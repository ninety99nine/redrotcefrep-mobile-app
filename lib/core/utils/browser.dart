import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dialog.dart';

class BrowserUtility {
  
  static Future<void> launch({ required String url }) async {
    
    ///  Parse the url
    final Uri parsedUrl = Uri.parse(url);

    ///  Check if we can launch the url on the browser
    if (await canLaunchUrl(parsedUrl)) {

      ///  Launch the url on the browser
      await launchUrl(parsedUrl).whenComplete(() {
        
        /// Additional code ...

      });

    }
    
  }

}