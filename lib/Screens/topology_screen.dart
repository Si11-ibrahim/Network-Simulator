import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:http/http.dart' as http;

class TopologyScreen extends StatefulWidget {
  const TopologyScreen({super.key});

  @override
  _TopologyScreenState createState() => _TopologyScreenState();
}

class _TopologyScreenState extends State<TopologyScreen> {
  Graph graph = Graph()..isTree = false;

  Future<void> fetchTopology() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/generate_topology'),
      body: jsonEncode({"switches": 3, "hosts": 6}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List nodes = data['nodes'];
      List edges = data['edges'];

      Map<String, Node> nodeMap = {};

      for (var node in nodes) {
        nodeMap[node] = Node.Id(node);
        graph.addNode(nodeMap[node]!);
      }

      for (var edge in edges) {
        graph.addEdge(nodeMap[edge[0]]!, nodeMap[edge[1]]!);
      }

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTopology();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        constrained: false,
        child: GraphView(
          graph: graph,
          algorithm: FruchtermanReingoldAlgorithm(),
          builder: (Node node) {
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
