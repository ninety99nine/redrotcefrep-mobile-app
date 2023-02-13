import 'package:flutter/material.dart';

enum SnackbarMessageType {
  success,
  error,
  info
}

class SnackbarUtility {

  static showSuccessMessage({ required BuildContext context, required String message, int duration = 2 }) {
    return _show(context: context, message: message, duration: duration, type: SnackbarMessageType.success);
  }

  static showErrorMessage({ required BuildContext context, required String message, int duration = 2 }) {
    return _show(context: context, message: message, duration: duration, type: SnackbarMessageType.error);
  }

  static showInfoMessage({ required BuildContext context, required String message, int duration = 2 }) {
    return _show(context: context, message: message, duration: duration, type: SnackbarMessageType.info);
  }

  static _show({ required BuildContext context, required String message, SnackbarMessageType type = SnackbarMessageType.info, int duration = 2 }) {
    
    Color color = Colors.grey;

    if (type == SnackbarMessageType.success) {
      color = Colors.green;
    } else if (type == SnackbarMessageType.error) {
      color = Colors.red;
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed, //  Push the Floating Button Upwards when showing
      duration: Duration(seconds: duration),
      backgroundColor: color,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
  }

}