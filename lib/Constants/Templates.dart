import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Constants.dart';
import 'appStyles.dart';

class MyButtons {
  static Widget backButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_outlined),
      color: Colors.white,
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  static Widget mediumButton(
      BuildContext context, String text, Function()? onPressed,
      {Color buttonColor = Colors.green,
      Color textColor = Colors.black,
      double height = 45}) {
    return Container(
      height: height,
      width: widthPercentage(40, context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: buttonColor,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: textColor == Colors.black
              ? AppStyles.mediumBlackTextStyle()
              : AppStyles.mediumWhiteTextStyle(),
        ),
      ),
    );
  }

  static Widget bigButton(
      BuildContext context, String text, Function() onPressed) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
          color: buttonColor, borderRadius: BorderRadius.circular(10)),
      width: widthPercentage(65, context),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: AppStyles.mediumBlackTextStyle(),
        ),
      ),
    );
  }

  Widget summaButton(Function()? onPressed) {
    return TextButton(onPressed: onPressed, child: const Text('Summa Button'));
  }
}

class MyInputFields {
  static Widget textField(
      BuildContext context,
      String? Function(String?)? validator,
      int length,
      String hint,
      Function(String)? onChanged,
      {double height = 80,
      bool expands = false,
      InputDecoration decoration = const InputDecoration(
        hintText: '',
        hintStyle: TextStyle(fontSize: 10, color: Colors.white70),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        filled: true,
        fillColor: Colors.white38,
        helperText: ' ',
      ),
      double padding = 0,
      TextInputType type = TextInputType.text}) {
    return Container(
      width: (textFieldWidth(context)),
      height: height,
      padding: EdgeInsets.all(padding),
      child: TextFormField(
        validator: validator,
        style: AppStyles.mediumBlackTextStyle(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(length),
        ],
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: onChanged,
        textAlign: TextAlign.start,
        keyboardType: type,
        minLines: null,
        maxLines: null,
        expands: expands,
        decoration: decoration,
      ),
    );
  }
}

class MyDialogs {
  static void loadingStart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const PopScope(
          canPop: false,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }

  static void closeDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
