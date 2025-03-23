import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/Templates.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/mininet_service.dart';
import 'package:network_simulator/TopologyWidgets/fat_tree.dart';
import 'package:network_simulator/TopologyWidgets/mesh_topology.dart';
import 'package:network_simulator/TopologyWidgets/tree_topo.dart';

class TopologyScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String topo;
  final String? meshType;
  const TopologyScreen(
      {super.key, required this.data, required this.topo, this.meshType});

  @override
  _TopologyScreenState createState() => _TopologyScreenState();
}

class _TopologyScreenState extends State<TopologyScreen> {
  TextEditingController commandController = TextEditingController();

  Map<String, Widget> topo(Map<String, dynamic> res) => {
        'fattree': FatTreeTopology(
          mininetResponse: res,
        ),
        'mesh': MeshTopology(
          mininetResponse: res,
          meshType: widget.meshType,
        ),
        'tree': TreeTopology(mininetResponse: res)
      };

  @override
  void initState() {
    super.initState();
    commandController.addListener(() {});
  }

  @override
  void dispose() {
    commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mininetServise = MininetService(context);
    return Scaffold(
      appBar: AppBar(
        // leading: MyButtons.backButton(context),
        automaticallyImplyLeading: false,
        title: Text(
          'Topology Screen',
          style: AppStyles.mediumWhiteTextStyle(isBold: true),
        ),
        backgroundColor: bgColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // MyButtons.largeButton(context, 'Ping All', () {
              //   mininetServise.executeCommand('pingall');
              // }),
              gapeContainer('Execute any command here'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyInputFields.textField(
                      context,
                      controller: commandController,
                      (val) {
                        if (val == null) {
                          return "Field is empty";
                        }
                        return null;
                      },
                      100,
                      'type here',
                      (val) {
                        commandController.value = TextEditingValue(text: val);
                      },
                      suffix: IconButton(
                          onPressed: () {
                            if (commandController.value.text.isNotEmpty) {
                              mininetServise.executeCommand(
                                  commandController.text.trim());
                              setState(() {
                                commandController.clear();
                              });
                              MyDialogs.loadingStart(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Field is empty')));
                            }
                          },
                          icon: const Icon(Icons.send))),
                ],
              ),
              gapeBox,
              Container(
                  margin: const EdgeInsets.all(5),
                  height:
                      //  widget.topo == 'mesh' ? null :
                      500,
                  child: topo(widget.data)[widget.topo]),
              gapeBox,
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100),
        width: widthPercentage(80, context),
        child: MyButtons.largeButton(context, 'Stop Mininet', () {
          mininetServise.stopMininet();
          MyDialogs.loadingStart(context);
          Future.delayed(const Duration(seconds: 3)).then((val) {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        }),
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

  Widget gapeContainer(String text) => Container(
        alignment: Alignment.centerLeft,
        width: textFieldWidth(context),
        height: gapeHeight + 15,
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            textAlign: TextAlign.left,
            style: AppStyles.mediumWhiteTextStyle(isBold: true)),
      );
}
