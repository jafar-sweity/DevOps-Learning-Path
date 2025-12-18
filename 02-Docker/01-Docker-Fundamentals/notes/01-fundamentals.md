# Linux Fundamentals for Containers

## Overview

Containers are built on fundamental Linux kernel features. Before diving into containers themselves, we need to understand the three core control mechanisms that make containers possible.

## The Three Pillars of Container Technology

### 1. Resource Control

Controls **how much** of a resource a process can use

- CPU time
- Memory allocation
- Network bandwidth
- Disk I/O

### 2. Access Control

Controls **what type** of resources a process can access

- File systems
- Network interfaces
- Devices
- Inter-process communication

### 3. Capabilities

Controls **what privileges** a process has

- System calls
- Security operations
- Administrative tasks

## Solutions

| Problem            | Solution            | Purpose                          |
| ------------------ | ------------------- | -------------------------------- |
| Resource Control   | **CGroups**         | Limit and monitor resource usage |
| Access Control     | **Namespaces**      | Isolate process view of system   |
| Capabilities       | **SELinux/Seccomp** | Fine-grained privilege control   |
| Complete Isolation | **Sandboxing**      | Combine all above mechanisms     |

---

## CGroups (Control Groups)

### What are CGroups?

Control Groups are a Linux kernel feature that limits, accounts for, and isolates resource usage (CPU, memory, disk I/O, network) of process groups.

### Key Concept

CGroups enable **resource control** at the process group level, not just individual processes.

### Controllers

CGroups work through different controllers, each managing a specific resource:

```
┌─────────────────────────────────────┐
│         CGroup Controllers          │
├─────────────┬───────────────────────┤
│    CPU      │   CPU time allocation │
│   Memory    │   RAM limits          │
│   Network   │   Bandwidth limits    │
│    Disk     │   I/O throttling      │
│   Freezer   │   Pause processes     │
└─────────────┴───────────────────────┘
```

---

## CGroup Hierarchy

CGroups are organized in a **tree structure** (hierarchy):

```
                    root
                     |
        ┌────────────┼────────────┐
        │            │            │
    mygroup      entapp    customgroup
    (5% CPU)   (50% CPU)   (45% CPU)
        │
    ┌───┴───┐
process1  process2
```

### CPU Shares Example

If your CPU runs at full speed (3 GHz), you can allocate:

- `mygroup`: 5% = 150 MHz
- `entapp`: 50% = 1.5 GHz
- `customgroup`: 45% = 1.35 GHz

**Note**: These are relative shares. If `entapp` is idle, other groups can use its allocation.

---

## CGroup Location in Filesystem

CGroups are managed through a special filesystem:

```bash
/sys/fs/cgroup/
```

This virtual filesystem allows you to:

- View current cgroup assignments
- See resource usage statistics
- Modify cgroup parameters
- Create new cgroups

### Viewing CGroups

```bash
# List all cgroups
ls -la /sys/fs/cgroup/

# View CPU cgroup
ls /sys/fs/cgroup/cpu/

# View memory cgroup
ls /sys/fs/cgroup/memory/
```

---

## Managing CGroups: Three Approaches

### 1. Manual (Not Recommended)

Directly manipulating cgroup files in `/sys/fs/cgroup/`.

**Drawbacks**:

- Error-prone
- Not persistent across reboots
- Difficult to maintain
- No validation

### 2. Semi-Automated

Using tools like `cgcreate`, `cgset`, `cgexec`:

```bash
# Create a cgroup
cgcreate -g cpu,memory:/mygroup

# Set limits
cgset -r cpu.shares=512 mygroup
cgset -r memory.limit_in_bytes=1G mygroup

# Run process in cgroup
cgexec -g cpu,memory:/mygroup /path/to/process
```

### 3. Systemd (Recommended)

Modern Linux distributions use systemd to manage cgroups automatically.

```bash
# Create a service with resource limits
systemctl set-property myservice.service CPUShares=512
systemctl set-property myservice.service MemoryLimit=1G

# View cgroup for a service
systemctl status myservice.service
```

---

## Practical Example: CPU Throttling

### The Command

```bash
dd if=/dev/zero of=/dev/null
```

This command consumes 100% of one CPU core by continuously reading and writing data.

### Without CGroup

```bash
# Run the command
dd if=/dev/zero of=/dev/null &

# Check CPU usage
top
# You'll see ~100% CPU usage for dd process
```

### With CGroup Limits

#### Understanding Period and Quota

- **period**: The time interval for CPU allocation (microseconds)
- **quota**: Maximum CPU time allowed within that period (microseconds)

**Formula**: CPU usage = (quota / period) × 100%

**Example**:

- period = 100,000 μs (100 ms)
- quota = 50,000 μs (50 ms)
- Result = 50% CPU usage

#### Creating a Limited CGroup

```bash
# Create a new cgroup for CPU control
sudo mkdir -p /sys/fs/cgroup/cpu/limited_group

# Set period to 100ms (100,000 microseconds)
echo 100000 | sudo tee /sys/fs/cgroup/cpu/limited_group/cpu.cfs_period_us

# Set quota to 50ms (50% of one core)
echo 50000 | sudo tee /sys/fs/cgroup/cpu/limited_group/cpu.cfs_quota_us

# Run dd in this cgroup
sudo cgexec -g cpu:/limited_group dd if=/dev/zero of=/dev/null &

# Check CPU usage - now limited to ~50%
top
```

### Moving Existing Process to CGroup

```bash
# Find process ID
pidof dd

# Move to cgroup
echo <PID> | sudo tee /sys/fs/cgroup/cpu/limited_group/cgroup.procs
```

---

## Key Concepts Summary

### CGroup Parameters

| Parameter               | Description                 | Example                |
| ----------------------- | --------------------------- | ---------------------- |
| `cpu.shares`            | Relative CPU weight         | 1024 = normal priority |
| `cpu.cfs_period_us`     | Time period in microseconds | 100000 = 100ms         |
| `cpu.cfs_quota_us`      | CPU time quota in period    | 50000 = 50% CPU        |
| `memory.limit_in_bytes` | Maximum memory              | 1073741824 = 1GB       |
| `blkio.weight`          | Relative I/O weight         | 500 = half priority    |

### Important Notes

1. **Hierarchy Matters**: Child cgroups inherit limits from parents
2. **Relative Shares**: CPU shares are relative, not absolute
3. **Hard Limits**: Memory limits are hard (process killed if exceeded)
4. **Soft Limits**: CPU limits are soft (can burst if available)

---

## Best Practices

1. **Use systemd**: Let systemd manage cgroups when possible
2. **Monitor First**: Observe resource usage before setting limits
3. **Set Realistic Limits**: Don't over-constrain processes
4. **Test Thoroughly**: Verify limits work as expected
5. **Document Everything**: Keep track of why limits were set

---

## Next Steps

Now that you understand resource control with CGroups, the next step is learning about **Namespaces** for process isolation. Together, CGroups + Namespaces form the foundation of containers.

Continue to: [02-namespaces.md](02-namespaces.md)
