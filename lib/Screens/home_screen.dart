import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/Templates.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Screens/topology_screen.dart';
import 'package:network_simulator/Screens/tutorials_screen.dart';
import 'package:network_simulator/Services/loading_service.dart';
import 'package:network_simulator/Services/mininet_service.dart';
import 'package:network_simulator/Utils/topo_utils.dart';
import 'package:network_simulator/Widgets/app_bar.dart';
import 'package:network_simulator/Widgets/tutorial_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LoadingService _loadingService = LoadingService();
  late final MininetService mininetService;

  Map<String, Map<String, int>> topoLimits = TopoUtils.topologyLimits;

  int switchCount = 1;
  int hostsCount = 1;

  String? selectedTopology;

  String? meshType;

  int maxSwitches = 0;
  int maxHosts = 0;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isCreatingNetwork = false;
  String mininetStatus = "Waiting for updates...";
  String? errorMessage;
  final TextEditingController _switchCountController =
      TextEditingController(text: '1');

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _clearError() {
    setState(() {
      errorMessage = null;
    });
  }

  void _updateSwitchCount() {
    if (_switchCountController.text.isNotEmpty) {
      setState(() {
        switchCount = int.tryParse(_switchCountController.text) ?? 1;
        if (switchCount > maxSwitches) {
          switchCount = maxSwitches;
          _switchCountController.text = maxSwitches.toString();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    mininetService = MininetService(context);
    _loadingService.initialize(context);
    _switchCountController.addListener(_updateSwitchCount);
  }

  @override
  void dispose() {
    _loadingService.dispose();
    _switchCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(20, 30),
        child: myAppBar(
          'Network Simulator ',
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            width: textFieldWidth(context),
            alignment: Alignment.center,
            height: heightPercentage(80, context),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: bgColor.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: AppStyles.smallWhiteTextStyle(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: _clearError,
                            ),
                          ],
                        ),
                      ),
                    Text(
                      'Create a new LAN network',
                      style: AppStyles.headerText3Style,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    gapeContainer('Select your topology'),
                    Tooltip(
                      message: 'Choose the network topology type',
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: textfieldBGColor!.withOpacity(0.2)),
                      child: SizedBox(
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
                              style:
                                  AppStyles.smallBlackTextStyle(isBold: false),
                            ),
                          ),
                          decoration: InputDecoration(
                            errorStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
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
                              return 'You must select a topology';
                            }
                            return null;
                          },
                          items: [
                            myDropdownItem('tree', 'Tree Topology'),
                            myDropdownItem('mesh', 'Mesh Topology'),
                            myDropdownItem('star', 'Star Topology'),
                            myDropdownItem('ring', 'Ring Topology'),
                            myDropdownItem('fattree', 'Fat Tree Topology'),
                          ],
                          onChanged: (val) {
                            setState(() {
                              selectedTopology = val;
                              hostsCount = 0;
                              maxHosts = TopoUtils.topologyLimits[
                                  selectedTopology]!["maxHosts"]!;
                              maxSwitches = TopoUtils.topologyLimits[
                                  selectedTopology]!["maxSwitches"]!;
                              if (switchCount > maxSwitches) {
                                switchCount = maxSwitches;
                                _switchCountController.text =
                                    maxSwitches.toString();
                              } else if (hostsCount > maxHosts) {
                                hostsCount = maxHosts;
                              }
                            });
                            log('Max Hosts: $maxHosts');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (selectedTopology == 'mesh') ...[
                      gapeContainer('Select the type of mesh'),
                      Tooltip(
                        message: 'Choose the type of mesh',
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: textfieldBGColor!.withOpacity(0.2)),
                        child: SizedBox(
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
                                style: AppStyles.smallBlackTextStyle(
                                    isBold: false),
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
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (maxSwitches != 0) ...[
                      gapeContainer('Number of hosts: $hostsCount'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Slider(
                              onChanged: (value) {
                                setState(() {
                                  hostsCount = value.toInt();
                                });
                              },
                              min: 1,
                              max: maxHosts.toDouble(),
                              label: hostsCount.toString(),
                              divisions: maxHosts - 1,
                              value: hostsCount.clamp(1, maxHosts).toDouble(),
                              activeColor: textfieldBGColor,
                              secondaryActiveColor: Colors.black,
                              thumbColor: textfieldBGColor,
                              overlayColor:
                                  const WidgetStatePropertyAll(Colors.white30),
                              inactiveColor: Colors.grey,
                            ),
                            Text(
                              'Maximum allowed: $maxHosts',
                              style: AppStyles.smallWhiteTextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 55,
            alignment: Alignment.center,
            width: widthPercentage(40, context),
            child: MyButtons.largeButton(
              context,
              'Start Network',
              _createNetwork,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            width: widthPercentage(15, context),
            alignment: Alignment.center,
            height: 55,
            child: MyButtons.smallButton('Tutorials', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Stack(
                          children: [
                            TutorialsScreen(),
                            TutorialOverlay(),
                          ],
                        )),
              );
            }, context),
          ),
        ],
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

  Future<void> _createNetwork() async {
    if (isCreatingNetwork) {
      return; // Prevent multiple simultaneous calls
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if (!context.mounted) return;

    setState(() {
      isCreatingNetwork = true;
      isLoading = true;
      _clearError();
    });
    _loadingService.showLoading();

    try {
      String status =
          mininetService.startMininet(hostsCount, selectedTopology!, meshType);
      log('Mininet start status: $status');

      if (status == 'success') {
        mininetService.listenToResponses((response) {
          if (!mounted) return;

          dynamic res;
          try {
            res = jsonDecode(response);
            log('Parsed response: $res');
          } catch (e) {
            res = response;
            log('Failed to parse response: $e');
          }

          if (res is! Map<String, dynamic>) {
            log('Invalid response format');
            _handleError('Invalid response from server');
            return;
          }

          if (res['status'] == 'success') {
            _loadingService.hideLoading();
            setState(() {
              isLoading = false;
              isCreatingNetwork = false;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TopologyScreen(
                          data: res,
                          topo: selectedTopology!,
                          meshType: meshType,
                        )));
          } else if (res['status'] == 'failed') {
            _handleError('Error: ${res['message']}');
          } else if (res['status'] == 'error') {
            log('An error occurred: ${res['message']}');
            _handleError(res['message'].toString());
          }
        });
      } else if (status == 'error') {
        _handleError('Error while starting mininet...');
      } else {
        _handleError('Server is not connected...');
      }
    } catch (e) {
      log('Error during network creation: $e');
      _handleError('An unexpected error occurred. Please try again.');
    }
  }

  void _handleError(String message) {
    if (!mounted) return;

    _loadingService.hideLoading();
    setState(() {
      isLoading = false;
      isCreatingNetwork = false;
    });
    _showError(message);
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
