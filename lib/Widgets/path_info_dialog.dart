import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';

class PathInfoDialog extends StatelessWidget {
  final String source;
  final String destination;
  final List<String> path;
  final VoidCallback onClose;

  const PathInfoDialog({
    super.key,
    required this.source,
    required this.destination,
    required this.path,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widthPercentage(45, context),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: textfieldBGColor!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.route,
                    color: textfieldBGColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Path Information',
                  style: AppStyles.mediumWhiteTextStyle(isBold: true),
                ),
                const SizedBox(height: 20),
                _buildInfoRow('Source', source),
                const SizedBox(height: 10),
                _buildInfoRow('Destination', destination),
                const SizedBox(height: 20),
                Container(
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
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: widthPercentage(50, context),
                  child: ElevatedButton(
                    onPressed: onClose,
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
            ),
          ),
        ),
      ),
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
