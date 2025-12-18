# Podman & Docker: Container Engines

## What is a Container Engine?

A **container engine** is a software tool that automates the creation, deployment, and management of containers. Instead of manually creating namespaces, cgroups, and networking, container engines do it all for you.

---

## Docker vs Podman

### Docker

**Architecture**:

```
Docker CLI
    ↓
Docker Daemon (dockerd) - runs as root
    ↓
containerd
    ↓
runc → Container
```

**Characteristics**:

- Client-server architecture
- Requires daemon running as root
- Industry standard
- Large ecosystem
- Docker Compose for multi-container apps

### Podman

**Architecture**:

```
Podman CLI
    ↓
fork/exec → Container
(no daemon!)
```

**Characteristics**:

- Daemonless architecture
- Rootless containers (can run as regular user)
- Drop-in replacement for Docker (mostly compatible)
- Pod concept (like Kubernetes)
- Developed by Red Hat

### Key Differences

| Feature          | Docker                | Podman                  |
| ---------------- | --------------------- | ----------------------- |
| **Daemon**       | Required              | None                    |
| **Root**         | Needs root for daemon | Can run rootless        |
| **Command**      | `docker`              | `podman` (alias works!) |
| **Pods**         | No native support     | Yes (Kubernetes-like)   |
| **API**          | Docker API            | Compatible API          |
| **Compose**      | docker-compose        | podman-compose          |
| **Architecture** | Client-Server         | Fork-exec               |

---

## Podman Basics

### Searching for Images

```bash
# Search for MySQL images
podman search mysql
```

**Output** shows images from multiple registries:

```
NAME                              DESCRIPTION
docker.io/library/mysql           Official MySQL Docker image
quay.io/mysql/mysql-server        MySQL Server
registry.access.redhat.com/rhscl/mysql-57-rhel7
```

### Image Naming Convention (Standard)

Images follow this naming format:

```
[registry]/[namespace]/[image]:[tag]

Examples:
docker.io/library/nginx:latest
quay.io/fedora/httpd-24:latest
registry.example.com/myapp/web:v1.2.3
```

**Components**:

- **registry**: Where the image is stored (docker.io, quay.io)
- **namespace**: Organization or user (library, fedora)
- **image**: The actual image name (nginx, httpd)
- **tag**: Version or variant (latest, v1.2.3)

### Common Registries

- **docker.io**: Docker Hub (default for Docker)
- **quay.io**: Red Hat's container registry
- **registry.access.redhat.com**: Red Hat official images
- **gcr.io**: Google Container Registry
- **ghcr.io**: GitHub Container Registry

---

## Container Lifecycle

### Basic Operations

```bash
# Pull an image
podman pull quay.io/fedora/httpd-24

# Run a container
podman run -d --name myweb quay.io/fedora/httpd-24

# List running containers
podman ps

# List all containers (including stopped)
podman ps -a

# Stop a container
podman stop myweb

# Start a stopped container
podman start myweb

# Restart a container
podman restart myweb

# Remove a container
podman rm myweb

# Remove a running container (force)
podman rm -f myweb
```

### Run Options

```bash
# Run in detached mode
podman run -d nginx

# Run with custom name
podman run --name webserver nginx

# Run with environment variables
podman run -e MYSQL_ROOT_PASSWORD=secret mysql

# Run with port mapping
podman run -p 8080:80 nginx

# Run with volume mount
podman run -v /host/path:/container/path nginx

# Run interactively
podman run -it ubuntu /bin/bash

# Run with resource limits
podman run --memory=512m --cpus=1.5 nginx
```

---

## Port Mapping

### Understanding Port Mapping

When a container runs a service (e.g., web server on port 80), that port is inside the container's network namespace. To access it from outside, we need **port mapping**.

### Basic Port Mapping

```bash
# Map host port 8080 to container port 80
podman run -d -p 8080:80 nginx

# Access: http://localhost:8080
# → forwards to container's port 80
```

**Format**: `-p [host_ip:]host_port:container_port`

### Port Mapping Examples

```bash
# Simple mapping
-p 9090:8080
# Host port 9090 → Container port 8080
# Listens on ALL interfaces (0.0.0.0)

# Specific interface
-p 192.168.233.128:9092:8080
# Only accepts connections on 192.168.233.128:9092
# → Container port 8080

# Let system choose host port
-p 8080
# Random host port → Container port 8080

# Multiple ports
-p 8080:80 -p 8443:443
# Map both HTTP and HTTPS
```

