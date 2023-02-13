import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import 'dialog.dart';

class DialerUtility {
  
  static Future<void> dial({ required String number, String message = 'Dialing...', required BuildContext context }) async {

    ///  Start dialog loader
    DialogUtility.showLoader(context: context, message: message);
    
    ///  Parse the number or shortcode
    final Uri parsedNumber = Uri.parse('tel:$number');

    ///  Check if we can launch the number on to the device dialer keypad
    if (await canLaunchUrl(parsedNumber)) {

      ///  Launch the number on to the device dialer keypad
      await launchUrl(parsedNumber).whenComplete(() {
        
        ///  Stop dialog loader
        DialogUtility.hideLoader(context);

      });

    }
    
  }
}