import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/Provider/ping_provider.dart';
import 'package:network_simulator/Widgets/ping_visualization.dart';
import 'package:provider/provider.dart';

class MeshTopology extends StatefulWidget {
  final Map<String, dynamic> mininetResponse;
  final String? meshType;

  const MeshTopology({super.key, required this.mininetResponse, this.meshType});

  @override
  _MeshTopologyState createState() => _MeshTopologyState();
}

class _MeshTopologyState extends State<MeshTopology> {
  final Graph graph = Graph()..isTree = false;
  late FruchtermanReingoldAlgorithm algorithm;
  late TransformationController transformationController;
  late double minScale, maxScale;
  final List<Future> _animationFutures = [];

  Color nodeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController();
    minScale = 0.5; // Prevent too much zoom out
    maxScale = 2.0; // Prevent too much zoom in
    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustGraphScale());
    _buildGraph();
  }

  @override
  void didUpdateWidget(MeshTopology oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mininetResponse != widget.mininetResponse) {
      _clearGraph();
      _buildGraph();
      if (widget.mininetResponse['type'] == 'path_data') {
        log('MeshTopology: Received path data: ${widget.mininetResponse.toString()}');
        context.read<PingProvider>().updatePingData(widget.mininetResponse);
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
    transformationController.value = Matrix4.identity()..scale(0.8, 0.8);
  }

  void _buildGraph() {
    var response = widget.mininetResponse;
    var topology = response["topology"];
    List<String> hosts = List<String>.from(topology["hosts"]);
    List<List<dynamic>> links = List<List<dynamic>>.from(topology["links"]);

    Map<String, Node> nodes = {};
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
    log(widget.meshType ?? 'Mesh type is null');
    algorithm = FruchtermanReingoldAlgorithm(
        iterations: 1000,
        attractionRate: widget.meshType == 'full' ? 0.005 : 0.1,
        repulsionRate: widget.meshType == 'full' ? 0.5 : 0.2,
        renderer: ArrowEdgeRenderer());

    setState(() {});
  }

  /// Resets the graph position when user gets lost
  void _resetGraphView() {
    setState(() {
      transformationController.value = Matrix4.identity()..scale(0.9);
    });
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
                minScale: minScale,
                maxScale: maxScale,
                constrained: true,
                boundaryMargin: const EdgeInsets.all(500),
                transformationController: transformationController,
                child: GraphView(
                  graph: graph,
                  algorithm: algorithm,
                  paint: Paint()..color = textfieldBGColor!,
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border:
                    isActive ? Border.all(color: Colors.red, width: 2) : null,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                label.startsWith('s')
                    ? 'assets/tutorials/switch.png'
                    : 'assets/tutorials/host.png',
                width: 60,
                height: 60,
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
    log('MeshTopology: Starting packet animation from $src to $dst along path: $path');
    _animationFutures.clear();
    for (var i = 0; i < path.length - 1; i++) {
      final future = Future.delayed(Duration(milliseconds: 500 * i), () {
        if (mounted) {
          log('MeshTopology: Animation step $i - updating progress to $i');
          context.read<PingProvider>().updateAnimationProgress(i);
        } else {
          log('MeshTopology: Widget not mounted during animation step $i');
        }
      });
      _animationFutures.add(future);
    }

    // Reset animation after completion
    _animationFutures.add(
      Future.delayed(Duration(milliseconds: 500 * (path.length - 1) + 500), () {
        if (mounted) {
          log('MeshTopology: Animation completed, resetting animation state');
          context.read<PingProvider>().resetAnimation();
        } else {
          log('MeshTopology: Widget not mounted during animation reset');
        }
      }),
    );
  }
}