### Checking Port Mappings

```bash
# Show ports for all containers
podman port --all

# Example output:
# f1dd4ce56ad4    8080/tcp -> 0.0.0.0:9091
# 49bf7f0ea760    8080/tcp -> 0.0.0.0:9090
# 252582c61275    8080/tcp -> 192.168.233.128:9092
```

---

## Container Networking

### Network Interfaces on Host

When you install a container engine, you'll see new network interfaces:

```bash
ifconfig
# or
ip addr

# Output shows:
# lo       - Loopback (127.0.0.1)
# ens33    - Physical network interface
# docker0  - Docker bridge (if using Docker)
# cni0     - Container Network Interface bridge (if using Podman)
```

Each interface has its own IP address.

### Request Flow

```
Internet Request → Host Interface (ens33) →
Port Mapping (iptables rules) →
Bridge (docker0/cni0) →
Container Interface → Container Process
```

### Multiple Network Attachment

Containers can be attached to multiple networks simultaneously:

```bash
# Create networks
podman network create mynetwork
podman network create public

# Attach container to multiple networks
podman run -d --name myhttpd \
  -p 9090:8080 \
  --network mynetwork,public \
  quay.io/fedora/httpd-24
```

**Use case**: Container needs to:

- Communicate with backend services (private network)
- Serve public traffic (public network)

### Same Port on Different Networks

A container can have:

- `eth0` on network1: port 80
- `eth1` on network2: port 80

**No conflict** because they're on different network interfaces!

**Real-world scenarios**:

1. Same service exposed on different networks with different IPs
2. Different applications on different networks using the same port

---

## File Operations

### Copying Files Between Host and Container

```bash
# Copy from host to container
podman cp /path/on/host/file.txt container_id:/path/in/container/

# Copy from container to host
podman cp container_id:/path/in/container/file.txt /path/on/host/

# Examples
podman cp config.json myweb:/etc/app/config.json
podman cp myweb:/var/log/app.log ./app.log
```

### When to Use

- Copy configuration files
- Extract logs
- Quick file transfers
- Debugging

**Note**: For persistent data, use **volumes** instead (covered later).

---

## Container States: Pause vs Stop

### Pause

```bash
podman pause container_id
```

**What happens**:

- Freezes ALL processes inside the container
- Uses the cgroup **freezer** controller
- Container still exists and uses resources
- Can be quickly resumed

**Behind the scenes**:

```bash
# CGroup freezer in action
echo FROZEN > /sys/fs/cgroup/freezer/container/freezer.state
```

**Resume**:

```bash
podman unpause container_id
```

### Stop

```bash
podman stop container_id
```

**What happens**:

1. Sends `SIGTERM` to all processes (graceful shutdown)
2. Waits 10 seconds (configurable)
3. Sends `SIGKILL` if still running (forced kill)
4. Container stops completely

**Difference**:
| Aspect | Pause | Stop |
|--------|-------|------|
| **Processes** | Frozen | Terminated |
| **Resume** | Instant | Must restart |
| **Resources** | Still allocated | Released |
| **Use case** | Temporary freeze | Shutdown |
| **Duration** | Short term | Long term |

---

## Overlay Filesystem in Action

### What You'll See

When you run a container, a new directory appears:

```bash
# List running containers
podman ps

# Check overlay mounts
mount | grep overlay

# You'll see something like:
overlay on /var/lib/containers/storage/overlay/abc123/merged
```

### Inside Container vs Host

**From inside the container**:

```bash
podman exec -it mycontainer /bin/bash

ls /
# Sees: /bin, /etc, /var, /usr, etc.
# Looks like a complete filesystem
```

**From the host**:

```bash
# The container's filesystem is actually at:
/var/lib/containers/storage/overlay/<container-id>/merged/

# This is a merged view of multiple layers
```

This is the **overlay filesystem** providing the container's root filesystem. We'll explore this in detail in the next chapter.

---

## Container Tools Ecosystem

### Core Tools

#### Docker

- **Purpose**: Complete container platform
- **Components**: CLI + daemon + containerd + runc
- **Use case**: General containerization

