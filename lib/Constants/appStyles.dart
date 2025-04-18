import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/constants.dart';

class AppStyles {
  /* TEXT STYLES */

  static TextStyle smallWhiteTextStyle({bool isBold = false}) => TextStyle(
        color: textColorWhite,
        fontWeight: isBold ? FontWeight.bold : null,
        fontSize: smallFontSize,
      );
  static TextStyle smallBlackTextStyle({bool isBold = false}) => TextStyle(
        color: textColorBlack,
        fontSize: smallFontSize,
        fontWeight: isBold ? FontWeight.bold : null,
      );

  static TextStyle mediumWhiteTextStyle({bool isBold = false}) => TextStyle(
      color: textColorWhite,
      fontSize: midFontSize,
      fontWeight: isBold ? FontWeight.bold : null,
      fontStyle: FontStyle.normal);

  static TextStyle mediumBlackTextStyle({bool isBold = false}) => TextStyle(
      color: textColorBlack,
      fontSize: midFontSize,
      fontWeight: isBold ? FontWeight.bold : null,
      fontStyle: FontStyle.normal);

  static TextStyle bigWhiteTextStyle({bool isBold = false}) => TextStyle(
        color: textColorWhite,
        fontWeight: isBold ? FontWeight.bold : null,
        fontSize: bigFontSize,
      );

  static TextStyle bigBlackTextStyle({bool isBold = false}) => TextStyle(
        color: textColorBlack,
        fontSize: bigFontSize,
        fontWeight: isBold ? FontWeight.bold : null,
      );
  static final TextStyle hugeWhiteTextStyle = TextStyle(
    color: textColorWhite,
    fontWeight: FontWeight.bold,
    fontSize: hugeFontSize,
  );
  static final TextStyle hugeBlackTextStyle = TextStyle(
    color: textColorBlack,
    fontSize: hugeFontSize,
  );

  static final TextStyle headerText1Style = TextStyle(
    color: textColorWhite,
    fontWeight: FontWeight.bold,
    fontSize: 40,
  );
  static final TextStyle headerWhiteText2Style = TextStyle(
    color: textColorWhite,
    fontWeight: FontWeight.bold,
    fontSize: 35,
  );
  static final TextStyle headerBlackText2Style = TextStyle(
    color: textColorBlack,
    fontWeight: FontWeight.bold,
    fontSize: 35,
  );
  static final TextStyle headerText3Style = TextStyle(
    color: textColorWhite,
    fontWeight: FontWeight.bold,
    fontSize: headerTextSize3,
  );
  static final TextStyle headerBlackText3Style = TextStyle(
    color: textColorBlack,
    fontSize: headerTextSize3,
  );

  /* BUTTON STYLES */

  static final ButtonStyle smallButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: mediumWhiteTextStyle(isBold: true),
  );
  static final ButtonStyle smallWhiteButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: mediumWhiteTextStyle(),
  );

  static final ButtonStyle mediumButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonColor,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: mediumBlackTextStyle(),
  );
  static final ButtonStyle mediumWhiteButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: mediumWhiteTextStyle(),
  );

  static final ButtonStyle largeButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: mediumWhiteTextStyle(),
  );
}
