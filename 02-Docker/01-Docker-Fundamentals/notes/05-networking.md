# Container Networking

## Overview

Container networking is how containers communicate with each other, the host system, and the outside world. Understanding container networking is crucial for building multi-container applications and troubleshooting connectivity issues.

---

## Network Infrastructure Basics

### Standard System Network Stack

Every Linux system has these network components:

```
System Network Stack
├── Network Interfaces (eth0, lo, wlan0, etc.)
├── Routing Tables (where to send packets)
├── Firewall Rules (iptables/nftables)
├── DNS Configuration (/etc/resolv.conf)
└── Loopback Interface (127.0.0.1 - lo)
```

### Viewing Network Configuration

```bash
# Show all interfaces
ip addr
# or
ifconfig

# Show routing table
ip route
# or
route -n

# Show firewall rules
sudo iptables -L -n -v
```

---

## Container Network Interfaces

### Host Interfaces with Container Engine

After installing Docker or Podman, you'll see additional interfaces:

```bash
ip addr

# Typical output:
# 1: lo        - Loopback (127.0.0.1)
# 2: ens33     - Physical network interface
# 3: docker0   - Docker bridge network (if Docker installed)
# 4: cni0      - CNI bridge (if Podman with CNI)
# 5: vethXXXX  - Virtual ethernet pairs for containers
```

**Each interface has its own IP address and subnet.**

### Interface Types

| Interface        | Type             | Purpose                         |
| ---------------- | ---------------- | ------------------------------- |
| `lo`             | Loopback         | Local communication (127.0.0.1) |
| `ens33`/`eth0`   | Physical         | Connect to external network     |
| `docker0`/`cni0` | Bridge           | Connect containers together     |
| `vethXXXX`       | Virtual Ethernet | Connect container to bridge     |

---

## Default Network Namespace

**Question**: What is the default network namespace on a system?

**Answer**: The **SystemD namespace** (PID 1).

All processes and network interfaces start in this namespace unless explicitly moved to another.

```bash
# View systemd's network namespace
sudo ls -la /proc/1/ns/net
```

---

## Port Publishing Deep Dive

### Basic Port Publishing

```bash
# Format: -p [host_ip:]host_port:container_port
podman run -d -p 9090:8080 nginx
```

**What this means**:

- Any request to port **9090** on **any interface** of the host
- Gets forwarded to port **8080** inside the container

### Request Flow

```
Client → Host Interface (any IP) → Port 9090
   ↓
iptables NAT rule
   ↓
Bridge (docker0/cni0)
   ↓
veth pair
   ↓
Container eth0 → Port 8080
```

### Binding to Specific IP

```bash
# Bind to specific host IP
podman run -d -p 192.168.233.128:9092:8080 nginx
```

**What this means**:

- Only requests to **192.168.233.128:9092** are forwarded
- Requests to other IPs on port 9092 are **not** forwarded

**Use cases**:

- Security: Only accept connections from specific interface
- Multi-homed hosts: Different services on different IPs
- Testing: Isolate container to specific network

### Viewing Port Mappings

```bash
# Show all container ports
podman port --all

# Example output:
# f1dd4ce56ad4    8080/tcp -> 0.0.0.0:9091
# 49bf7f0ea760    8080/tcp -> 0.0.0.0:9090
# 252582c61275    8080/tcp -> 192.168.233.128:9092
```

**Interpretation**:

- `0.0.0.0` means all interfaces
- Specific IP means only that interface

---

## Multiple Network Attachment

### Why Multiple Networks?

A container might need to:

1. Communicate with backend services (private network)
2. Serve public traffic (public network)
3. Access database (database network)
4. Management traffic (admin network)

### Creating and Attaching Networks

```bash
# Create custom networks
podman network create mynetwork
podman network create public
podman network create backend

# Run container attached to multiple networks
podman run -d \
  --name myhttpd \
  -p 9090:8080 \
  --network mynetwork,public \
  quay.io/fedora/httpd-24

# Attach existing container to additional network
podman network connect backend myhttpd
```

### Network Inspection

```bash
# List networks
podman network ls

# Inspect network details
podman network inspect mynetwork

# See which networks a container is on
podman inspect myhttpd | grep -A 10 Networks
```

---

## Same Port, Different Interfaces

### The Scenario

A container can have **the same port** on different network interfaces:

```
Container:
├── eth0 (192.168.1.10) → Port 80
└── eth1 (10.0.0.10)    → Port 80
```

**No conflict!** Because they're on different interfaces.

### Real-World Examples

#### Example 1: Public and Private APIs

