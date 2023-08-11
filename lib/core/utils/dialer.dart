import 'package:url_launcher/url_launcher.dart';

class DialerUtility {
  
  static Future<void> dial({ required String number }) async {

    /**
     *  We need to use URL encoding for converting special characters within our number.
     *  This will convert special characters such as "#" to "%23". This will allow us
     *  to properly dial shortcodes e.g *123#
     */
    number = Uri.encodeComponent(number);
    
    ///  Parse the number or shortcode
    final Uri parsedNumber = Uri.parse('tel:$number');

    ///  Check if we can launch the number on to the device dialer keypad
    if (await canLaunchUrl(parsedNumber)) {

      ///  Launch the number on to the device dialer keypad
      await launchUrl(parsedNumber).whenComplete(() {

          /// Do something else ...

      });

    }
    
  }

}