import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_simulator/Constants/Templates.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> deviceCategories = [
    'Network Devices',
    'End Devices',
    'Connections',
    'Other Devices'
  ];

  int routerCount = 0;
  int switchCount = 0;
  int hostsCount = 0;

  String? selectedTopology;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // void showGridModal(BuildContext context) {
  //   showModalBottomSheet(
  //     sheetAnimationStyle: AnimationStyle(
  //         curve: Easing.legacy, duration: const Duration(seconds: 1)),
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (context) {
  //       return Column(
  //         children: [
  //           const ListTile(
  //             title: Text('Select a device for the network'),
  //           ),
  //           Container(
  //             alignment: Alignment.center,
  //             padding: const EdgeInsets.all(16),
  //             height: heightPercentage(50, context),
  //             width: widthPercentage(80, context),
  //             child: GridView.builder(
  //               shrinkWrap: true,
  //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: 3,
  //                   crossAxisSpacing: 8,
  //                   mainAxisSpacing: 8,
  //                   childAspectRatio: 1.0),
  //               itemCount: deviceCategories.length,
  //               itemBuilder: (context, index) {
  //                 return Container(
  //                   height: 50,
  //                   width: 50,
  //                   decoration: BoxDecoration(
  //                     color: Colors.black54,
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   constraints:
  //                       const BoxConstraints(maxHeight: 50, maxWidth: 50),
  //                   child: TextButton(
  //                     isSemanticButton: false,
  //                     onPressed: () {
  //                       setState(() {});
  //                       Navigator.pop(context);
  //                     },
  //                     child: Container(
  //                       alignment: Alignment.center,
  //                       child: Text(
  //                         deviceCategories[index],
  //                         textAlign: TextAlign.center,
  //                         style: AppStyles.mediumWhiteTextStyle(),
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<int> sendDeviceCounts(int switches, int routers, int hosts) async {
    final url = Uri.parse("http://127.0.0.1:8000/get_device_counts");
    int statusCode = 0;
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "switches": switches,
          "routers": routers,
          "hosts": hosts,
        }),
      );
      statusCode = response.statusCode;
      if (response.statusCode == 200) {
        log("Device counts sent successfully!");
      } else {
        log("Failed to send device counts: ${response.body}");
      }
      return response.statusCode;
    } catch (e) {
      log(e.toString());
    } finally {
      if (mounted) MyDialogs.closeDialog(context);
    }
    return statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white54,
        title: Text(
          'LAN Network Graphic Editor Practice',
          style: AppStyles.mediumBlackTextStyle(),
        ),
      ),
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
                  'Enter the number of devices you need',
                  style: AppStyles.mediumBlackTextStyle(),
                ),
                gapeBox,
                // Gape Container
                gapeContainer('Router Count'),
                MyInputFields.textField(
                  context,
                  (val) {
                    if (val!.isEmpty) return 'Field cannot be empty';
                    return null;
                  },
                  3,
                  '',
                  (val) {
                    setState(() {
                      routerCount = int.tryParse(val)!;
                    });
                  },
                  type: TextInputType.number,
                ),

                gapeContainer('Switch Count'),
                MyInputFields.textField(
                    context,
                    (val) {
                      if (val!.isEmpty) return 'Field cannot be empty';

                      return null;
                    },
                    3,
                    '',
                    (val) {
                      setState(() {
                        switchCount = int.tryParse(val)!;
                      });
                    },
                    type: TextInputType.number),
                gapeContainer('Hosts Count'),
                MyInputFields.textField(
                    context,
                    (val) {
                      if (val!.isEmpty) return 'Field cannot be empty';

                      return null;
                    },
                    3,
                    '',
                    (val) {
                      setState(() {
                        hostsCount = int.tryParse(val)!;
                      });
                    },
                    type: TextInputType.number),
                gapeContainer('Select your topology'),
                Container(
                    decoration: BoxDecoration(
                        color: textfieldBGColor,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(15)),
                    width: textFieldWidth(context),
                    height: 50,
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
                        decoration: const InputDecoration(
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        dropdownColor: Colors.white,
                        validator: (value) {
                          if (value == null) {
                            return 'You should your preference';
                          }
                          return null;
                        },
                        items: [
                          myDropdownItem('tree', 'Tree Topology'),
                          myDropdownItem('mesh', 'Mesh Topology'),
                          myDropdownItem(
                              'auto', 'Select topology automatically'),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedTopology = val;
                          });
                        })),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 55,
        alignment: Alignment.center,
        width: textFieldWidth(context),
        child: MyButtons.bigButton(context, 'Send to Server', () async {
          final isValid = _formKey.currentState!.validate();

          if (!isValid) {
            return;
          }
          _formKey.currentState!.save();
          if (!context.mounted) return;
          MyDialogs.loadingStart(context);
          await sendDeviceCounts(switchCount, routerCount, hostsCount);
          log(routerCount.toString());
          log(switchCount.toString());
          log(hostsCount.toString());
        }),
      ),
    );
  }

  Widget gapeContainer(String text) => Container(
        alignment: Alignment.centerLeft,
        width: textFieldWidth(context),
        height: gapeHeight - 13,
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            textAlign: TextAlign.left,
            style: AppStyles.smallBlackTextStyle(isBold: true)),
      );
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
