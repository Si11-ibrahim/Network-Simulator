import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

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

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustGraphScale());
    _buildGraph();
  }

  void _adjustGraphScale() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Size screenSize = MediaQuery.of(context).size;

      double scaleX = screenSize.width / 1200; // Adjust graph width
      double scaleY = screenSize.height / 1200; // Adjust graph height
      double finalScale = (scaleX < scaleY ? scaleX : scaleY) * 0.8;
      finalScale = finalScale.clamp(0.3, 2.0); // Prevent extreme zooming

      transformationController.value = Matrix4.identity()
        ..translate(screenSize.width / 4, screenSize.height / 4)
        ..scale(finalScale);
    });
  }

  void _buildGraph() {
    var response = widget.mininetResponse;
    var topology = response["topology"];
    List<String> hosts = List<String>.from(topology["hosts"]);
    List<String> switches = List<String>.from(topology["switches"]);
    List<List<dynamic>> links = List<List<dynamic>>.from(topology["links"]);

    Map<String, Node> nodes = {};

    for (var switchNode in switches) {
      nodes[switchNode] = Node.Id(switchNode);
      graph.addNode(nodes[switchNode]!);
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

    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustGraphScale());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: InteractiveViewer(
        constrained: false, // Allow free movement
        boundaryMargin: const EdgeInsets.all(20),
        transformationController: transformationController,
        minScale: 0.01,
        maxScale: 5.0,
        child: GraphView(
          graph: graph,
          algorithm: SugiyamaAlgorithm(builder),
          paint: Paint()..color = Colors.blue,
          builder: (Node node) {
            return networkNode(node.key!.value.toString());
          },
        ),
      ),
    );
  }

  Widget networkNode(String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: label.startsWith('s') ? Colors.orange : Colors.green,
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
