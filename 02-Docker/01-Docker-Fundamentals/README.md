# Containers From Scratch

A comprehensive guide to understanding containers from the ground up, covering Linux kernel fundamentals, container technologies, and practical implementations.

## 📚 Overview

This repository contains detailed notes and explanations about container technology, starting from Linux kernel primitives (cgroups, namespaces) and building up to modern container engines like Docker and Podman. The content is designed for DevOps engineers, system administrators, and anyone interested in understanding how containers really work.

## 🎯 Purpose

- **Deep Understanding**: Go beyond surface-level knowledge to understand container internals
- **Interview Preparation**: Comprehensive coverage of topics commonly asked in DevOps interviews
- **Practical Reference**: Real-world examples and commands you can use immediately
- **Progressive Learning**: Structured path from fundamentals to advanced topics

## 📖 Table of Contents

### 1. [Fundamentals](notes/01-fundamentals.md)

- Control mechanisms in Linux
- Resource control, access control, and capabilities
- **CGroups (Control Groups)**
  - Controllers (CPU, memory, network, disk)
  - Hierarchy and resource allocation
  - CPU shares and quotas
  - Manual, semi-automated, and systemd management

### 2. [Namespaces](notes/02-namespaces.md)

- Process isolation fundamentals
- Types of namespaces (UTS, User, Mount, Cgroup, PID, Network, IPC)
- Creating and managing namespaces with `unshare`
- Network namespace deep dive
- Virtual ethernet pairs (veth)
- Bridge networking

### 3. [Container Basics](notes/03-container-basics.md)

- Evolution from VMs to containers
- How namespaces + cgroups = containers
- Container architecture and isolation
- User mode vs kernel mode
- Seccomp profiles

### 4. [Podman & Docker](notes/04-podman-docker.md)

- Container engines comparison
- Podman basics and commands
- Container lifecycle operations
- Port mapping and networking
- File sharing with containers
- Pause vs Stop operations

### 5. [Container Networking](notes/05-networking.md)

- Container network models
- Port mapping and publishing
- Multiple network attachment
- Network namespaces in practice
- Bridge networking configuration
- Interface management

### 6. [Images & Layers](notes/06-images-layers.md)

- Container image architecture
- Layer system and OverlayFS
- LowerDir, UpperDir, and WorkDir
- Image optimization strategies
- Universal Base Images (UBI)
- Multi-stage builds concepts

### 7. [Image Registries](notes/07-registries.md)

- Registry architecture
- Popular solutions (Harbor, Quay.io, Docker Hub, Nexus)
- Setting up a private registry
- Authentication and SSL/TLS
- Image distribution workflow

### 8. [Advanced Topics](notes/08-advanced-topics.md)

- Container tools ecosystem (buildah, skopeo, runc, crun, cri-o)
- OCI (Open Container Initiative) compliance
- Container runtimes
- Containerd architecture
- Best practices and security considerations

## 🚀 Recommended Study Order

1. **Start with Fundamentals** - Understand Linux kernel features (cgroups, namespaces)
2. **Learn Namespace Isolation** - See how processes are isolated
3. **Grasp Container Concepts** - Connect cgroups + namespaces to containers
4. **Practice with Podman/Docker** - Hands-on container operations
5. **Master Networking** - Understanding container connectivity
6. **Deep Dive into Images** - Learn about layers and filesystems
7. **Explore Registries** - Image distribution and storage
8. **Advanced Topics** - OCI standards, runtimes, and ecosystem tools

## 💡 How to Use These Notes

- **For Learning**: Follow the recommended order above
- **For Review**: Jump to specific topics using the table of contents
- **For Interviews**: Focus on fundamentals, namespaces, and architecture sections
- **For Practice**: Try all commands in the examples sections

## 🛠️ Prerequisites

- Basic Linux command-line knowledge
- Understanding of networking fundamentals
- Access to a Linux system (physical or virtual)
- Root/sudo privileges for hands-on practice

## 📝 Notes Style

- **Concepts First**: Understanding before implementation
- **Practical Examples**: Real commands you can run
- **Visual Aids**: ASCII diagrams where helpful
- **Progressive Complexity**: Building knowledge step-by-step

## 🤝 Contributing

These notes are meant to be living documents. If you find errors, have suggestions, or want to add content:

- Open an issue
- Submit a pull request
- Share your feedback

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Podman Documentation](https://docs.podman.io/)
- [OCI Specifications](https://opencontainers.org/)
- [Linux Namespaces Man Pages](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [Cgroups Documentation](https://www.kernel.org/doc/Documentation/cgroup-v2.txt)

---

**Last Updated**: December 2024  
**Maintained by**: DevOps Learning Community