#### Podman

- **Purpose**: Daemonless container engine
- **Components**: CLI directly manages containers
- **Use case**: Rootless containers, systemd integration

#### Buildah

- **Purpose**: Build container images
- **Specialty**: Doesn't require Docker, scriptable builds
- **Use case**: Building images without Docker daemon

#### Skopeo

- **Purpose**: Manage container images
- **Operations**: Inspect, copy, sign images
- **Use case**: Copy images between registries without pulling

```bash
# Example: Copy image between registries
skopeo copy \
  docker://docker.io/nginx:latest \
  docker://my-registry.com/nginx:latest
```

### Container Runtimes

#### runc

- **Language**: Go
- **Standard**: OCI reference implementation
- **Used by**: Docker
- **Purpose**: Actually executes containers

#### crun

- **Language**: C
- **Performance**: Faster, lighter than runc
- **Used by**: Podman (default)
- **Creator**: Red Hat

#### cri-o

- **Purpose**: Container runtime for Kubernetes
- **Optimization**: Designed specifically for Kubernetes
- **Features**: OCI-compatible, lightweight

---

## OCI Compliance

### What is OCI?

**Open Container Initiative (OCI)** is a set of industry standards for containers.

### Purpose

- Standardize container formats
- Ensure interoperability
- Avoid vendor lock-in

### Two Main Standards

#### 1. Image Format Specification

Defines how container images are structured:

```
image/
├── blobs/
│   ├── sha256/abc123... (layer 1)
│   ├── sha256/def456... (layer 2)
│   └── sha256/ghi789... (config)
├── index.json
└── manifest.json
```

#### 2. Runtime Specification

Defines how containers are executed:

- Configuration format
- Execution environment
- Lifecycle operations
- Required features

### Why OCI Matters

**Benefit**: An OCI-compliant image can run on:

- Docker
- Podman
- Kubernetes (via CRI-O)
- Any OCI-compliant runtime

---

## Containerd

### What is Containerd?

**Containerd** is an industry-standard core container runtime. It manages the complete container lifecycle.

### Architecture

```
Docker/Podman
      ↓
  Containerd
      ↓
    runc/crun
      ↓
   Container
```

### Features

- Image transfer and storage
- Container execution and supervision
- Low-level storage management
- Network attachments
- Available for Linux and Windows

### Use Cases

- Docker uses containerd internally
- Kubernetes can use containerd directly (without Docker)
- Cloud providers use containerd for their container services

---

## Practical Examples

### Running a Web Server

```bash
# Pull and run nginx
podman run -d \
  --name webserver \
  -p 8080:80 \
  -v ~/html:/usr/share/nginx/html:ro \
  nginx

# Access
curl http://localhost:8080
```

### Running a Database

```bash
# Run PostgreSQL
podman run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13

# Connect
psql -h localhost -U postgres
```

### Interactive Debugging

```bash
# Run Ubuntu container interactively
podman run -it ubuntu /bin/bash

# Inside container
apt update
apt install curl
curl ifconfig.me
exit
```

---

## Best Practices

### 1. Use Specific Tags

```bash
# ❌ Don't
podman run nginx:latest

# ✅ Do
podman run nginx:1.21.6
```

### 2. Name Your Containers

```bash
# ❌ Don't
podman run -d nginx

# ✅ Do
podman run -d --name my-web-server nginx
```

### 3. Clean Up

```bash
# Remove stopped containers
podman container prune

# Remove unused images
podman image prune

# Remove everything unused
podman system prune -a
```

### 4. Use Resource Limits

```bash
podman run -d \
  --memory=512m \
  --cpus=1 \
  --memory-reservation=256m \
  nginx
```

---

## Key Takeaways

1. **Container engines** automate container management
2. **Podman** is daemonless, **Docker** uses a daemon
3. Container **lifecycle** includes: pull, run, stop, start, remove
4. **Port mapping** exposes container services to the outside
5. Containers can attach to **multiple networks**
6. **Pause** freezes, **stop** terminates
7. **OCI standards** ensure interoperability
8. Multiple tools exist for different purposes (buildah, skopeo, etc.)

---

## Next Steps

Now that you understand how to work with container engines, let's dive deep into **container networking** to understand how containers communicate.

Continue to: [05-networking.md](05-networking.md)