```bash
# Create networks
podman network create public_net --subnet 192.168.1.0/24
podman network create private_net --subnet 10.0.0.0/24

# Run API server on both networks
podman run -d \
  --name api-server \
  --network public_net,private_net \
  my-api:latest

# Inside container:
# - eth0 (public_net): 192.168.1.10:8080 → Public API
# - eth1 (private_net): 10.0.0.10:8080 → Admin API
```

#### Example 2: Multi-Tenant Services

```bash
# Different customers on different networks
podman network create customer_a --subnet 172.20.0.0/24
podman network create customer_b --subnet 172.21.0.0/24

# Service listens on port 443 on both networks
podman run -d \
  --network customer_a,customer_b \
  saas-app:latest
```

---

## Network Namespaces Deep Dive

### Reviewing Namespace Basics

Each network namespace has:

```
Network Namespace
├── Own network interfaces
├── Own routing table
├── Own firewall rules
├── Own /proc/net
└── Own port space
```

### Creating Network Namespace

```bash
# Create network namespace
sudo ip netns add mynetns

# List namespaces
ip netns list

# Execute command in namespace
sudo ip netns exec mynetns ip addr
# Shows only loopback (and it's DOWN)
```

### Bringing Up Loopback

```bash
# Inside namespace, loopback is down
sudo ip netns exec mynetns ip link set lo up

# Now can ping localhost
sudo ip netns exec mynetns ping 127.0.0.1
```

---

## Virtual Ethernet (veth) Pairs

### Concept

A **veth pair** is like a virtual network cable with two ends:

```
┌──────────┐                    ┌──────────┐
│   Host   │                    │ Namespace│
│          │                    │          │
│  veth0   │◄──────────────────►│  ceth0   │
│          │   Virtual Cable    │          │
└──────────┘                    └──────────┘
```

Data sent to one end comes out the other end.

### Creating and Connecting veth Pair

```bash
# 1. Create network namespace
sudo ip netns add mynetns

# 2. Create veth pair
sudo ip link add veth0 type veth peer name ceth0

# 3. Move one end to namespace
sudo ip link set ceth0 netns mynetns

# 4. Configure host end
sudo ip addr add 192.168.100.1/24 dev veth0
sudo ip link set veth0 up

# 5. Configure namespace end
sudo ip netns exec mynetns ip addr add 192.168.100.2/24 dev ceth0
sudo ip netns exec mynetns ip link set ceth0 up
sudo ip netns exec mynetns ip link set lo up

# 6. Test connectivity
sudo ip netns exec mynetns ping 192.168.100.1
# Success!

# 7. Test from host
ping 192.168.100.2
# Success!
```

### Viewing veth Pairs

```bash
# On host
ip link show type veth

# Inside namespace
sudo ip netns exec mynetns ip link show
```

---

## Bridge Networking

### The Problem

How do we connect **multiple namespaces** together?

```
ns1 ◄─?─► ns2 ◄─?─► ns3
```

Creating veth pairs between each would be messy:

- ns1 ↔ ns2 (1 pair)
- ns1 ↔ ns3 (1 pair)
- ns2 ↔ ns3 (1 pair)

**3 namespaces = 3 pairs. 10 namespaces = 45 pairs!**

### Solution: Bridge

A **bridge** acts like a virtual switch:

```
        ┌─────────────┐
        │   Bridge    │
        │    (br0)    │
        │ 192.168.1.1 │
        └──────┬──────┘
               │
     ┌─────────┼─────────┐
     │         │         │
   ┌─┴─┐     ┌─┴─┐     ┌─┴─┐
   │ns1│     │ns2│     │ns3│
   └───┘     └───┘     └───┘
 .1.10      .1.20     .1.30
```

### Creating Bridge Network

```bash
# 1. Create bridge
sudo ip link add name br0 type bridge

# 2. Assign IP to bridge (gateway for namespaces)
sudo ip addr add 192.168.100.254/24 dev br0

# 3. Bring up bridge
sudo ip link set br0 up
```

### Connecting Namespace to Bridge

```bash
# For namespace 'ns1':

# 1. Create veth pair
sudo ip link add veth-ns1 type veth peer name br-veth-ns1

# 2. Move one end to namespace
sudo ip link set br-veth-ns1 netns ns1

# 3. Connect other end to bridge
sudo ip link set veth-ns1 master br0

# 4. Bring up host end
sudo ip link set veth-ns1 up

# 5. Configure namespace end
sudo ip netns exec ns1 ip addr add 192.168.100.1/24 dev br-veth-ns1
sudo ip netns exec ns1 ip link set br-veth-ns1 up
sudo ip netns exec ns1 ip link set lo up

# 6. Add default route (important!)
sudo ip netns exec ns1 ip route add default via 192.168.100.254

# 7. Test connectivity to bridge
sudo ip netns exec ns1 ping 192.168.100.254
```

