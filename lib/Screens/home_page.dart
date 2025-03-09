import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/Templates.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Screens/topology_screen.dart';
import 'package:network_simulator/Services/mininet_service.dart';
import 'package:network_simulator/Utils/topo_utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Map<String, int>> topoLimits = TopoUtils.topologyLimits;

  int switchCount = 1;
  int hostsCount = 1;

  String? selectedTopology;

  String? meshType;

  int maxSwitches = 0;
  int maxHosts = 0;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String mininetStatus = "Waiting for updates...";
  final mininetServise = MininetService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            width: textFieldWidth(context),
            alignment: Alignment.center,
            height: heightPercentage(80, context),
            child: ListView(
              children: [
                Text(
                  'Create a new lan network',
                  style: AppStyles.headerText3Style,
                  textAlign: TextAlign.center,
                ),
                gapeBox,
                // Gape Container

                gapeContainer('Select your topology'),
                SizedBox(
                    width: textFieldWidth(context),
                    child: DropdownButtonFormField(
                        value: selectedTopology,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: Colors.black,
                        ),
                        hint: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            "Choose here",
                            style: AppStyles.smallBlackTextStyle(isBold: false),
                          ),
                        ),
                        decoration: InputDecoration(
                          errorStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          fillColor: textfieldBGColor,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                        ),
                        dropdownColor: buttonColor,
                        validator: (value) {
                          if (value == null) {
                            return 'You must select a topology';
                          }
                          return null;
                        },
                        items: [
                          myDropdownItem('tree', 'Tree Topology'),
                          myDropdownItem('mesh', 'Mesh Topology'),
                          myDropdownItem('fattree', 'Fat Tree Topology'),
                          // myDropdownItem('custom', 'Custom Topology'),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedTopology = val;
                            hostsCount = 0;
                            maxHosts = TopoUtils
                                .topologyLimits[selectedTopology]!["maxHosts"]!;
                            maxSwitches = TopoUtils.topologyLimits[
                                selectedTopology]!["maxSwitches"]!;
                            if (switchCount > maxSwitches) {
                              switchCount = maxSwitches;
                            } else if (hostsCount > maxHosts) {
                              hostsCount = maxHosts;
                            }
                          });
                          log('Max Switches: $maxSwitches \n Max Hosts: $maxHosts');
                        })),
                gapeBox,
                if (selectedTopology == 'mesh')
                  gapeContainer('Select the type of mesh'),
                if (selectedTopology == 'mesh')
                  SizedBox(
                      width: textFieldWidth(context) - 10,
                      child: DropdownButtonFormField(
                          value: meshType,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: Colors.black,
                          ),
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Choose here",
                              style:
                                  AppStyles.smallBlackTextStyle(isBold: false),
                            ),
                          ),
                          decoration: InputDecoration(
                            fillColor: textfieldBGColor,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  const BorderSide(color: Colors.black54),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  const BorderSide(color: Colors.black54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  const BorderSide(color: Colors.black54),
                            ),
                          ),
                          dropdownColor: buttonColor,
                          validator: (value) {
                            if (value == null) {
                              return 'You must select the Mesh Type';
                            }
                            return null;
                          },
                          items: [
                            myDropdownItem('partial', 'Partial Mesh'),
                            myDropdownItem('full', 'Full Mesh'),
                          ],
                          onChanged: (val) {
                            setState(() {
                              meshType = val;
                            });
                          })),
                gapeBox,
                gapeBox,
                if (maxSwitches != 0)
                  gapeContainer('Number of hosts $hostsCount'),
                if (maxSwitches != 0)
                  Slider(
                    min: 1,
                    max: maxHosts.toDouble(),
                    label: hostsCount.toString(),
                    divisions: maxHosts - 1,
                    value: hostsCount.clamp(1, maxHosts).toDouble(),
                    onChanged: (value) {
                      setState(() {
                        hostsCount = value.toInt();
                      });
                    },
                    thumbColor: buttonColor,
                    overlayColor: const WidgetStatePropertyAll(Colors.white30),
                    activeColor: buttonColor,
                    inactiveColor: Colors.grey,
                    secondaryActiveColor: Colors.black,
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 55,
        alignment: Alignment.center,
        width: textFieldWidth(context),
        child: MyButtons.largeButton(context, 'Create Network', () async {
          final isValid = _formKey.currentState!.validate();

          if (!isValid) {
            return;
          }
          _formKey.currentState!.save();
          if (!context.mounted) return;
          MyDialogs.loadingStart(context);

          try {
            String status = mininetServise.startMininet(
                hostsCount, switchCount, selectedTopology!, meshType);
            if (status == 'success') {
              mininetServise.listenToResponses((response) {
                log(response.runtimeType.toString());
                final res = jsonDecode(response);
                log("Mininet Responsee: $response");
                if (res['status'] == 'success') {
                  log(res['message']);
                  log(res['topology'].toString());
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TopologyScreen(
                                data: res,
                                topo: selectedTopology!,
                                meshType: meshType,
                              )));
                } else if (res['status'] == 'failure') {
                  log(res['message']);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(res['message'].toString()),
                  ));
                } else if (res['status'] == 'error') {
                  log('an error occured: ');
                  log(res['message']);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(res['message'].toString()),
                  ));
                }
              });
            } else if (status == 'error') {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Error while starting mininet...')));
            } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Server disconnected...')));
            }
          } catch (e) {
            log('Error: $e');
          }
        }),
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

  @override
  void dispose() {
    super.dispose();
  }
}

DropdownMenuItem<String> myDropdownItem(String val, String text) {
  return DropdownMenuItem(
    value: val,
    child: Text(
      text,
      style: AppStyles.smallBlackTextStyle(isBold: false),
    ),
  );
}
