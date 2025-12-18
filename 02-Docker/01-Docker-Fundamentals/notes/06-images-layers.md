# Container Images and Layers

## What is a Container Image?

A **container image** is a lightweight, standalone, executable package that includes everything needed to run a piece of software:

- Application code
- Runtime environment
- System tools
- System libraries
- Settings and dependencies

---

## Images Are Made of Layers

### Core Concept

An image is **not a single file** but a **collection of layers** stacked on top of each other.

```
┌─────────────────────────────────┐
│   Layer 4: Application Code     │  ← Your app
├─────────────────────────────────┤
│   Layer 3: Dependencies         │  ← npm/pip packages
├─────────────────────────────────┤
│   Layer 2: Runtime (Node.js)    │  ← Language runtime
├─────────────────────────────────┤
│   Layer 1: Base OS (Ubuntu)     │  ← Base filesystem
└─────────────────────────────────┘
```

Each layer contains:

- A set of files
- Filesystem changes from the layer below
- Metadata

---

## Why Layers?

### 1. **Efficiency**

Layers are **reused** across different images:

```
Image A:                 Image B:
┌──────────────┐        ┌──────────────┐
│  App A       │        │  App B       │
├──────────────┤        ├──────────────┤
│  Python 3.9  │◄──────►│  Python 3.9  │  ← Shared layer
├──────────────┤        ├──────────────┤
│  Ubuntu      │◄──────►│  Ubuntu      │  ← Shared layer
└──────────────┘        └──────────────┘
```

**Result**: Download once, use multiple times!

### 2. **Fast Builds**

When rebuilding an image, **only changed layers are rebuilt**:

```
Dockerfile:                    Layer Cache:
1. FROM ubuntu                 ✓ Cached
2. RUN apt update             ✓ Cached
3. COPY app.py /app/          ✗ Changed → Rebuild
4. CMD python /app/app.py     ✗ Rebuild
```

### 3. **Space Savings**

Multiple containers from the same image **share layers**:

```
Image (stored once)
     ↓
┌────┴────┬────────┬────────┐
│         │        │        │
Container1 Container2 Container3
(only diff) (only diff) (only diff)
```

---

## OverlayFS: The Union Filesystem

### What is OverlayFS?

**OverlayFS** is a union filesystem that allows multiple layers to be combined into a single unified view.

### Three Key Directories

```
┌─────────────────────────────────────┐
│         Unified View                │
│          (merged/)                  │
└────────────┬────────────────────────┘
             │
        ┌────┴─────┐
        │ OverlayFS│
        └────┬─────┘
             │
    ┌────────┼────────┐
    │        │        │
LowerDir UpperDir WorkDir
(Read-Only)(Read-Write)(Temp)
```

### Directory Purposes

| Directory    | Access     | Purpose                    | Content                             |
| ------------ | ---------- | -------------------------- | ----------------------------------- |
| **lowerdir** | Read-Only  | Base layers (image layers) | Immutable files from image          |
| **upperdir** | Read-Write | Container changes          | Files created/modified by container |
| **workdir**  | Internal   | Temporary operations       | Used by OverlayFS internally        |
| **merged**   | Unified    | Combined view              | What the container sees             |

---

## How OverlayFS Works

### Reading Files

```
Container wants to read /etc/config.txt

1. Check upperdir → Not found
2. Check lowerdir layer 3 → Not found
3. Check lowerdir layer 2 → Found!
4. Return file to container
```

**Principle**: Search from top (upperdir) to bottom (lowerdir layers).

### Writing Files

#### Case 1: Creating New File

```
Container creates /app/data.txt

1. Check if exists in lowerdir → No
2. Create file in upperdir
3. File appears in merged view
```

#### Case 2: Modifying Existing File (Copy-on-Write)

```
Container modifies /etc/config.txt (exists in lowerdir)

1. Copy file from lowerdir to upperdir
2. Modify the copy in upperdir
3. Original in lowerdir remains unchanged
4. Merged view shows modified version
```

This is **Copy-on-Write (CoW)**.

#### Case 3: Deleting File

```
Container deletes /etc/config.txt

1. Can't delete from lowerdir (read-only)
2. Create "whiteout" marker in upperdir
3. Merged view hides the file
4. Original still exists in lowerdir
```

---

## Practical Example: Manual OverlayFS

### Setup

