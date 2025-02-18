// ignore_for_file: file_names

import 'package:flutter/material.dart';

// Header Text Sizes
// ignore: non_constant_identifier_names

double widthPercentage(int width, BuildContext context) {
  double widthPercent = MediaQuery.of(context).size.width / 100 * width;
  return widthPercent;
}

double heightPercentage(int height, BuildContext context) {
  double heightPercent = MediaQuery.of(context).size.height / 100 * height;
  return heightPercent;
}

double headerTextSize1(context) => MediaQuery.of(context).size.height * 5 / 100;
double headerTextSize2 = 50;
double headerTextSize3 = 30;

// Normal Text sizes
double hugeFontSize = 25;
double bigFontSize = 20;
double midFontSize = 15;
double smallFontSize = 10;

//Colors
Color bgColor = const Color.fromARGB(255, 190, 255, 250); // Background color
var buttonColor = Colors.green; // Button Color
var textColorWhite = Colors.white; // Text color White
var textColorBlack = Colors.black;
var textfieldBGColor = Colors.white38; //Text Field BG Color

// Gape Container sizes
double gapeHeight = 30;

SizedBox gapeBox = const SizedBox(
  height: 30,
);

double gapeWidth = double.infinity;

// Text Field sizes
double textFieldHeight = 65;

double textFieldWidth(context) {
  return MediaQuery.of(context).size.width * 75 / 100;
}
