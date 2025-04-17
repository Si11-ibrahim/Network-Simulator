import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';

class AlertDialogCustom extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const AlertDialogCustom({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: SingleChildScrollView(child: content),
      actionsAlignment: MainAxisAlignment.center,
      actions: actions ??
          [
            SizedBox(
              width: widthPercentage(20, context),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Close',
                  style: AppStyles.mediumBlackTextStyle(),
                ),
              ),
            ),
          ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
}
