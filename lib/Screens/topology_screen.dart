import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/Templates.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/loading_service.dart';
import 'package:network_simulator/Services/mininet_service.dart';
import 'package:network_simulator/TopologyWidgets/fat_tree_topo.dart';
import 'package:network_simulator/TopologyWidgets/mesh_topo.dart';
import 'package:network_simulator/TopologyWidgets/tree_topo.dart';
import 'package:network_simulator/Widgets/alert_dialog.dart';
import 'package:network_simulator/Widgets/app_bar.dart';
import 'package:network_simulator/Widgets/dialog_builders.dart';
import 'package:network_simulator/Widgets/path_info_dialog.dart';

import '../TopologyWidgets/star_topo.dart';

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
  late final MininetService mininetServise;
  final LoadingService _loadingService = LoadingService();
  String? lastCommand; // Track the last command sent

  Map<String, Widget> topo(Map<String, dynamic> res) => {
        'fattree': FatTreeTopology(
          mininetResponse: res,
        ),
        'mesh': MeshTopology(
          mininetResponse: res,
          meshType: widget.meshType,
        ),
        'tree': TreeTopology(mininetResponse: res),
        'star': StarTopology(
          mininetResponse: res,
        ),
        'ring': StarTopology(
          mininetResponse: res,
        )
      };

  void _handleCommand(String command) {
    if (command.isEmpty) {
      MyDialogs.showErrorSnackbar(context, 'Field is empty');
      return;
    }

    if (command.toLowerCase() == 'help') {
      _showHelpDialog();
      return;
    }

    // List of supported commands
    final supportedCommands = [
      'ping',
      'pingall',
      'ifconfig',
      'dump',
      'logs',
    ];

    // Check if the command is supported
    final commandType = command.split(' ')[0].toLowerCase().startsWith('h') ||
            command.split(' ')[0].toLowerCase().startsWith('s')
        ? command.split(' ')[1].toLowerCase()
        : command.split(' ')[0].toLowerCase();
    if (!supportedCommands.contains(commandType)) {
      MyDialogs.showErrorSnackbar(
        context,
        'Unsupported command: $commandType. Type "help" to see available commands.',
      );
      return;
    }

    _loadingService.showLoading();
    lastCommand = command; // Store the last command
    mininetServise.executeCommand(command.trim());
    setState(() => commandController.clear());
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialogCustom(
        title: 'Available Commands',
        content: DialogBuilders.buildHelpDialogContent(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    mininetServise = MininetService(context);
    _loadingService.initialize(context);
    commandController.addListener(() {});
  }

  @override
  void dispose() {
    commandController.dispose();
    _loadingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mininetServise.listenToResponses((message) {
      log("Raw message: $message");
      dynamic msg;
      try {
        msg = jsonDecode(message);
      } catch (e) {
        msg = message;
      }
      _handleWebSocketMessage(msg);
    });
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size(20, 30),
          child: myAppBar('Topology Created')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    gapeContainer(
                        'Execute commands here: (Type "help" for help)'),
                    _buildCommandInput(),
                    gapeBox,
                    _buildTopologyContainer(),
                    gapeBox,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCommandInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: textFieldHeight - 15,
        width: textFieldWidth(context),
        child: TextFormField(
          controller: commandController,
          onFieldSubmitted: _handleCommand,
          validator: (value) => value == null ? "Field is empty" : null,
          decoration: InputDecoration(
            fillColor: textfieldBGColor,
            filled: true,
            hintText: 'Type here...',
            hintStyle:
                TextStyle(fontSize: smallFontSize, color: Colors.black38),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            suffix: IconButton(
              onPressed: () => _handleCommand(commandController.text),
              icon: const Icon(Icons.send, size: 20),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              commandController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            }
          },
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }

  Widget _buildTopologyContainer() {
    return Container(
      width: widthPercentage(90, context),
      height: heightPercentage(60, context),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textfieldBGColor!.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildTopologyHeader(),
          const SizedBox(height: 20),
          topo(widget.data)[widget.topo] ?? const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildTopologyHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: textfieldBGColor!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Topology',
        style: AppStyles.mediumWhiteTextStyle(isBold: true),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: textFieldWidth(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: textFieldWidth(context),
        ),
        child: MyButtons.largeButton(context, 'Stop Network', () {
          _loadingService.showLoading();
          mininetServise.stopMininet();
          Future.delayed(const Duration(seconds: 3)).then((val) {
            _loadingService.hideLoading();
            Navigator.pop(context);
          });
        }),
      ),
    );
  }

  Widget gapeContainer(String text) => Container(
        alignment: Alignment.centerLeft,
        width: textFieldWidth(context),
        height: gapeHeight + 15,
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: AppStyles.mediumWhiteTextStyle(isBold: true),
        ),
      );

  void _handleWebSocketMessage(dynamic msg) {
    if (msg is! Map<String, dynamic>) return;

    log("Message received: $msg");
    _loadingService.hideLoading();

    switch (msg['type']) {
      case 'path_data':
        if (lastCommand?.startsWith('ping') == true && widget.topo != 'star') {
          showDialog(
            context: context,
            builder: (context) => PathInfoDialog(
              source: msg['src'] ?? 'Unknown',
              destination: msg['dst'] ?? 'Unknown',
              path: List<String>.from(msg['path'] ?? []),
              onClose: () => Navigator.of(context).pop(),
            ),
          );
        }
        break;
      case 'pingall':
        if (lastCommand == 'pingall') {
          double? dropped = msg['result'];
          if (dropped == null) return;

          showDialog(
            context: context,
            builder: (context) => AlertDialogCustom(
              title: 'Pingall Results',
              content: DialogBuilders.buildPingallContent(dropped),
            ),
          );
        }
        break;
      case 'ping':
        if (lastCommand?.startsWith('ping') == true) {
          showDialog(
            context: context,
            builder: (context) => AlertDialogCustom(
              title: 'Ping Result',
              content: DialogBuilders.buildPingContent(msg),
            ),
          );
        }
        break;
      case 'ifconfig':
        _showIfconfigDialog(msg);
        break;
      case 'logs':
        _showLogsDialog(msg);
        break;
      case 'dump':
        _showDumpDialog(msg);
        break;
      case 'command':
        _handleCommandResponse(msg);
        break;
    }
  }

  void _showIfconfigDialog(Map<String, dynamic> msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialogCustom(
        title: 'Interface Configuration',
        content: DialogBuilders.buildIfconfigContent(msg),
      ),
    );
  }

  void _showLogsDialog(Map<String, dynamic> msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialogCustom(
        title: 'System Logs',
        content: DialogBuilders.buildLogsContent(msg),
      ),
    );
  }

  void _showDumpDialog(Map<String, dynamic> msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialogCustom(
        title: 'Network Topology',
        content: DialogBuilders.buildDumpContent(msg, context),
      ),
    );
  }

  void _handleCommandResponse(Map<String, dynamic> msg) {
    if (msg['status'] == 'success') {
      MyDialogs.showSuccessSnackbar(context, 'Result: ${msg['message']}');
    } else if (msg['status'] == 'error') {
      MyDialogs.showErrorSnackbar(context, msg['message']);
    }
  }
}
