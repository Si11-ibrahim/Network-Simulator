import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:network_simulator/Constants/Templates.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/mininet_service.dart';
import 'package:network_simulator/TopologyWidgets/fat_tree.dart';
import 'package:network_simulator/TopologyWidgets/mesh.dart';

class TopologyScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String topo;
  const TopologyScreen({super.key, required this.data, required this.topo});

  @override
  _TopologyScreenState createState() => _TopologyScreenState();
}

class _TopologyScreenState extends State<TopologyScreen> {
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  final mininetServise = MininetService();

  Map<String, Widget> topo(Map<String, dynamic> res) => {
        'fattree': FatTreeTopology(
          mininetResponse: res,
        ),
        'mesh': MeshTopology(
          mininetResponse: res,
        )
      };

  @override
  void initState() {
    super.initState();
  }

  void buildGraph() {
    final topology = widget.data['topology'];

    List<String> hosts = List<String>.from(topology["hosts"]);
    List<String> switches = List<String>.from(topology["switches"]);
    List<List<String>> links = List<List<String>>.from(topology["links"]);

    Map<String, Node> nodeMap = {}; // To store created nodes

    // Create nodes for hosts and switches
    for (String host in hosts) {
      nodeMap[host] = Node.Id(host);
      graph.addNode(nodeMap[host]!);
    }
    for (String switchNode in switches) {
      nodeMap[switchNode] = Node.Id(switchNode);
      graph.addNode(nodeMap[switchNode]!);
    }

    // Add links (edges) between nodes
    for (var link in links) {
      String node1 = link[0];
      String node2 = link[1];

      if (nodeMap.containsKey(node1) && nodeMap.containsKey(node2)) {
        graph.addEdge(nodeMap[node1]!, nodeMap[node2]!);
      }
    }

    // Configure graph layout
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: MyButtons.backButton(context),
        title: Text(
          'Topology Screen',
          style: AppStyles.mediumBlackTextStyle(isBold: true),
        ),
        backgroundColor: bgColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              MyButtons.largeButton(context, 'Ping All', () {
                mininetServise.executeCommand('pingall');
              }),
              gapeBox,
              MyButtons.largeButton(context, 'Stop Mininet', () {
                mininetServise.stopMininet();
              }),
              gapeBox,
              SizedBox(height: 500, child: topo(widget.data)[widget.topo]),
            ],
          ),
        ),
      ),
    );
  }

  Widget networkNode(String label) {
    return Container(
      padding: const EdgeInsets.all(10),
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
