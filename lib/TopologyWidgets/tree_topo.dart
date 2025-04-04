import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      minScale: 0.08,
      maxScale: 100,
      boundaryMargin: const EdgeInsets.all(20),
      transformationController: transformationController,
      child: GraphView(
        graph: graph,
        algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
        paint: Paint()..color = Colors.blue,
        builder: (Node node) {
          String label = node.key!.value.toString();
          return networkNode(label);
        },
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