### Connecting Multiple Namespaces

Repeat the above steps for ns2, ns3, etc., using different IPs:

```bash
# ns2: 192.168.100.2/24
# ns3: 192.168.100.3/24
# etc.
```

### Testing Inter-Namespace Communication

```bash
# From ns1, ping ns2
sudo ip netns exec ns1 ping 192.168.100.2

# Success! They can communicate through the bridge
```

---

## How Container Engines Use This

### Docker/Podman Network Setup

When you create a container, the engine:

```bash
# 1. Creates network namespace for container
# 2. Creates veth pair
# 3. Connects one end to bridge (docker0/cni0)
# 4. Moves other end to container namespace
# 5. Assigns IP to container
# 6. Sets up NAT rules for port publishing
# 7. Configures DNS
```

**All of this happens automatically!**

### Viewing Container Network

```bash
# Run container
podman run -d --name web nginx

# Find container's network namespace
podman inspect web | grep -i sandbox

# View container's network from host
podman exec web ip addr
```

---

## Container Network Modes

### 1. Bridge (Default)

Container connects to bridge network with its own IP.

```bash
podman run -d --network bridge nginx
```

### 2. Host

Container uses host's network namespace (no isolation).

```bash
podman run -d --network host nginx
```

**Use case**: Maximum performance, but less isolation.

### 3. None

No network interfaces (except loopback).

```bash
podman run -d --network none alpine
```

**Use case**: Completely isolated, manual network setup.

### 4. Container

Share another container's network namespace.

```bash
podman run -d --name web1 nginx
podman run -d --network container:web1 app
```

**Use case**: Sidecar pattern, localhost communication.

---

## DNS in Containers

### Container DNS Resolution

Containers get DNS configuration automatically:

```bash
# Inside container
cat /etc/resolv.conf

# Shows nameserver (usually bridge IP or custom DNS)
```

### Custom DNS

```bash
# Set custom DNS servers
podman run -d --dns 8.8.8.8 --dns 8.8.4.4 nginx

# Verify inside container
podman exec nginx cat /etc/resolv.conf
```

---

## Network Troubleshooting

### Common Commands

```bash
# Check container IP
podman inspect -f '{{.NetworkSettings.IPAddress}}' container_name

# Test connectivity from container
podman exec container_name ping google.com

# Check port mappings
podman port container_name

# View network details
podman network inspect bridge

# Test from host to container
curl http://$(podman inspect -f '{{.NetworkSettings.IPAddress}}' web)
```

### Common Issues

| Issue                            | Likely Cause       | Solution                                     |
| -------------------------------- | ------------------ | -------------------------------------------- |
| Can't access container from host | Port not published | Add `-p` flag                                |
| Containers can't talk            | Different networks | Use same network or link                     |
| No internet in container         | DNS issue          | Check `--dns` or `/etc/resolv.conf`          |
| Port already in use              | Conflict           | Change host port or stop conflicting service |

---

## Advanced Networking Concepts

### Network Namespaces vs Containers

**Every container** gets:

- Network namespace
- PID namespace
- Mount namespace
- UTS namespace
- IPC namespace
- (optionally) User namespace

The network namespace provides the network isolation.

### Inspecting Namespaces

```bash
# List all namespaces
lsns

# Filter for network namespaces
lsns -t net

# View container's namespaces
ls -la /proc/<container_pid>/ns/
```

---

## Best Practices

### 1. Use Custom Networks

```bash
# ❌ Don't rely on default bridge
podman run -d nginx

# ✅ Create custom network
podman network create myapp-net
podman run -d --network myapp-net nginx
```

### 2. Name Resolution

```bash
# Containers on same custom network can resolve by name
podman network create app-net
podman run -d --name database --network app-net postgres
podman run -d --name webapp --network app-net myapp

# Inside webapp:
# curl http://database:5432  ← Works!
```

### 3. Network Segmentation

```bash
# Frontend network
podman network create frontend

# Backend network
podman network create backend

# Web server: both networks
podman run -d --network frontend,backend webserver

# App server: backend only
podman run -d --network backend appserver

# Database: backend only
podman run -d --network backend database
```

---

## Key Takeaways

1. **Network namespaces** provide complete network isolation
2. **veth pairs** connect namespaces (like virtual cables)
3. **Bridges** connect multiple namespaces (like virtual switches)
4. **Port publishing** forwards host ports to container ports
5. Containers can attach to **multiple networks**
6. Container engines automate all network setup
7. Custom networks provide **name resolution** between containers

---

## Next Steps

Understanding networking is crucial, but we also need to understand how container images are built and stored. Let's explore the **image layer system** and **OverlayFS**.

Continue to: [06-images-layers.md](06-images-layers.md)
