# Linux Namespaces

## Overview

While CGroups control **how much** resources a process can use, **namespaces** control **what** a process can see and access. Namespaces provide isolation by creating separate instances of global system resources.

## What are Namespaces?

Namespaces are a Linux kernel feature that partitions kernel resources so that one set of processes sees one set of resources, while another set of processes sees a different set of resources.

**Think of it as**: Each namespace is a fully isolated instance of a particular system resource.

---

## Types of Namespaces

Linux provides seven types of namespaces:

| Namespace   | Isolates                           | Use Case                                  |
| ----------- | ---------------------------------- | ----------------------------------------- |
| **UTS**     | Hostname and domain name           | Different hostnames per container         |
| **PID**     | Process IDs                        | Isolated process trees                    |
| **Mount**   | Filesystem mount points            | Separate filesystem views                 |
| **Network** | Network interfaces, routing tables | Isolated network stacks                   |
| **IPC**     | Inter-Process Communication        | Isolated message queues, shared memory    |
| **User**    | User and group IDs                 | Map root in container to non-root on host |
| **Cgroup**  | Cgroup root directory              | Virtualize cgroup view                    |

---

## Understanding Namespace Isolation

### Example: Network Namespace

**Without namespaces (default system)**:

```
System has:
├── Routing table (one global)
├── Network interfaces (eth0, lo, etc.)
└── Firewall rules (iptables)
```

**With network namespace**:

```
Namespace 1:                    Namespace 2:
├── Own routing table          ├── Own routing table
├── Own interfaces             ├── Own interfaces
└── Own firewall rules         └── Own firewall rules
```

Each namespace has a **completely isolated** view of network resources.

---

## Creating and Using Namespaces

### The `unshare` Command

The `unshare` command creates new namespaces and optionally runs a program in them.

**Syntax**:

```bash
unshare [options] [program [arguments]]
```

### Basic Example: PID Namespace

```bash
# Create new PID namespace and run bash
sudo unshare --pid --fork --mount-proc /bin/bash

# Inside the new namespace
ps aux
# You'll only see processes in this namespace!
# PID 1 will be your bash shell

echo $$
# Shows PID 1 (in this namespace)

# Exit to return to normal namespace
exit
```

**Explanation**:

- `--pid`: Create new PID namespace
- `--fork`: Fork before executing (required for PID namespace)
- `--mount-proc`: Mount new /proc filesystem

### Network Namespace Example

```bash
# Create new network namespace
sudo unshare --net /bin/bash

# Check network interfaces
ip addr
# Only loopback (lo) exists, and it's DOWN

# The outside world still has all interfaces
```

---

## IPC (Inter-Process Communication)

IPC namespaces isolate:

- Message queues
- Semaphores
- Shared memory segments

This prevents processes in different namespaces from communicating through IPC mechanisms.

---

## Key Questions About Namespaces

### 1. How to Create a Namespace?

```bash
# Using unshare
unshare --pid --fork /bin/bash

# Using ip command (for network namespaces)
ip netns add mynetns

# Using clone() system call (programming)
# (Advanced: used by container runtimes)
```

### 2. How to Run a Process Inside a Namespace?

```bash
# With unshare
unshare --pid --net --fork /bin/bash

# With ip netns (network only)
ip netns exec mynetns /bin/bash

# With nsenter (enter existing namespace)
nsenter --target <PID> --pid --net /bin/bash
```

### 3. How Does the OS See Namespaces?

```bash
# List all namespaces
lsns

# Output shows:
# NS TYPE   NPROCS   PID USER    COMMAND
# Namespace ID, type, number of processes, etc.

# View namespaces for specific process
ls -la /proc/<PID>/ns/
```

### 4. What Can the Namespace See?

A process in a namespace sees:

- **PID namespace**: Only processes in same namespace
- **Network namespace**: Only its network interfaces
- **Mount namespace**: Only its mounted filesystems
- **UTS namespace**: Only its hostname
- **IPC namespace**: Only its IPC objects
- **User namespace**: Mapped user/group IDs

---

## Practical Example: Complete Isolation

### Creating Multiple Isolated Namespaces

```bash
# Create namespace with PID, Network, UTS, and Mount isolation
sudo unshare --pid --net --uts --mount --fork /bin/bash

# Inside the namespace:

# 1. Change hostname
hostname container1
hostname
# Shows: container1

# 2. Check processes
ps aux
# Only processes in this namespace

# 3. Check network
ip addr
# Only loopback interface

# 4. Mount new filesystem
mkdir /tmp/newroot
mount -t tmpfs tmpfs /tmp/newroot
# This mount is isolated from host
```

---

## Network Namespace Deep Dive

### Default Network Infrastructure

Every system has:

```
├── Network interfaces (eth0, lo, etc.)
├── Routing table
├── Firewall rules (iptables/nftables)
├── DNS configuration
└── Loopback interface (127.0.0.1)
```

### Creating Isolated Network Namespace

