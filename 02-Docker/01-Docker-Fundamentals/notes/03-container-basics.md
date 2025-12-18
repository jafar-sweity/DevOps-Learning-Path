# Container Basics

## The Evolution: VMs to Containers

### The Problem

Imagine you have a server running multiple applications:

```
Server
├── Java App 1
├── Java App 2
├── Apache Web Server
├── Database
└── Other Services
```

**Challenges**:

1. **Dependency Conflicts**: App 1 needs Java 8, App 2 needs Java 11
2. **Resource Competition**: No way to limit each app's resources
3. **Update Nightmare**: Updating one component might break others
4. **Scaling Issues**: Can't easily scale individual apps
5. **Security Risks**: Apps can interfere with each other

### Traditional Solution: Virtual Machines

```
Physical Server
├── VM1 (OS + App1)
├── VM2 (OS + App2)
├── VM3 (OS + App3)
└── ...
```

**Problems with VMs**:

- Each VM runs a full OS (heavy overhead)
- Slow to start (minutes)
- Resource intensive (GBs per VM)
- Limited density (50-60 VMs per server?)
- **Question**: What happens when you run out of capacity?

---

## The Container Revolution

### The Insight

**Remember what we learned**:

- CGroups can limit resources (CPU, memory, etc.)
- Namespaces can isolate views (PID, network, filesystem, etc.)

**What if we combine them?**

```
Namespaces + CGroups = Fully Isolated Environment
```

This is the **core idea** of containers!

---

## How Containers Work

### Architecture

```
┌─────────────────────────────────────────────┐
│           Container (Process)               │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  Application + Dependencies          │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Isolated by:                              │
│  • PID Namespace    (own process tree)     │
│  • Network Namespace (own network stack)   │
│  • Mount Namespace  (own filesystem)       │
│  • UTS Namespace    (own hostname)         │
│  • IPC Namespace    (isolated IPC)         │
│  • User Namespace   (UID/GID mapping)      │
│                                             │
│  Limited by:                               │
│  • CPU CGroup       (CPU quota)            │
│  • Memory CGroup    (RAM limit)            │
│  • Disk CGroup      (I/O limits)           │
│  • Network CGroup   (bandwidth)            │
└─────────────────────────────────────────────┘
        │
        └──> Runs on Host Kernel
```

### Key Differences: VM vs Container

| Aspect        | Virtual Machine         | Container                    |
| ------------- | ----------------------- | ---------------------------- |
| **Isolation** | Hardware virtualization | Kernel features (namespaces) |
| **OS**        | Full OS per VM          | Shares host kernel           |
| **Size**      | GBs                     | MBs                          |
| **Startup**   | Minutes                 | Seconds                      |
| **Overhead**  | Heavy                   | Minimal                      |
| **Density**   | 10s per host            | 100s-1000s per host          |
| **Security**  | Strong (hypervisor)     | Good (kernel isolation)      |

---

## User Mode vs Kernel Mode

### Understanding the Separation

```
┌─────────────────────────────────────────┐
│         User Mode (User Space)          │
│  ┌──────────┐  ┌──────────┐            │
│  │Container1│  │Container2│            │
│  └────┬─────┘  └────┬─────┘            │
│       │             │                   │
│       └─────┬───────┘                   │
│             │ System Calls              │
│═════════════╪═══════════════════════════│
│             ▼                           │
│      ┌─────────────┐                    │
│      │   Kernel    │                    │
│      │   (Core)    │                    │
│      └─────────────┘                    │
│         Kernel Mode                     │
└─────────────────────────────────────────┘
```

**Important Concept**:

- Applications (and containers) run in **user mode**
- They don't directly interact with hardware
- They make **system calls** to the kernel
- The kernel executes requests in **kernel mode**

### Why This Matters for Containers

1. **Shared Kernel**: All containers share the same kernel
2. **System Call Interface**: Containers use syscalls like any process
3. **Security**: We need to restrict which syscalls containers can make

---

## Seccomp: System Call Filtering

### What is Seccomp?

**Secure Computing Mode (seccomp)** is a Linux kernel feature that restricts which system calls a process can make.

### Why Containers Need Seccomp

Without filtering, a container could:

- Make dangerous system calls
- Potentially exploit kernel vulnerabilities
- Affect other containers or the host

### How It Works

```
Container Process
      │
      │ Attempts syscall (e.g., mount)
      ▼
 ┌─────────┐
 │ Seccomp │ ──► Checks against policy
 │ Filter  │
 └────┬────┘
      │
      ├─→ Allowed: Pass to kernel
      └─→ Blocked: Return error (or kill process)
```

### Example Seccomp Policy

```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "syscalls": [
    {
      "names": ["read", "write", "open", "close"],
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "names": ["mount", "umount", "reboot"],
      "action": "SCMP_ACT_KILL"
    }
  ]
}
```

Container engines apply seccomp profiles by default to enhance security.

---

## Complete Container Isolation

### What a Container Gets

