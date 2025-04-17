import 'package:flutter/material.dart';

class TutorialStep {
  final String title;
  final String description;
  final String? targetElementId;
  final bool dismissible;
  final List<String>? imagePaths;

  TutorialStep({
    required this.title,
    required this.description,
    this.targetElementId,
    this.dismissible = true,
    this.imagePaths,
  });
}

class Tutorial {
  final String id;
  final String name;
  final String description;
  final List<TutorialStep> steps;
  final String category;

  Tutorial({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.category,
  });
}

class TutorialProvider extends ChangeNotifier {
  bool _tutorialMode = false;
  bool _tutorialCompleted = false;
  int _currentStepIndex = 0;
  Tutorial? _currentTutorial;
  final Map<String, bool> _completedTutorials = {};

  bool get tutorialMode => _tutorialMode;
  bool get tutorialCompleted => _tutorialCompleted;
  int get currentStepIndex => _currentStepIndex;
  Tutorial? get currentTutorial => _currentTutorial;
  TutorialStep? get currentStep => _currentTutorial != null &&
          _currentStepIndex < _currentTutorial!.steps.length
      ? _currentTutorial!.steps[_currentStepIndex]
      : null;

  final List<Tutorial> _availableTutorials = [
    // Topology Tutorials
    Tutorial(
      id: 'star_topology',
      name: 'Star Topology',
      description: 'Learn about star network topology and how it works',
      category: 'topologies',
      steps: [
        TutorialStep(
          title: 'Star Topology Overview',
          description:
              'A star topology is a network where all nodes connect to a central hub or switch. This central device acts as a conduit to transmit messages.',
          imagePaths: ['assets/tutorials/star_topology.png'],
        ),
        TutorialStep(
          title: 'Advantages',
          description:
              'Star topologies are easy to set up, manage, and troubleshoot. If one connection fails, only that specific node is affected while the rest of the network remains operational.',
        ),
        TutorialStep(
          title: 'Disadvantages',
          description:
              'The central node is a single point of failure. If the central hub fails, the entire network becomes unusable.',
        ),
        TutorialStep(
          title: 'Try It Out',
          description:
              'Click on two nodes and use the ping tool to see how traffic flows through the central hub in a star topology.',
          targetElementId: 'ping_button',
        ),
      ],
    ),

    Tutorial(
      id: 'mesh_topology',
      name: 'Mesh Topology',
      description: 'Understand mesh network topology configurations',
      category: 'topologies',
      steps: [
        TutorialStep(
          title: 'Mesh Topology Overview',
          description:
              'A mesh topology connects devices directly to as many other devices as possible. This creates multiple paths for data to travel.',
          imagePaths: ['assets/tutorials/mesh_topology.png'],
        ),
        TutorialStep(
          title: 'Full vs Partial Mesh',
          description:
              'In a full mesh, every device connects directly to every other device. In a partial mesh, only some devices connect to each other.',
        ),
        TutorialStep(
          title: 'Advantages',
          description:
              'Mesh networks offer redundancy and fault tolerance. If one path fails, data can be routed through alternative paths.',
        ),
        TutorialStep(
          title: 'Disadvantages',
          description:
              'Full mesh networks are complex and expensive to implement as the number of connections grows exponentially with each device added.',
        ),
      ],
    ),

    Tutorial(
      id: 'tree_topology',
      name: 'Tree Topology',
      description: 'Learn about hierarchical network topology',
      category: 'topologies',
      steps: [
        TutorialStep(
          title: 'Tree Topology Overview',
          description:
              'A tree topology is a hierarchical structure where nodes are arranged in a tree-like pattern. It combines characteristics of star and bus topologies.',
          imagePaths: ['assets/tutorials/tree_topology.png'],
        ),
        TutorialStep(
          title: 'Structure',
          description:
              'The network starts with a root node (usually a switch or hub) that branches out to other nodes. Each branch can have its own sub-branches, creating a hierarchical structure.',
        ),
        TutorialStep(
          title: 'Advantages',
          description:
              'Tree topologies are scalable and easy to expand. They provide good fault isolation and are suitable for large networks.',
        ),
        TutorialStep(
          title: 'Disadvantages',
          description:
              'The entire network depends on the root node. If it fails, the entire network becomes unusable. Also, the network becomes more complex as it grows.',
        ),
        TutorialStep(
          title: 'Try It Out',
          description:
              'Create a tree topology and observe how data flows through the hierarchical structure. Notice how traffic is routed through parent nodes to reach different branches.',
          targetElementId: 'topology_builder',
        ),
      ],
    ),

    Tutorial(
      id: 'ring_topology',
      name: 'Ring Topology',
      description: 'Explore circular network connections and their benefits',
      category: 'topologies',
      steps: [
        TutorialStep(
          title: 'Ring Topology Overview',
          description:
              'A ring topology connects each device to exactly two other devices, forming a single continuous pathway for signals. Data travels from one device to another until it reaches its destination.',
          imagePaths: ['assets/tutorials/ring_topology.png'],
        ),
        TutorialStep(
          title: 'Data Flow in Ring Networks',
          description:
              'Data in a ring network travels in one direction (unidirectional) or both directions (bidirectional). In a unidirectional ring, data packets must pass through every node between the source and destination. In bidirectional rings, data can take the shortest path in either direction.',
        ),
        TutorialStep(
          title: 'Advantages',
          description:
              'Ring topologies provide equal access for all devices, handle high-volume traffic well, and offer built-in redundancy when implemented as bidirectional rings. They also eliminate the need for a central hub, removing this single point of failure.',
        ),
        TutorialStep(
          title: 'Disadvantages',
          description:
              'If any single device or connection fails in a unidirectional ring, the entire network can be disrupted. Adding or removing devices requires taking down the network temporarily. Ring networks can also become slower with more nodes as data must pass through each device.',
        ),
        TutorialStep(
          title: 'Real-world Applications',
          description:
              'Ring topologies are used in metropolitan area networks (MANs), SONET (Synchronous Optical Network) architectures, and some industrial automation systems where reliable communication is essential.',
        ),
      ],
    ),

    // Network Concepts Tutorials
    Tutorial(
      id: 'routing_basics',
      name: 'Routing Basics',
      description: 'Learn fundamental concepts about network routing',
      category: 'concepts',
      steps: [
        TutorialStep(
          title: 'What is Routing?',
          description:
              'Routing is the process of selecting paths in a network along which to send data. Routers use routing tables to determine the best path for packets.',
        ),
        TutorialStep(
          title: 'Routing Tables',
          description:
              'A routing table contains information about network destinations, associated metrics, and next hops. It helps the router decide where to forward packets.',
        ),
        TutorialStep(
          title: 'Path Selection',
          description:
              'When you ping between two hosts, the router uses algorithms to determine the shortest or most efficient path for your data packets.',
        ),
        TutorialStep(
          title: 'Try It Yourself',
          description:
              'Select two distant nodes and observe how the simulator calculates the shortest path between them.',
          targetElementId: 'ping_visualization',
        ),
      ],
    ),

    Tutorial(
      id: 'subnetting',
      name: 'Subnetting',
      description: 'Master IP addressing and subnet calculations',
      category: 'concepts',
      steps: [
        TutorialStep(
          title: 'What is Subnetting?',
          description:
              'Subnetting is the process of dividing a network into smaller logical sub-networks called subnets. It allows for more efficient use of IP addresses and improves network performance and security.',
        ),
        TutorialStep(
          title: 'IP Address Classes',
          description:
              'Traditional IPv4 addresses are divided into classes A, B, and C for public addressing. Class A networks have 8 network bits, Class B has 16, and Class C has 24. Modern networks use Classless Inter-Domain Routing (CIDR) which provides more flexibility than the class system.',
        ),
        TutorialStep(
          title: 'Subnet Masks',
          description:
              'A subnet mask is a 32-bit number that divides an IP address into network and host portions. For example, 255.255.255.0 (or /24 in CIDR notation) indicates that the first 24 bits identify the network, while the remaining 8 bits identify hosts within that network.',
          imagePaths: ['assets/tutorials/subnet_mask.png'],
        ),
        TutorialStep(
          title: 'Calculating Subnet Information',
          description:
              'To calculate subnet information, you need to determine: network address (first address), broadcast address (last address), valid host range, and number of hosts. Each subnet bit added doubles the number of subnets while halving the number of hosts per subnet.',
        ),
        TutorialStep(
          title: 'Benefits of Subnetting',
          description:
              'Subnetting improves network security by isolating network segments, reduces network traffic by containing broadcasts within smaller domains, and makes networks more manageable by creating logical groupings based on function, location, or organizational structure.',
        ),
      ],
    ),

    Tutorial(
      id: 'switching_basics',
      name: 'Network Switching',
      description: 'Understand how switches operate in networks',
      category: 'concepts',
      steps: [
        TutorialStep(
          title: 'What is a Network Switch?',
          description:
              'A network switch is a device that connects multiple devices on a local area network (LAN) and uses MAC addresses to forward data packets to their intended destinations. Unlike hubs, switches send data only to the specific device that needs it.',
        ),
        TutorialStep(
          title: 'How Switches Work',
          description:
              'Switches maintain a MAC address table that maps physical ports to the MAC addresses of connected devices. When a frame arrives, the switch checks the destination MAC address against its table and forwards the frame only to the appropriate port.',
          imagePaths: ['assets/tutorials/switch.png'],
        ),
        TutorialStep(
          title: 'Types of Switching',
          description:
              'There are three main types of switching: cut-through (fastest but no error checking), store-and-forward (complete error checking), and fragment-free (middle ground that checks for frame size errors only).',
        ),
        TutorialStep(
          title: 'VLANs',
          description:
              'Virtual LANs (VLANs) are logical groupings of network devices that allow switches to create multiple separate networks on a single physical switch. VLANs improve security and performance by isolating broadcast domains.',
        ),
        TutorialStep(
          title: 'Multilayer Switching',
          description:
              'Modern switches often incorporate Layer 3 (routing) functionality, allowing them to make forwarding decisions based on IP addresses as well as MAC addresses. This eliminates the need for separate routers in some network designs.',
        ),
      ],
    ),

    // Protocol Tutorials
    Tutorial(
      id: 'tcp_ip',
      name: 'TCP/IP Protocol Suite',
      description: 'Explore the fundamental protocols that power the internet',
      category: 'protocols',
      steps: [
        TutorialStep(
          title: 'The TCP/IP Model',
          description:
              'The TCP/IP model is a conceptual framework consisting of four layers: Network Interface, Internet, Transport, and Application. Each layer has specific protocols that handle different aspects of network communication.',
          imagePaths: ['assets/tutorials/tcp_ip_model.png'],
        ),
        TutorialStep(
          title: 'IP (Internet Protocol)',
          description:
              'IP is responsible for routing packets across networks using logical addressing. IPv4 uses 32-bit addresses while IPv6 uses 128-bit addresses. IP provides best-effort delivery without guarantees of packet arrival or ordering.',
        ),
        TutorialStep(
          title: 'TCP (Transmission Control Protocol)',
          description:
              'TCP is a connection-oriented protocol that ensures reliable, ordered, and error-checked delivery of data. It establishes connections through a three-way handshake, manages flow control, and includes mechanisms for congestion control.',
        ),
        TutorialStep(
          title: 'UDP (User Datagram Protocol)',
          description:
              'UDP is a connectionless protocol that offers fast delivery without the overhead of establishing connections or guaranteeing delivery. It is used for applications where speed is more important than reliability, such as live streaming or online gaming.',
        ),
        TutorialStep(
          title: 'Common Application Protocols',
          description:
              'The TCP/IP suite includes many application protocols such as HTTP(S) for web browsing, SMTP/POP3/IMAP for email, DNS for domain name resolution, FTP for file transfers, and DHCP for automatic IP configuration.',
        ),
      ],
    ),

    Tutorial(
      id: 'ospf_protocol',
      name: 'OSPF Routing Protocol',
      description: 'Learn how networks determine optimal routes dynamically',
      category: 'protocols',
      steps: [
        TutorialStep(
          title: 'What is OSPF?',
          description:
              'Open Shortest Path First (OSPF) is a link-state routing protocol used within large enterprise networks. It allows routers to build a map of the network topology and calculate the shortest path to each network.',
        ),
        TutorialStep(
          title: 'How OSPF Works',
          description:
              'OSPF routers build a link-state database by exchanging LSAs (Link State Advertisements). They then use Dijkstra algorithm to calculate the best route to each destination based on cumulative path cost.',
          imagePaths: ['assets/tutorials/ospf_network.png'],
        ),
        TutorialStep(
          title: 'OSPF Areas',
          description:
              'OSPF uses a hierarchical design with areas to improve scalability. Area 0 (backbone area) connects all other areas. This hierarchical structure reduces the processing and memory requirements of routers by limiting the scope of route advertisements.',
        ),
        TutorialStep(
          title: 'OSPF Router Types',
          description:
              'OSPF defines several router types including Internal Routers (within a single area), Area Border Routers (connecting multiple areas), Backbone Routers (with interfaces in Area 0), and Autonomous System Boundary Routers (connecting to other routing protocols).',
        ),
        TutorialStep(
          title: 'Advantages Over Other Protocols',
          description:
              'OSPF converges quickly after network changes, supports VLSM (Variable Length Subnet Masking), uses bandwidth-efficient updates, and scales well for large networks. It is vendor-neutral and widely supported across network equipment.',
        ),
      ],
    ),

    Tutorial(
      id: 'dhcp_protocol',
      name: 'DHCP Protocol',
      description: 'Understand automatic IP address configuration',
      category: 'protocols',
      steps: [
        TutorialStep(
          title: 'What is DHCP?',
          description:
              'Dynamic Host Configuration Protocol (DHCP) automatically assigns IP addresses and other network configuration parameters to devices on a network. This eliminates the need for manual IP configuration.',
        ),
        TutorialStep(
          title: 'The DHCP Process',
          description:
              'DHCP uses a four-step process known as DORA: Discover (client broadcasts a request), Offer (server responds with an available IP), Request (client requests the offered IP), and Acknowledge (server confirms the assignment).',
          imagePaths: ['assets/tutorials/dhcp_process.png'],
        ),
        TutorialStep(
          title: 'DHCP Lease Time',
          description:
              'IP addresses are assigned for a specific period called a lease. Before the lease expires, the client must renew it to keep using the same IP. This allows for efficient reuse of IP addresses in networks where devices connect and disconnect regularly.',
        ),
        TutorialStep(
          title: 'DHCP Options',
          description:
              'Besides IP addresses, DHCP can provide many other configuration parameters including subnet mask, default gateway, DNS servers, NTP servers, and more. These options are communicated through specific option codes in DHCP messages.',
        ),
        TutorialStep(
          title: 'DHCP Relay',
          description:
              'In larger networks with multiple subnets, DHCP relay agents forward requests between subnets, allowing a central DHCP server to service multiple network segments without requiring a server on each subnet.',
        ),
      ],
    ),
  ];

