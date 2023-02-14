import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarMessageType {
  success,
  error,
  info
}

class SnackbarUtility {

  static showSuccessMessage({ String? title, required String message, int duration = 2 }) {
    return _show(title: title, message: message, duration: duration, type: SnackbarMessageType.success);
  }

  static showErrorMessage({ String? title, required String message, int duration = 2 }) {
    return _show(title: title, message: message, duration: duration, type: SnackbarMessageType.error);
  }

  static showInfoMessage({ String? title, required String message, int duration = 2 }) {
    return _show(title: title, message: message, duration: duration, type: SnackbarMessageType.info);
  }

  static _show({ String? title, required String message, SnackbarMessageType type = SnackbarMessageType.info, int duration = 2 }) {
    
    IconData? icon;
    Color color = Colors.grey;

    if (type == SnackbarMessageType.success) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (type == SnackbarMessageType.error) {
      color = Colors.red;
      icon = Icons.error;
    }else{
      icon = Icons.info;
    }

    final bool hasTitle = title != null;
    final Widget titleText = CustomTitleSmallText(title ?? '', color: Colors.white);
    final Widget messageText = CustomBodyText(message, color: Colors.white);

    Get.snackbar(
      '',
      '',
      borderRadius: 32,
      backgroundColor: color,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
      icon: Icon(icon, color: Colors.white,),
      messageText: hasTitle ? messageText : null,
      titleText: hasTitle ? titleText : messageText,
      padding: EdgeInsets.only(top: 24.0, bottom: hasTitle ? 24.0 : 0.0, left: 24.0, right: 24.0)
    );
    
  }

}