```
┌────────────────────────────────────────┐
│  Container sees itself as a system:    │
│                                        │
│  • Own PID 1 (init process)           │
│  • Own hostname                        │
│  • Own network interfaces              │
│  • Own filesystem tree                 │
│  • Own process tree                    │
│  • Own users (with user namespaces)    │
│                                        │
│  Limited resources:                    │
│  • CPU: 50% of 1 core                 │
│  • Memory: 512MB                       │
│  • Disk I/O: 10MB/s                    │
│                                        │
│  Restricted capabilities:              │
│  • Can't load kernel modules           │
│  • Can't reboot system                 │
│  • Limited syscalls via seccomp        │
└────────────────────────────────────────┘
```

---

## How Container Engines Put It Together

When you run `podman run` or `docker run`, the engine:

1. **Creates Namespaces**

   ```bash
   unshare --pid --net --mount --uts --ipc --fork
   ```

2. **Sets up CGroups**

   ```bash
   # Limit CPU to 50%
   echo 50000 > /sys/fs/cgroup/cpu/container/cpu.cfs_quota_us

   # Limit memory to 512MB
   echo 536870912 > /sys/fs/cgroup/memory/container/memory.limit_in_bytes
   ```

3. **Configures Networking**

   ```bash
   # Create veth pair
   # Connect to bridge
   # Set up NAT/port forwarding
   ```

4. **Mounts Filesystem** (we'll cover this in detail later)

   ```bash
   # Use overlay filesystem
   # Mount container root
   # Mount volumes
   ```

5. **Applies Security**

   ```bash
   # Apply seccomp profile
   # Set capabilities
   # Apply SELinux context
   ```

6. **Starts Process**
   ```bash
   # Execute container's main process as PID 1
   ```

---

## Container Process View

### From the Host

```bash
# On the host
ps aux | grep container_process
# Shows: process with normal PID (e.g., 15234)

# Check namespaces
ls -la /proc/15234/ns/
# Shows all namespace assignments
```

### From Inside the Container

```bash
# Inside container
ps aux
# Shows: process as PID 1

echo $$
# Shows: 1 (the container thinks it's PID 1)

hostname
# Shows: unique container hostname

ip addr
# Shows: container's network interfaces only
```

### The Magic

The same process has:

- **PID 15234** on the host
- **PID 1** inside the container

This is namespace isolation in action!

---

## Analogy: Containers as Apartments

Think of containers like apartments in a building:

```
Building (Host System)
├── Apartment 1 (Container 1)
│   ├── Own address (IP)
│   ├── Own utilities allocation (CGroups)
│   ├── Own keys (credentials)
│   └── Can't see inside other apartments (namespaces)
├── Apartment 2 (Container 2)
│   └── ... same isolation
└── Apartment 3 (Container 3)
    └── ... same isolation

Shared:
├── Building structure (kernel)
├── Electrical/water mains (hardware)
└── Building rules (host policies)
```

---

## The Benefits of Containers

### 1. **Lightweight**

- No full OS per container
- Share kernel with host
- MB instead of GB

### 2. **Fast**

- Start in seconds
- No OS boot time
- Quick to create/destroy

### 3. **Consistent**

- Same environment everywhere
- "Works on my machine" solved
- Reproducible builds

### 4. **Portable**

- Run anywhere with container engine
- Cloud, on-premises, laptop
- Same behavior everywhere

### 5. **Scalable**

- High density on hardware
- Easy to replicate
- Orchestration tools (Kubernetes)

### 6. **Isolated**

- Process isolation
- Resource limits
- Security boundaries

---

## Real-World Container Scenarios

### Scenario 1: Microservices

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  API     │  │  Auth    │  │ Database │
│Container │◄─┤Container ├─►│Container │
│          │  │          │  │          │
└──────────┘  └──────────┘  └──────────┘
```

Each service runs in its own container with proper isolation.

### Scenario 2: Development Environment

```
Developer Laptop:
├── Container: Node.js v16 + React app
├── Container: Python 3.9 + Flask API
├── Container: PostgreSQL 13
└── Container: Redis cache

Same as Production! No "works on my machine"
```

### Scenario 3: CI/CD Pipeline

```
1. Code commit
2. Spin up container with build environment
3. Run tests in container
4. Build application in container
5. Push container image to registry
6. Deploy container to production
```

Clean, reproducible, isolated builds.

---

## Key Takeaways

1. **Containers = Namespaces + CGroups + Seccomp**
2. Containers share the host kernel (unlike VMs)
3. Each container is isolated but lightweight
4. Processes in containers appear isolated but run on host kernel
5. Security is enforced through multiple layers
6. Container engines automate all the complex setup

---

## What We Haven't Covered Yet

- How are container **images** built and stored? (Next chapter)
- How does container **networking** really work? (Coming soon)
- What are the different **container engines**? (Podman vs Docker)
- How do **registries** work? (Docker Hub, etc.)

---

## Next Steps

Now that you understand what containers are and how they achieve isolation, let's explore the tools that make working with containers practical: **Podman and Docker**.

Continue to: [04-podman-docker.md](04-podman-docker.md)
