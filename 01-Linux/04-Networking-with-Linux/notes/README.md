Networking :
basics are essential for DevOps engineers because they provide a foundational understanding of how different components of a system communicate. This knowledge is crucial for troubleshooting issues, securing the infrastructure, implementing automation, and optimizing performance. DevOps involves collaboration between development and operations, and a grasp of networking principles enables effective communication and coordination across distributed applications.

Networking concepts should know:
OSI Model
Protocols : TCP/UDP/IP
Ports
Subnetting
Routing
DNS
VPN (Virtual Private Network)
Networking tools

1.OSI Model :

The OSI (Open Systems Interconnection) model is a conceptual framework used to understand and implement network protocols in seven layers. Each layer serves a specific function and communicates with the layers directly above and below it. The seven layers are:

1. Physical Layer : Handles the physical connection between devices, including cables, switches, and other hardware.
2. Data Link Layer : Manages data transfer between devices on the same network, including MAC addressing and error detection.
3. Network Layer : Responsible for routing, forwarding, and addressing packets across different networks.
4. Transport Layer : Ensures reliable data transfer between devices, including error recovery and flow control.
5. Session Layer : Manages sessions or connections between applications.
6. Presentation Layer : Translates data between the application layer and the network, including encryption and compression.
7. Application Layer : Provides network services directly to end-user applications.

Osi model is great understanding of network but it is very challenging to use in practice. this is why we using TCP/IP model :
2.TCP/IP Model :
The TCP/IP (Transmission Control Protocol/Internet Protocol) model is a more practical framework used for networking that consists of four layers. It is the foundation of the internet and most modern networks. The four layers are:

1. Network Interface Layer : Corresponds to the OSI's Physical and Data Link layers, handling the physical connection and data transfer between devices on the same network.

2. Internet Layer : Corresponds to the OSI's Network layer, responsible for routing and addressing packets across different networks using IP (Internet Protocol).

3. Transport Layer : Corresponds to the OSI's Transport layer, ensuring reliable data transfer between devices using protocols like TCP (Transmission Control Protocol) and UDP (User Datagram Protocol).

4. Application Layer : Corresponds to the OSI's Session, Presentation, and Application layers, providing network services directly to end-user applications using protocols like HTTP, FTP, SMTP, and DNS.

2.Protocols : TCP/UDP/IP

- TCP (Transmission Control Protocol):

        Description: TCP operates at the transport layer of the OSI model. It establishes a connection between two devices before data exchange, ensuring reliable and ordered delivery of information.

        Functionality: It breaks data into packets, assigns sequence numbers, and uses acknowledgment messages to guarantee delivery. It’s connection-oriented, meaning it sets up, maintains, and terminates a connection for data exchange

- UDP (User Datagram Protocol):

        Description: Also operating at the transport layer, UDP is a connectionless protocol that offers minimal services. It’s like a ‘fire and forget’ approach for data transmission

        Functionality: It sends packets called datagrams without establishing a connection, which means there’s no guarantee of delivery, order, or error checking. It’s faster and more efficient for applications that can tolerate some data loss, such as video streaming or online gaming.

- IP (Internet Protocol):

            Description: IP operates at the network layer of the OSI model. It’s responsible for addressing and routing packets of data so they can travel across networks and reach the correct destination.

            Functionality: IP assigns unique addresses (IP addresses) to devices on a network and uses these addresses to route packets from the source to the destination. It works in conjunction with other protocols, like TCP and UDP, to facilitate data transmission.

  3.Ports :

            Ports are essential for directing network traffic to specific applications or services on devices. They act as communication endpoints, allowing multiple services to run simultaneously on a single device without interference. Each port is identified by a number ranging from 0 to 65535, divided into three categories

            - Well-Known Ports (0-1023): These ports are reserved for common services and protocols, such as HTTP (port 80), HTTPS (port 443), FTP (port 21), and SSH (port 22).
            - Registered Ports (1024-49151): These ports are assigned to specific applications or services
            - Dynamic/Private Ports (49152-65535): These ports are used for temporary or private connections, often assigned dynamically by the operating system for client-side communication.

  4.Subnetting :

          Subnetting is the process of dividing a larger network into smaller, more manageable subnetworks, or subnets. It improves network performance and security by reducing broadcast traffic and isolating segments of the network. Subnetting involves borrowing bits from the host portion of an IP address to create additional network addresses.
