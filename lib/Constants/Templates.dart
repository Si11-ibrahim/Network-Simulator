import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Constants.dart';
import 'appStyles.dart';

class MyButtons {
  static Widget backButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: buttonColor,
      onPressed: () => Navigator.pop(context),
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

  static Widget largeButton(
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
          style: AppStyles.mediumBlackTextStyle(isBold: true),
        ),
      ),
    );
  }

  static Widget smallButton(text, Function()? onPressed, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: buttonColor, borderRadius: BorderRadius.circular(10)),
      height: 45,
      width: textFieldWidth(context) * 0.7,
      child: TextButton(
        onPressed: onPressed,
        style:
            ButtonStyle(backgroundColor: WidgetStatePropertyAll(buttonColor)),
        child: text is String
            ? Text(
                text,
                style: AppStyles.mediumBlackTextStyle(isBold: true),
              )
            : text,
      ),
    );
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
      EdgeInsets containerPadding = EdgeInsets.zero,
      TextInputType type = TextInputType.text,
      Widget? suffix,
      TextEditingController? controller}) {
    return Container(
      alignment: Alignment.topCenter,
      width: (textFieldWidth(context)),
      height: height,
      padding: containerPadding,
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: AppStyles.mediumBlackTextStyle(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(length),
        ],
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: onChanged,
        keyboardType: type,
        minLines: null,
        maxLines: null,
        expands: expands,
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            filled: true,
            fillColor: textfieldBGColor,
            helperText: ' ',
            suffix: suffix),
      ),
    );
  }
}

class MyDialogs {
  static void loadingStart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Colors.green,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.transparent,
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  static void closeDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static showErrorSnackbar(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
          ),
        )));
  }

  static showSuccessSnackbar(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: textfieldBGColor,
        duration: const Duration(seconds: 5),
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
          ),
        )));
  }
}
