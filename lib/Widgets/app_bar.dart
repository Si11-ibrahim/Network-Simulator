import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/Provider/server_provider.dart';
import 'package:provider/provider.dart';

myAppBar(String title,
    {bool showBackButton = false, List<Widget> actions = const []}) {
  return Consumer<ServerProvider>(builder: (context, provider, child) {
    return AppBar(
      leading: showBackButton
          ? const BackButton(
              color: Colors.white,
            )
          : null,
      title: Text(
        title,
        style: AppStyles.mediumWhiteTextStyle(isBold: true),
      ),
      actions: [
        Row(
          children: [
            Text(
              provider.isConnected ? 'Server Connected' : 'Server Disconnected',
              style: TextStyle(
                  color: provider.isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        )
      ],
      backgroundColor: bgColor,
    );
  });
}