```bash
# Create directory structure
cd ~
mkdir overlayfs && cd overlayfs
mkdir lower1 lower2 lower3 upper workdir merged

# Create files in lower layers
echo "Hello from lower1" > lower1/file1.txt
echo "Hello from lower1" > lower1/file2.txt

echo "Hello from lower2" > lower2/file2.txt
echo "Hello from lower2" > lower2/file3.txt

echo "Hello from lower3" > lower3/file3.txt
echo "Hello from lower3" > lower3/file4.txt

# Create files in upper layer
echo "Hello from upper" > upper/file3.txt
echo "Hello from upper" > upper/file4.txt
```

### Mounting OverlayFS

```bash
# Mount overlay filesystem
sudo mount -t overlay overlay \
  -o lowerdir=lower1:lower2:lower3,upperdir=upper,workdir=workdir \
  merged/
```

**Note**: Layers in `lowerdir` are listed from **highest to lowest priority**.

### Viewing Merged Result

```bash
# List merged directory
ls merged/
# Shows: file1.txt file2.txt file3.txt file4.txt

# Check file1.txt (only in lower1)
cat merged/file1.txt
# Output: Hello from lower1

# Check file2.txt (in lower1 and lower2, lower1 has priority)
cat merged/file2.txt
# Output: Hello from lower1

# Check file3.txt (in lower2, lower3, and upper; upper has priority)
cat merged/file3.txt
# Output: Hello from upper

# Check file4.txt (in lower3 and upper; upper has priority)
cat merged/file4.txt
# Output: Hello from upper
```

### Making Changes

```bash
# Create new file in merged
echo "New file" > merged/file5.txt

# Check where it went
ls upper/
# Shows: file3.txt file4.txt file5.txt

# Modify existing file
echo "Modified" > merged/file1.txt

# Check upper directory
cat upper/file1.txt
# Shows: Modified

# Original is still in lower1
cat lower1/file1.txt
# Shows: Hello from lower1
```

### Unmounting

```bash
sudo umount merged
```

---

## Container Image Layers in Practice

### Viewing Layers

```bash
# Pull an image
podman pull nginx

# Inspect image layers
podman inspect nginx

# View layer IDs
podman history nginx
```

**Output shows**:

- Each layer's size
- Command that created it
- Layer ID

### Storage Location

```bash
# Podman storage location
ls /var/lib/containers/storage/overlay/

# Each directory is a layer
# Format: <layer-id>/
#   ├── diff/      ← Actual files
#   ├── link       ← Short identifier
#   └── work/      ← Work directory
```

### Running Container

```bash
# Run container
podman run -d --name testnginx nginx

# Find overlay mount
mount | grep overlay
# Shows overlay mount with lowerdir, upperdir, workdir

# Example output:
# overlay on /var/lib/containers/storage/overlay/<id>/merged
# type overlay (rw,lowerdir=/var/lib/containers/storage/overlay/<layer1>/diff:
#             /var/lib/containers/storage/overlay/<layer2>/diff:...,
#             upperdir=/var/lib/containers/storage/overlay/<id>/diff,
#             workdir=/var/lib/containers/storage/overlay/<id>/work)
```

---

## Layer Optimization

### Problem: Too Many Layers

```dockerfile
# ❌ Bad: Many layers
FROM ubuntu
RUN apt update
RUN apt install -y curl
RUN apt install -y wget
RUN apt install -y vim
RUN apt clean
```

**Issues**:

- 6 layers total
- Larger image size
- Slower builds and pulls
- Can't remove intermediate files from earlier layers

### Solution: Combine Commands

```dockerfile
# ✅ Good: Fewer layers
FROM ubuntu
RUN apt update && \
    apt install -y curl wget vim && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
```

**Benefits**:

- 2 layers total (FROM + RUN)
- Smaller size (cleanup in same layer)
- Faster operations

---

## Image Size Considerations

### Layer Accumulation

```
Layer 1: +100 MB (base OS)
Layer 2: +50 MB  (install packages)
Layer 3: -30 MB  (delete files) ← Doesn't reduce total size!
Layer 4: +20 MB  (add app)

Total: 100 + 50 + 0 + 20 = 170 MB
```

**Why?** The deleted files still exist in Layer 2!

### Best Practices

