# Container Image Registries

## What is a Container Registry?

A **container registry** is a storage and distribution system for container images. Think of it as a "library" or "app store" for container images.

```
┌─────────────┐
│  Developer  │
└──────┬──────┘
       │ Push
       ▼
┌─────────────┐
│  Registry   │  ◄─── Pull ─── Servers/Users
└─────────────┘
```

---

## How Registries Work

### The Pull Process

When you run `podman pull` or `docker pull`:

```
1. Client sends HTTP request to registry
      ↓
2. Registry authenticates request (if private)
      ↓
3. Registry returns image manifest (metadata)
      ↓
4. Client downloads layers (as compressed tar files)
      ↓
5. Client extracts and stores layers locally
      ↓
6. Image ready to use
```

### Image Manifest

The manifest is a JSON file containing:

- Image configuration
- List of layers and their checksums
- Platform information (architecture, OS)
- Metadata (author, creation time)

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
  "config": {
    "mediaType": "application/vnd.docker.container.image.v1+json",
    "size": 7023,
    "digest": "sha256:abc123..."
  },
  "layers": [
    {
      "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
      "size": 27145492,
      "digest": "sha256:def456..."
    }
  ]
}
```

### Registry API

Registries expose HTTP APIs for:

- Searching images
- Pulling images (layers + manifest)
- Pushing images
- Deleting images
- Managing tags

---

## Popular Registry Solutions

### 1. Docker Hub

**Type**: Public cloud registry

**Features**:

- Free public repositories
- Paid private repositories
- Official images (nginx, mysql, ubuntu, etc.)
- Automated builds from GitHub/Bitbucket
- Webhooks for CI/CD
- Team collaboration tools

**Usage**:

```bash
# Pull from Docker Hub (default)
podman pull nginx
# Same as: docker.io/library/nginx:latest

# Push to Docker Hub
podman push myusername/myimage:v1.0
```

**URL**: https://hub.docker.com

---

### 2. Quay.io

**Type**: Cloud registry by Red Hat

**Features**:

- Free public repositories
- Paid private repositories
- Image vulnerability scanning (Clair)
- Robot accounts for automation
- Team/organization support
- Git repository integration
- Time-machine (view old image versions)
- Geo-replication

**Usage**:

```bash
# Pull from Quay
podman pull quay.io/fedora/httpd-24

# Push to Quay
podman push quay.io/myorg/myimage:latest
```

**URL**: https://quay.io

---

### 3. Harbor

**Type**: Self-hosted enterprise registry

**Features**:

- **Open source** (CNCF project)
- Image vulnerability scanning
- Content signing and validation
- Multi-tenancy support
- Role-based access control (RBAC)
- Replication between registries
- Image retention policies
- Webhook notifications
- Audit logging
- Helm chart repository
- Web UI + API

**Architecture**:

```
┌─────────────────────────────────────┐
│           Harbor Core               │
├──────────┬────────────┬─────────────┤
│ Registry │ Database   │ Job Service │
│ (store)  │ (metadata) │ (scanning)  │
└──────────┴────────────┴─────────────┘
```

**Use Case**: Enterprise on-premises deployments

---

### 4. Nexus Repository

**Type**: Universal repository manager

**Features**:

- Supports **multiple formats**: Docker, Maven, npm, NuGet, PyPI, Ruby Gems, etc.
- Proxy remote registries (cache Docker Hub locally)
- Host private repositories
- Role-based access control
- REST API
- Web UI
- Cleanup policies
- Blob storage

**Use Case**: Organizations with multiple artifact types

**Advantage**: One tool for all artifacts (not just containers)

---

### Comparison Table

| Feature          | Docker Hub    | Quay.io     | Harbor            | Nexus          |
| ---------------- | ------------- | ----------- | ----------------- | -------------- |
| **Hosting**      | Cloud         | Cloud       | Self-hosted       | Self-hosted    |
| **Cost**         | Free + Paid   | Free + Paid | Free              | Free + Paid    |
| **Scanning**     | Yes           | Yes (Clair) | Yes (Clair/Trivy) | Yes            |
| **RBAC**         | Basic         | Advanced    | Advanced          | Advanced       |
| **Replication**  | No            | Yes         | Yes               | Yes            |
| **Multi-format** | No            | No          | No                | Yes            |
| **Best for**     | Public images | Teams       | Enterprises       | Multi-artifact |

---

## Setting Up a Private Registry

### What You Need

To run your own image registry:

1. **Registry Software** (as RPM or container)
2. **Authentication** (HTTP basic auth, OAuth, etc.)
3. **Storage** (directory, S3, etc.)
4. **SSL Certificates** (for HTTPS)
5. **Firewall Rules** (allow registry port)

---

### Step-by-Step: Local Registry Setup

#### 1. Create Directory Structure

```bash
# Create registry directory
sudo mkdir -p /opt/registry/{auth,certs,data}

