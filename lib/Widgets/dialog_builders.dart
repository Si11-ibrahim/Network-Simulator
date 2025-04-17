import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';

class DialogBuilders {
  static BoxDecoration _buildDialogDecoration() {
    return BoxDecoration(
      color: bgColor.withOpacity(0.8),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static Widget _buildDialogContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildDialogDecoration(),
      child: child,
    );
  }

  static Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: textfieldBGColor!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: color,
        size: 40,
      ),
    );
  }

  static Widget _buildScrollableContent(String content) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SingleChildScrollView(
        child: Text(
          content,
          style: AppStyles.smallBlackTextStyle(),
        ),
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppStyles.mediumWhiteTextStyle(isBold: true),
        ),
        Text(
          value,
          style: AppStyles.mediumWhiteTextStyle(),
        ),
      ],
    );
  }

  static Widget buildHelpDialogContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconContainer(Icons.help_outline, textfieldBGColor!),
            const SizedBox(height: 20),
            Text(
              'Network Commands',
              style: AppStyles.mediumWhiteTextStyle(isBold: true),
            ),
            const SizedBox(height: 20),
            _buildCommandRow('ping h1 h2', 'Ping between two hosts'),
            _buildCommandRow('pingall', 'Ping all hosts'),
            _buildCommandRow(
                'h1 ifconfig', 'Show host interface configuration'),
            _buildCommandRow('h1 logs', 'Show host system logs'),
            _buildCommandRow('dump', 'Show network topology information'),
            const SizedBox(height: 20),
            _buildHelpNote(),
          ],
        ),
      ),
    );
  }

  static Widget _buildCommandRow(String command, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: textfieldBGColor!.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              command,
              style: AppStyles.smallWhiteTextStyle(isBold: true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: AppStyles.smallWhiteTextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHelpNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note',
            style: AppStyles.mediumBlackTextStyle(isBold: true),
          ),
          const SizedBox(height: 8),
          Text(
            'Replace h1 with any host name in your topology',
            style: AppStyles.smallBlackTextStyle(),
          ),
        ],
      ),
    );
  }

  static Widget buildPathDataContent(
      Map<String, dynamic> msg, BuildContext context) {
    return _buildDialogContainer(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(Icons.route, textfieldBGColor!),
          const SizedBox(height: 20),
          Text(
            'Path Information',
            style: AppStyles.mediumWhiteTextStyle(isBold: true),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Source', msg['src']),
          const SizedBox(height: 10),
          _buildInfoRow('Destination', msg['dst']),
          const SizedBox(height: 20),
          _buildPathDetails(msg['path'], context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget _buildPathDetails(List path, BuildContext context) {
    return Container(
      width: widthPercentage(70, context),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Path',
            style: AppStyles.mediumBlackTextStyle(isBold: true),
          ),
          const SizedBox(height: 8),
          Text(
            path.join(' → '),
            style: AppStyles.mediumBlackTextStyle(),
          ),
        ],
      ),
    );
  }

  static Widget buildPingallContent(double dropped) {
    return _buildDialogContainer(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(
            dropped == 0.0 ? Icons.check_circle : Icons.error,
            dropped == 0.0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            dropped == 0.0 ? 'Pingall Successful' : 'Pingall Failed',
            style: AppStyles.mediumWhiteTextStyle(isBold: true),
          ),
          const SizedBox(height: 20),
          _buildPingallResults(dropped),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget _buildPingallResults(double dropped) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Results',
            style: AppStyles.mediumBlackTextStyle(isBold: true),
          ),
          const SizedBox(height: 8),
          Text(
            dropped == 0.0
                ? 'All packets were successfully delivered. No packets dropped.'
                : '$dropped% of packets were dropped.',
            style: AppStyles.mediumBlackTextStyle(),
          ),
        ],
      ),
    );
  }

  static Widget buildPingContent(Map<String, dynamic> msg) {
    return _buildDialogContainer(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(
            msg['status'] == 'success' ? Icons.check_circle : Icons.error,
            msg['status'] == 'success' ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            'Ping ${msg['status'] == 'success' ? 'Successful' : 'Failed'}',
            style: AppStyles.mediumWhiteTextStyle(isBold: true),
          ),
          const SizedBox(height: 20),
          _buildPingDetails(msg),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget _buildPingDetails(Map<String, dynamic> msg) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ping Result',
            style: AppStyles.mediumBlackTextStyle(isBold: true),
          ),
          const SizedBox(height: 8),
          Text(
            'Ping from ${msg['source']} to ${msg['destination']} ${msg['status']}',
            style: AppStyles.mediumBlackTextStyle(),
          ),
        ],
      ),
    );
  }

  static Widget buildIfconfigContent(Map<String, dynamic> msg) {
    return _buildDialogContainer(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(Icons.settings_ethernet, textfieldBGColor!),
          const SizedBox(height: 20),
          Text(
            '${msg['host']} Configuration',
            style: AppStyles.mediumWhiteTextStyle(isBold: true),
          ),
          const SizedBox(height: 20),
          _buildScrollableContent(msg['result']),
        ],
      ),
    );
  }

  static Widget buildLogsContent(Map<String, dynamic> msg) {
    return _buildDialogContainer(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(Icons.list_alt, textfieldBGColor!),
          const SizedBox(height: 20),
          Text(
            '${msg['host']} System Logs',
            style: AppStyles.mediumWhiteTextStyle(isBold: true),
          ),
          const SizedBox(height: 20),
          _buildScrollableContent(msg['result']),
        ],
      ),
    );
  }

  static Widget buildDumpContent(
      Map<String, dynamic> msg, BuildContext context) {
    return _buildDialogContainer(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(Icons.device_hub, textfieldBGColor!),
          const SizedBox(height: 20),
          Text(
            'Network Information',
            style: AppStyles.mediumWhiteTextStyle(isBold: true),
          ),
          const SizedBox(height: 20),
          Container(
            height: heightPercentage(25, context),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              child: Text(
                msg['result'],
                style: AppStyles.smallBlackTextStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