  List<Tutorial> getAvailableTutorials() {
    return _availableTutorials;
  }

  List<Tutorial> getTutorialsByCategory(String category) {
    return _availableTutorials
        .where((tutorial) => tutorial.category == category)
        .toList();
  }

  void startTutorial(String tutorialId) {
    final tutorial = _availableTutorials.firstWhere(
      (tutorial) => tutorial.id == tutorialId,
      orElse: () => throw Exception('Tutorial not found: $tutorialId'),
    );

    _currentTutorial = tutorial;
    _currentStepIndex = 0;
    _tutorialMode = true;
    _tutorialCompleted = false;
    notifyListeners();
  }

  void nextStep() {
    if (_currentTutorial == null) return;

    if (_currentStepIndex < _currentTutorial!.steps.length - 1) {
      _currentStepIndex++;
      notifyListeners();
    } else {
      completeTutorial();
    }
  }

  void previousStep() {
    if (_currentTutorial == null) return;

    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      notifyListeners();
    }
  }

  void completeTutorial() {
    if (_currentTutorial != null) {
      _completedTutorials[_currentTutorial!.id] = true;
    }
    _tutorialCompleted = true;
    _tutorialMode = false;
    notifyListeners();
  }

  void dismissTutorial() {
    _tutorialMode = false;
    _currentTutorial = null;
    _currentStepIndex = 0;
    notifyListeners();
  }

  bool isTutorialCompleted(String tutorialId) {
    return _completedTutorials[tutorialId] ?? false;
  }
}
