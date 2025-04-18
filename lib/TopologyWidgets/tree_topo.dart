import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/Provider/ping_provider.dart';
import 'package:network_simulator/Widgets/ping_visualization.dart';
import 'package:provider/provider.dart';

class TreeTopology extends StatefulWidget {
  final Map<String, dynamic> mininetResponse;

  const TreeTopology({super.key, required this.mininetResponse});

  @override
  _TreeTopologyState createState() => _TreeTopologyState();
}

class _TreeTopologyState extends State<TreeTopology> {
  final Graph graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  late TransformationController transformationController;
  final List<Future> _animationFutures = [];

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustGraphScale());
    _buildGraph();
  }

  @override
  void didUpdateWidget(TreeTopology oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mininetResponse != widget.mininetResponse) {
      _clearGraph();
      _buildGraph();
      if (widget.mininetResponse['type'] == 'path_data') {
        log('Received path data: ${widget.mininetResponse.toString()}');
        context.read<PingProvider>().updatePingData(widget.mininetResponse);

        // Show SnackBar with path information
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Shortest path found: ${widget.mininetResponse['path'].join(' → ')}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _clearGraph() {
    graph.nodes.clear();
    graph.edges.clear();
    _animationFutures.clear();
  }

  @override
  void dispose() {
    for (var future in _animationFutures) {
      future.ignore();
    }
    super.dispose();
  }

  void _adjustGraphScale() {
    Size screenSize = MediaQuery.of(context).size;
    double scaleX = screenSize.width / 1000;
    double scaleY = screenSize.height / 1000;
    double scale = scaleX < scaleY ? scaleX : scaleY;
    transformationController.value = Matrix4.identity()..scale(scale, scale);
  }

  void _buildGraph() {
    var response = widget.mininetResponse;
    var topology = response["topology"];
    List<String> hosts = List<String>.from(topology["hosts"]);
    List<String> switches = List<String>.from(topology["switches"]);
    List<List<dynamic>> links = List<List<dynamic>>.from(topology["links"]);

    Map<String, Node> nodes = {};
    Set<String> nonOrphanSwitches = {};

    for (var link in links) {
      if (hosts.contains(link[0])) {
        nonOrphanSwitches.add(link[1]);
      }
      if (hosts.contains(link[1])) {
        nonOrphanSwitches.add(link[0]);
      }
    }

    for (var switchNode in switches) {
      if (nonOrphanSwitches.contains(switchNode)) {
        nodes[switchNode] = Node.Id(switchNode);
        graph.addNode(nodes[switchNode]!);
      }
    }

    for (var host in hosts) {
      nodes[host] = Node.Id(host);
      graph.addNode(nodes[host]!);
    }

    for (var link in links) {
      String node1 = link[0];
      String node2 = link[1];
      if (nodes.containsKey(node1) && nodes.containsKey(node2)) {
        graph.addEdge(nodes[node1]!, nodes[node2]!,
            paint: Paint()..color = Colors.blue);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PingProvider>(
      builder: (context, pingProvider, child) {
        return Column(
          children: [
            SizedBox(
              height: heightPercentage(48, context),
              child: InteractiveViewer(
                constrained: false,
                minScale: 0.08,
                maxScale: 100,
                boundaryMargin: const EdgeInsets.all(20),
                transformationController: transformationController,
                child: GraphView(
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                      builder, TreeEdgeRenderer(builder)),
                  paint: Paint()..color = Colors.blue,
                  builder: (Node node) {
                    String label = node.key!.value.toString();
                    return networkNode(label);
                  },
                ),
              ),
            ),
            if (pingProvider.currentPingData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PingVisualization(
                  pingData: pingProvider.currentPingData!,
                  onPacketPathUpdate: (src, dst, path) {
                    _updateGraph({
                      'src': src,
                      'dst': dst,
                      'path': path,
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget networkNode(String label) {
    bool isSwitch = label.startsWith('s') ? true : false;
    return Consumer<PingProvider>(
      builder: (context, pingProvider, child) {
        bool isInPath = pingProvider.currentPath.contains(label);
        bool isActive = isInPath &&
            pingProvider.currentPathIndex <
                pingProvider.currentPath.length - 1 &&
            (label == pingProvider.currentPath[pingProvider.currentPathIndex] ||
                label ==
                    pingProvider
                        .currentPath[pingProvider.currentPathIndex + 1]);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                border:
                    isActive ? Border.all(color: Colors.red, width: 2) : null,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                isSwitch
                    ? 'assets/tutorials/switch.png'
                    : 'assets/tutorials/host.png',
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.red : Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateGraph(dynamic packetData) {
    String src = packetData["src"];
    String dst = packetData["dst"];
    List<dynamic> path = packetData["path"];

    setState(() {
      for (var edge in graph.edges) {
        if (path.contains(edge.source.key) &&
            path.contains(edge.destination.key)) {
          edge.paint = Paint()..color = Colors.red;
        } else {
          edge.paint = Paint()..color = Colors.blue;
        }
      }
    });

    _animatePacket(src, dst, path);
  }

  void _animatePacket(String src, String dst, List<dynamic> path) {
    log('TreeTopology: Starting packet animation from $src to $dst along path: $path');
    _animationFutures.clear();
    for (var i = 0; i < path.length - 1; i++) {
      final future = Future.delayed(Duration(milliseconds: 500 * i), () {
        if (mounted) {
          log('TreeTopology: Animation step $i - updating progress to $i');
          context.read<PingProvider>().updateAnimationProgress(i);
        } else {
          log('TreeTopology: Widget not mounted during animation step $i');
        }
      });
      _animationFutures.add(future);
    }

    // Reset animation after completion
    _animationFutures.add(
      Future.delayed(Duration(milliseconds: 500 * (path.length - 1) + 500), () {
        if (mounted) {
          log('TreeTopology: Animation completed, resetting animation state');
          context.read<PingProvider>().resetAnimation();
        } else {
          log('TreeTopology: Widget not mounted during animation reset');
        }
      }),
    );
  }
}
