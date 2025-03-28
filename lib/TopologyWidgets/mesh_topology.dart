import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

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

  Color nodeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustGraphScale());
    _buildGraph();
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
        attractionRate: widget.meshType == 'full' ? 0 : 0.1,
        repulsionRate: widget.meshType == 'full' ? 0.5 : 1,
        renderer: ArrowEdgeRenderer());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: true,
      boundaryMargin: const EdgeInsets.all(50),
      transformationController: transformationController,
      child: GraphView(
        graph: graph,
        algorithm: algorithm,
        paint: Paint()..color = Colors.blue,
        builder: (Node node) {
          String label = node.key!.value.toString();
          return networkNode(label);
        },
      ),
    );
  }

  Widget networkNode(String label) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: nodeColor,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
