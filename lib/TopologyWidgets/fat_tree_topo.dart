import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/Provider/ping_provider.dart';
import 'package:network_simulator/Widgets/ping_visualization.dart';
import 'package:provider/provider.dart';

class FatTreeTopology extends StatefulWidget {
  final Map<String, dynamic> mininetResponse;

  const FatTreeTopology({super.key, required this.mininetResponse});

  @override
  _FatTreeTopologyState createState() => _FatTreeTopologyState();
}

class _FatTreeTopologyState extends State<FatTreeTopology> {
  final Graph graph = Graph()..isTree = false;
  final SugiyamaConfiguration builder = SugiyamaConfiguration();
  late TransformationController transformationController;
  final List<Future> _animationFutures = [];
  bool _isGraphBuilt = false;
  // Store layer values for Sugiyama - use consistent int types
  final Map<Node, int> _nodeLayers = {};

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController();
    builder
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM
      ..levelSeparation = 150
      ..nodeSeparation = 100
      ..iterations = 20
      ..coordinateAssignment = CoordinateAssignment.Average;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildGraph();
      _adjustGraphScale();
    });
  }

  @override
  void didUpdateWidget(FatTreeTopology oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mininetResponse != widget.mininetResponse) {
      _clearGraph();
      _buildGraph();
      if (widget.mininetResponse['type'] == 'path_data') {
        log('FatTreeTopology: Received path data: ${widget.mininetResponse.toString()}');
        if (mounted) {
          context.read<PingProvider>().updatePingData(widget.mininetResponse);
        }
      }
    }
  }

  void _clearGraph() {
    setState(() {
      graph.nodes.clear();
      graph.edges.clear();
      _nodeLayers.clear();
      _isGraphBuilt = false;
      _cancelAnimations();
    });
  }

  void _cancelAnimations() {
    for (var future in _animationFutures) {
      future.ignore();
    }
    _animationFutures.clear();
  }

  @override
  void dispose() {
    _cancelAnimations();
    transformationController.dispose();
    super.dispose();
  }

  void _adjustGraphScale() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isGraphBuilt) return;

      try {
        final Size screenSize = MediaQuery.of(context).size;
        final double scaleX = screenSize.width / 1200;
        final double scaleY = screenSize.height / 1200;
        double finalScale = (scaleX < scaleY ? scaleX : scaleY) * 0.8;
        finalScale = finalScale.clamp(0.3, 2.0);

        final double centerX = screenSize.width / 4;
        final double centerY = screenSize.height / 4;

        transformationController.value = Matrix4.identity()
          ..translate(centerX, centerY)
          ..scale(finalScale);
      } catch (e) {
        log('Error adjusting graph scale: $e');
      }
    });
  }

  void _buildGraph() {
    if (!mounted) return;

    try {
      final response = widget.mininetResponse;
      if (!(response.containsKey("topology") && response["topology"] != null)) {
        log('FatTreeTopology: Invalid or missing topology data');
        return;
      }

      final topology = response["topology"];
      if (!(topology.containsKey("hosts") &&
          topology.containsKey("switches") &&
          topology.containsKey("links"))) {
        log('FatTreeTopology: Topology data is missing required elements');
        return;
      }

      final List hosts = topology["hosts"] ?? [];
      final List switches = topology["switches"] ?? [];
      final List links = topology["links"] ?? [];

      if (switches.isEmpty) {
        log('FatTreeTopology: No switches found in topology');
        return;
      }

      final Map<String, Node> nodes = {};
      _nodeLayers.clear();

      // Generate unique int IDs for Sugiyama if not already using ints
      int nodeCounter = 0;
      Map<String, int> labelToInt = {};

      int getId(String label) =>
          labelToInt.putIfAbsent(label, () => ++nodeCounter);

      // Create nodes with different layers based on their type
      for (var switchNode in switches) {
        var node = Node.Id(switchNode);
        nodes[switchNode] = node;

        int layer;
        if (switchNode.startsWith('s')) {
          final int switchIdx = switches.indexOf(switchNode);
          if (switchIdx < (switches.length ~/ 4)) {
            layer = 0; // Core switches
          } else if (switchIdx < (switches.length ~/ 2)) {
            layer = 1; // Aggregation switches
          } else {
            layer = 2; // Edge switches
          }
        } else {
          layer = 3; // Hosts
        }
        _nodeLayers[node] = layer;
        graph.addNode(node);
      }

      // Add hosts at bottom layer
      for (var host in hosts) {
        var node = Node.Id(host);
        nodes[host] = node;
        _nodeLayers[node] = 3; // Host level
        graph.addNode(node);
      }

      // Add links
      for (var link in links) {
        if (link.length < 2) continue;
        final String node1 = link[0].toString();
        final String node2 = link[1].toString();
        if (nodes.containsKey(node1) && nodes.containsKey(node2)) {
          graph.addEdge(
            nodes[node1]!,
            nodes[node2]!,
            paint: Paint()
              ..color = Colors.blue
              ..strokeWidth = 1.5,
          );
        }
      }

      setState(() {
        _isGraphBuilt = true;
      });

      _adjustGraphScale();
    } catch (e) {
      log('Error building graph: $e');
    }
  }

  // The builder expects Node.id as int (converted label), but the label in your data may be string.
  // We'll keep a label->id map and its inverse for showing string labels.
  Map<int, String>? _invLabelMap;
  Map<int, String> _getInverseLabelMap() {
    // Rebuild on every buildGraph
    final inv = <int, String>{};
    // Access labelToInt from _buildGraph
    int nodeCounter = 0;
    Map<String, int> labelToInt = {};
    int getId(String label) =>
        labelToInt.putIfAbsent(label, () => ++nodeCounter);

    final response = widget.mininetResponse;
    if (!(response.containsKey("topology") && response["topology"] != null)) {
      return {};
    }
    final topology = response["topology"];
    final List hosts = topology["hosts"] ?? [];
    final List switches = topology["switches"] ?? [];
    for (var label in [...switches, ...hosts]) {
      inv[getId(label)] = label;
    }
    return inv;
  }

  @override
  Widget build(BuildContext context) {
    // Lazy build the inverse label map so networkNode gets correct string label for the int Node.Id
    _invLabelMap = _getInverseLabelMap();
    return Consumer<PingProvider>(
      builder: (context, pingProvider, child) {
        return Column(
          children: [
            SizedBox(
              height: heightPercentage(48, context),
              child: InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(40),
                transformationController: transformationController,
                minScale: 0.1,
                maxScale: 5.0,
                child: _isGraphBuilt
                    ? GraphView(
                        graph: graph,
                        algorithm: _createSugiyamaAlgorithm(),
                        paint: Paint()..color = Colors.blue,
                        builder: (Node node) {
                          final nodeId = node.key!.value;
                          String label =
                              _invLabelMap?[nodeId] ?? nodeId.toString();
                          return networkNode(label);
                        },
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            if (pingProvider.currentPingData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PingVisualization(
                  pingData: pingProvider.currentPingData!,
                  onPacketPathUpdate: (src, dst, path) {
                    if (mounted && _isGraphBuilt) {
                      _updateGraph({
                        'src': src,
                        'dst': dst,
                        'path': path,
                      });
                    }
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  SugiyamaAlgorithm _createSugiyamaAlgorithm() {
    final alg = SugiyamaAlgorithm(builder);
    for (var entry in _nodeLayers.entries) {
      var nodeData = SugiyamaNodeData()
        ..layer = entry.value
        ..position = -1;
      alg.nodeData[entry.key] = nodeData;
    }
    return alg;
  }

  Widget networkNode(String label) {
    bool isSwitch = label.startsWith('s') ||
        label.startsWith('c') ||
        label.startsWith('e') ||
        label.startsWith('a');
    return Consumer<PingProvider>(
      builder: (context, pingProvider, child) {
        final bool isInPath = pingProvider.currentPath.contains(label);
        final bool isActive = isInPath &&
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
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: isActive
                    ? Border.all(color: Colors.red, width: 2)
                    : isInPath
                        ? Border.all(color: Colors.orange, width: 1)
                        : null,
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
    if (!mounted || packetData == null) return;
    try {
      final String src = packetData["src"]?.toString() ?? "";
      final String dst = packetData["dst"]?.toString() ?? "";
      final List<dynamic> path = packetData["path"] ?? [];
      if (src.isEmpty || dst.isEmpty || path.isEmpty) {
        log('FatTreeTopology: Invalid packet data');
        return;
      }
      // Cast path to int IDs
      final inverse = _invLabelMap ?? {};
      final labelToId = {for (var e in inverse.entries) e.value: e.key};
      final pathIds = path
          .map((label) => labelToId[label]?.toString() ?? label.toString())
          .toList();

      setState(() {
        for (var edge in graph.edges) {
          final nodeSrcId = edge.source.key?.value.toString() ?? "";
          final nodeDstId = edge.destination.key?.value.toString() ?? "";
          final bool isInPath = pathIds.contains(nodeSrcId) &&
              pathIds.contains(nodeDstId) &&
              _isAdjacentInPath(nodeSrcId, nodeDstId, pathIds);
          edge.paint = Paint()
            ..color = isInPath ? Colors.red : Colors.blue
            ..strokeWidth = isInPath ? 2.0 : 1.5;
        }
      });
      _animatePacket(src, dst, pathIds);
    } catch (e) {
      log('Error updating graph: $e');
    }
  }

  // Helper: adjacent in int path or string
  bool _isAdjacentInPath(String node1, String node2, List path) {
    for (int i = 0; i < path.length - 1; i++) {
      if ((path[i] == node1 && path[i + 1] == node2) ||
          (path[i] == node2 && path[i + 1] == node1)) {
        return true;
      }
    }
    return false;
  }

  void _animatePacket(String src, String dst, List<dynamic> path) {
    log('FatTreeTopology: Starting packet animation from $src to $dst along path: $path');
    _cancelAnimations();
    for (var i = 0; i < path.length - 1; i++) {
      final future = Future.delayed(Duration(milliseconds: 500 * i), () {
        if (mounted) {
          log('FatTreeTopology: Animation step $i - updating progress to $i');
          context.read<PingProvider>().updateAnimationProgress(i);
        } else {
          log('FatTreeTopology: Widget not mounted during animation step $i');
        }
      });
      _animationFutures.add(future);
    }
    final resetFuture = Future.delayed(
      Duration(milliseconds: 500 * (path.length - 1) + 500),
      () {
        if (mounted) {
          log('FatTreeTopology: Animation completed, resetting animation state');
          context.read<PingProvider>().resetAnimation();
          setState(() {
            for (var edge in graph.edges) {
              edge.paint = Paint()
                ..color = Colors.blue
                ..strokeWidth = 1.5;
            }
          });
        }
      },
    );
    _animationFutures.add(resetFuture);
  }
}
