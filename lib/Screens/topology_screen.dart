import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/Templates.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/mininet_service.dart';
import 'package:network_simulator/TopologyWidgets/fat_tree.dart';
import 'package:network_simulator/TopologyWidgets/mesh_topology.dart';

class TopologyScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String topo;
  const TopologyScreen({super.key, required this.data, required this.topo});

  @override
  _TopologyScreenState createState() => _TopologyScreenState();
}

class _TopologyScreenState extends State<TopologyScreen> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyButtons.largeButton(context, 'Ping All', () {
                mininetServise.executeCommand('pingall');
              }),
              gapeBox,
              MyButtons.largeButton(context, 'Stop Mininet', () {
                mininetServise.stopMininet();
                MyDialogs.loadingStart(context);
                Future.delayed(const Duration(seconds: 3)).then((val) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              }),
              gapeBox,
              SizedBox(
                  width: widthPercentage(95, context),
                  child: topo(widget.data)[widget.topo]),
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