# Set permissions
sudo chown -R $(whoami):$(whoami) /opt/registry
```

#### 2. Generate Authentication

```bash
# Install htpasswd (if not installed)
sudo dnf install httpd-tools  # RHEL/Fedora
# or
sudo apt install apache2-utils  # Ubuntu/Debian

# Create user and password
htpasswd -Bc /opt/registry/auth/htpasswd myuser
# Enter password when prompted
```

**What this does**: Creates a password file for basic HTTP authentication.

#### 3. Generate SSL Certificate

```bash
# Create self-signed certificate
sudo openssl req -newkey rsa:2048 \
  -nodes \
  -sha256 \
  -keyout /opt/registry/certs/registry.key \
  -x509 \
  -days 365 \
  -out /opt/registry/certs/registry.crt \
  -subj "/CN=registry.local" \
  -addext "subjectAltName=DNS:registry.local,DNS:localhost,IP:192.168.1.100"

# Fix permissions
chmod 644 /opt/registry/certs/registry.crt
chmod 600 /opt/registry/certs/registry.key
```

**Explanation**:

- `-newkey rsa:2048`: 2048-bit RSA key
- `-nodes`: No password on private key
- `-x509`: Self-signed certificate
- `-days 365`: Valid for 1 year
- `-subj`: Certificate subject (customize CN)
- `-addext`: Additional DNS names and IPs

#### 4. Trust the Certificate

```bash
# Copy certificate to trusted store
sudo cp /opt/registry/certs/registry.crt /usr/local/share/ca-certificates/

# Update certificate trust store
sudo update-ca-certificates

# Verify
sudo trust list | grep registry
```

**Why?** So Podman/Docker trusts your self-signed certificate.

#### 5. Configure /etc/hosts

```bash
# Add registry hostname
echo "192.168.1.100 registry.local" | sudo tee -a /etc/hosts
```

Replace `192.168.1.100` with your actual IP.

#### 6. Run Registry Container

```bash
podman run -d \
  --name myregistry \
  -p 5000:5000 \
  -v /opt/registry/data:/var/lib/registry:z \
  -v /opt/registry/auth:/auth:z \
  -v /opt/registry/certs:/certs:z \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  docker.io/library/registry:2
```

**Explanation**:

- `-p 5000:5000`: Expose registry on port 5000
- `-v .../data:/var/lib/registry`: Persistent image storage
- `-v .../auth:/auth`: Mount auth files
- `-v .../certs:/certs`: Mount SSL certificates
- `-e REGISTRY_AUTH=htpasswd`: Use htpasswd authentication
- `-e REGISTRY_HTTP_TLS_*`: Enable HTTPS

#### 7. Configure Firewall

```bash
# Allow registry port
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

---

### Using Your Private Registry

#### Login

```bash
# Login to registry
podman login registry.local:5000
# Enter username and password
```

#### Tag and Push

```bash
# Tag an image
podman tag nginx:latest registry.local:5000/nginx:latest

# Push to registry
podman push registry.local:5000/nginx:latest
```

#### Pull from Registry

```bash
# Pull from your registry
podman pull registry.local:5000/nginx:latest
```

#### List Images in Registry

```bash
# Using API
curl -u myuser:mypass https://registry.local:5000/v2/_catalog

# Response:
# {"repositories":["nginx","myapp"]}
```

---

## Registry Authentication

### Methods

1. **Basic Authentication** (username/password)

   - Simple htpasswd file
   - Easy to set up
   - Suitable for small teams

2. **Token-based** (OAuth, JWT)

   - More secure
   - Scalable
   - Required for advanced features

3. **Certificate-based**
   - Client certificates
   - Mutual TLS (mTLS)
   - Highest security

### Storing Credentials

```bash
# Credentials stored in:
cat ~/.config/containers/auth.json

# or (for Docker)
cat ~/.docker/config.json

# Contains encoded tokens for each registry
```

---

## Registry Best Practices

### 1. Security

```bash
# ✅ Always use HTTPS
# ✅ Implement authentication
# ✅ Scan images for vulnerabilities
# ✅ Use role-based access control
# ✅ Audit image pulls/pushes
# ✅ Keep registry software updated
```

### 2. Image Naming