```bash
# Create network namespace
sudo ip netns add mynetns

# List namespaces
ip netns list

# Execute command in namespace
sudo ip netns exec mynetns ip addr
# Shows only loopback (down)

# Bring up loopback
sudo ip netns exec mynetns ip link set lo up
sudo ip netns exec mynetns ping 127.0.0.1
# Now works!
```

---

## Virtual Ethernet (veth) Pairs

To connect namespaces to each other or to the host, we use **veth pairs** - virtual network cables.

### Concept

```
veth0 <=========> ceth0
(host)         (namespace)
```

A veth pair acts like a virtual network cable with two ends.

### Creating and Connecting veth Pairs

```bash
# 1. Create network namespace
sudo ip netns add mynetns

# 2. Create veth pair
sudo ip link add veth0 type veth peer name ceth0

# 3. Move one end to namespace
sudo ip link set ceth0 netns mynetns

# 4. Assign IP to host end
sudo ip addr add 192.168.100.1/24 dev veth0
sudo ip link set veth0 up

# 5. Configure namespace end
sudo ip netns exec mynetns ip addr add 192.168.100.2/24 dev ceth0
sudo ip netns exec mynetns ip link set ceth0 up
sudo ip netns exec mynetns ip link set lo up

# 6. Test connectivity
sudo ip netns exec mynetns ping 192.168.100.1
# Success! Namespace can reach host
```

---

## Bridge Networking for Multiple Namespaces

### Problem

How do we connect multiple namespaces together?

```
ns1 <--?--> ns2 <--?--> ns3
```

### Solution: Linux Bridge

A bridge acts like a virtual switch connecting multiple namespaces.

```
        ┌─────────┐
        │ Bridge  │
        │  br0    │
        └────┬────┘
      ┌──────┼──────┐
      │      │      │
    ns1    ns2    ns3
```

### Creating a Bridge Network

```bash
# 1. Create bridge
sudo ip link add name br0 type bridge

# 2. Assign IP to bridge (acts as gateway)
sudo ip addr add 192.168.100.254/24 dev br0

# 3. Bring up bridge
sudo ip link set br0 up

# 4. Create namespace
sudo ip netns add ns1

# 5. Create veth pair
sudo ip link add veth-ns1 type veth peer name br-veth-ns1

# 6. Move one end to namespace
sudo ip link set br-veth-ns1 netns ns1

# 7. Connect other end to bridge
sudo ip link set veth-ns1 master br0

# 8. Bring up host end
sudo ip link set veth-ns1 up

# 9. Configure namespace end
sudo ip netns exec ns1 ip addr add 192.168.100.1/24 dev br-veth-ns1
sudo ip netns exec ns1 ip link set br-veth-ns1 up
sudo ip netns exec ns1 ip link set lo up

# 10. Add default route in namespace
sudo ip netns exec ns1 ip route add default via 192.168.100.254

# 11. Test
sudo ip netns exec ns1 ping 192.168.100.254
```

### Connecting Multiple Namespaces

Repeat steps 4-11 for ns2, ns3, etc. All will be able to communicate through the bridge!

```bash
# From ns1, ping ns2
sudo ip netns exec ns1 ping 192.168.100.2  # ns2's IP
```

---

## Default Network Namespace

**Question**: What is the default network namespace?

**Answer**: The default namespace is managed by **systemd** (PID 1). All processes start in this namespace unless explicitly moved to another.

```bash
# View systemd's namespaces
ls -la /proc/1/ns/
```

---

## Viewing All Namespaces

```bash
# List all namespaces with details
lsns

# List only network namespaces
lsns -t net

# List namespaces for a specific PID
lsns -p <PID>
```

---

## Why Namespaces Matter for Containers

When you run a container:

1. **PID namespace**: Container sees PID 1 as its main process
2. **Network namespace**: Container has its own network stack
3. **Mount namespace**: Container has its own filesystem view
4. **UTS namespace**: Container has its own hostname
5. **IPC namespace**: Container can't access host IPC
6. **User namespace**: Root in container ≠ root on host (when enabled)
7. **Cgroup namespace**: Container sees virtualized cgroup tree

**Result**: Complete isolation giving the illusion of a separate system.

---

## Legacy vs Modern Approach

### Legacy (Manual Setup)

The examples above with `ip netns`, `veth`, and `bridge` are the **manual way**. This is:

- Educational
- Complex for multiple containers
- Error-prone
- Not scalable

### Modern (Container Engines)

Container engines (Docker, Podman) handle all this automatically:

- Create namespaces
- Set up networking
- Connect containers
- Manage bridges
- Handle cleanup

---

## Key Takeaways

1. **Namespaces = Isolation**: Each namespace sees only its resources
2. **Seven Types**: PID, Network, Mount, UTS, IPC, User, Cgroup
3. **veth Pairs**: Connect namespaces like virtual network cables
4. **Bridges**: Connect multiple namespaces together
5. **Foundation**: Namespaces + CGroups = Container isolation

---

## Next Steps

Now you understand both CGroups (resource limits) and Namespaces (isolation). Next, we'll see how these combine to create containers!

Continue to: [03-container-basics.md](03-container-basics.md)
