// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'appStyles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Wait bruh!!',
          textAlign: TextAlign.center,
          style: AppStyles.bigWhiteTextStyle(),
        ),
      ),
    );
  }
}