```bash
# ✅ Good naming convention
registry.example.com/team/service:v1.2.3
registry.example.com/project/component:sha-abc123
registry.example.com/environment/app:20231201

# ❌ Poor naming
registry.example.com/image:latest
registry.example.com/test:1
```

### 3. Tagging Strategy

```bash
# Multiple tags for same image
podman tag myapp:build-123 registry.local:5000/myapp:latest
podman tag myapp:build-123 registry.local:5000/myapp:v1.2.3
podman tag myapp:build-123 registry.local:5000/myapp:stable

# Push all tags
podman push --all-tags registry.local:5000/myapp
```

### 4. Cleanup Policies

- Remove old/unused images automatically
- Set retention periods (e.g., keep last 10 tags)
- Delete untagged images
- Archive to cheaper storage

---

## Registry Storage

### Storage Backends

1. **Filesystem** (default)

   - Simple directory on disk
   - Good for small deployments

2. **Object Storage**

   - S3, GCS, Azure Blob
   - Highly scalable
   - Best for production

3. **Network Storage**
   - NFS, Ceph
   - Shared across registry replicas

### Storage Configuration

```yaml
# Registry config (config.yml)
storage:
  filesystem:
    rootdirectory: /var/lib/registry

  # Or S3
  s3:
    accesskey: AKIAIOSFODNN7EXAMPLE
    secretkey: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    region: us-east-1
    bucket: my-registry-bucket
```

---

## Registry Replication

### Why Replicate?

- **High availability**: Redundancy
- **Geo-distribution**: Faster pulls worldwide
- **Disaster recovery**: Backup
- **Load balancing**: Distribute traffic

### Replication Strategies

```
┌──────────────┐
│ Main Registry│
└──────┬───────┘
       │ Replicate
  ┌────┴────┬────────┐
  ▼         ▼        ▼
┌────┐   ┌────┐   ┌────┐
│ US │   │ EU │   │ASIA│
└────┘   └────┘   └────┘
```

**Harbor Example**:

- Configure replication rules
- Schedule or trigger-based
- Filter by repository/tag
- Track replication status

---

## Inspecting Registry Images

### Using Skopeo

```bash
# Inspect image without pulling
skopeo inspect docker://registry.local:5000/nginx:latest

# Copy image between registries
skopeo copy \
  docker://docker.io/nginx:latest \
  docker://registry.local:5000/nginx:latest

# List tags
skopeo list-tags docker://registry.local:5000/nginx
```

### Using Registry API

```bash
# List repositories
curl -u user:pass https://registry.local:5000/v2/_catalog

# List tags for a repository
curl -u user:pass https://registry.local:5000/v2/nginx/tags/list

# Get manifest
curl -u user:pass https://registry.local:5000/v2/nginx/manifests/latest
```

---

## Troubleshooting

### Common Issues

#### 1. Certificate Errors

```bash
# Error: x509: certificate signed by unknown authority

# Solution: Trust the certificate
sudo cp /path/to/cert.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

#### 2. Authentication Failed

```bash
# Error: unauthorized: authentication required

# Solution: Login first
podman login registry.local:5000
```

#### 3. Connection Refused

```bash
# Error: connection refused

# Check:
1. Registry container running?
2. Firewall allows port 5000?
3. Correct hostname in /etc/hosts?
```

#### 4. Insecure Registry

```bash
# For testing only (not recommended for production)

# Add to /etc/containers/registries.conf
[registries.insecure]
registries = ['registry.local:5000']
```

---

## CI/CD Integration

### Example Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - build
  - push

build:
  stage: build
  script:
    - podman build -t myapp:$CI_COMMIT_SHA .

push:
  stage: push
  script:
    - podman login -u $REGISTRY_USER -p $REGISTRY_PASS registry.local:5000
    - podman tag myapp:$CI_COMMIT_SHA registry.local:5000/myapp:latest
    - podman push registry.local:5000/myapp:latest
```

---

## Key Takeaways

1. **Registries** store and distribute container images
2. **Pull/Push** uses HTTP API with authentication
3. **Popular solutions**: Docker Hub (cloud), Harbor (self-hosted)
4. **Private registries** need: auth, SSL, storage
5. **Best practices**: HTTPS, scanning, RBAC, cleanup
6. **Replication** provides HA and geo-distribution
7. **Skopeo** manages images without pulling them

---

## Next Steps

You now understand the complete container ecosystem from kernel features to image distribution. Let's explore **advanced topics** including OCI standards, container runtimes, and the broader container tools ecosystem.

Continue to: [08-advanced-topics.md](08-advanced-topics.md)