```dockerfile
# ✅ Clean up in the same layer
RUN wget https://example.com/file.tar.gz && \
    tar xzf file.tar.gz && \
    rm file.tar.gz  # Deleted in same layer = actually removed

# ❌ Don't clean up in different layer
RUN wget https://example.com/file.tar.gz
RUN tar xzf file.tar.gz
RUN rm file.tar.gz  # Too late! File is in previous layer
```

---

## Universal Base Images (UBI)

### What are UBIs?

**Universal Base Images** are container images provided by Red Hat that are:

- Free to use
- Redistributable
- Receive security updates
- Can be used in production
- Work with Docker, Podman, Kubernetes

### Types of UBI

#### 1. Micro

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi-micro
```

- **Smallest**: Minimal footprint
- **Contains**: Only runtime dependencies
- **Use case**: Single static binary
- **Size**: ~30 MB

#### 2. Minimal

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi-minimal
```

- **Size**: ~90 MB
- **Contains**: Basic tools, microdnf
- **Use case**: Small applications
- **Tools**: Basic debugging utilities

#### 3. Standard

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi
```

- **Size**: ~200 MB
- **Contains**: Full package manager (dnf), development tools
- **Use case**: General-purpose applications
- **Tools**: Full toolchain, SSL libraries, tar, gzip

#### 4. Multi-Service

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi-init
```

- **Contains**: Standard UBI + systemd
- **Use case**: Run multiple services in one container
- **Features**: Can use systemd to manage services

---

## Pre-Built vs Custom Images

### Pre-Built Images

**Advantages**:

- Ready to use
- Maintained by experts
- Regular security updates
- Best practices applied

**Sources**:

- Official images (Docker Hub, Quay.io)
- Red Hat (UBI)
- Vendor images (MongoDB, PostgreSQL)

### Custom Images

**When to build custom**:

- Specific requirements
- Combine multiple applications
- Custom configurations
- Company-specific needs

---

## Container Image Lifecycle

### From Build to Run

```
1. Dockerfile
      ↓
2. Build Process (creates layers)
      ↓
3. Image (stored in local storage)
      ↓
4. Push to Registry (optional)
      ↓
5. Pull from Registry (on other systems)
      ↓
6. Run Container
      ↓
7. OverlayFS mounts layers + upperdir
      ↓
8. Container sees merged filesystem
```

---

## Inspecting Image Internals

### Useful Commands

```bash
# View image history
podman history nginx

# Inspect image details
podman inspect nginx

# Show image layers and sizes
podman images --tree

# Export image to tar
podman save nginx -o nginx.tar

# Extract and explore
tar -xf nginx.tar
# Contains:
# - manifest.json
# - Layer directories
# - Config files
```

---

## Copy-on-Write Performance

### Reading (Fast)

- Files read directly from layers
- No copying needed
- Very efficient

### Writing (Slight Overhead)

- First write: Copy entire file to upperdir
- Subsequent writes: Modify in upperdir
- Large files = more overhead on first write

### Optimization Tips

1. **Use volumes for heavy I/O**:

   ```bash
   podman run -v /host/data:/container/data myapp
   ```

2. **Minimize file modifications in containers**

3. **Keep container images focused** (fewer files to manage)

---

## Best Practices Summary

### Image Building

1. ✅ Use official base images
2. ✅ Combine RUN commands
3. ✅ Clean up in the same layer
4. ✅ Order commands by change frequency
5. ✅ Use .dockerignore
6. ✅ Use specific tags, not `latest`

### Image Size

1. ✅ Start with minimal base images
2. ✅ Remove unnecessary files
3. ✅ Use multi-stage builds
4. ✅ Avoid installing dev dependencies in production

### Security

1. ✅ Scan images for vulnerabilities
2. ✅ Use official images
3. ✅ Keep images updated
4. ✅ Don't run as root in containers
5. ✅ Use UBI for production

---

## Key Takeaways

1. **Images are layers** stacked on top of each other
2. **OverlayFS** provides the unified filesystem view
3. **lowerdir** = read-only image layers
4. **upperdir** = read-write container changes
5. **Copy-on-Write** preserves lower layers
6. **Optimize layers** for smaller, faster images
7. **UBI** provides production-ready base images
8. **Layers are shared** between images and containers

---

## Next Steps

Now that you understand how images are structured and stored, let's explore how images are distributed and managed through **image registries**.

Continue to: [07-registries.md](07-registries.md)
