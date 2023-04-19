import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OrderForService {

  /// Save the order for options on to the device storage
  static saveOrderForOptionsOnDeviceStorage(List<String> orderForOptions) {
    
    SharedPreferences.getInstance().then((prefs) {

      /// Encode the order for options and expiry date
      final String orderFor = jsonEncode({
        'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'orderForOptions': orderForOptions,
      });

      //  Store order for information on device storage (long-term storage)
      prefs.setString('orderFor', orderFor);

    });

  }

  /// Get the order for options that is saved on the device storage
  static Future<List<String>> getOrderForOptionsFromDeviceStorage() async {
    
    return await SharedPreferences.getInstance().then((prefs) {

      //  Return the order for information stored on the device (long-term storage)
      final data = jsonDecode( (prefs.getString('orderFor')) ?? '{}' );

      /// Get the order for options if they exist
      final List<String> orderForOptions = List<String>.from(data['orderForOptions'] ?? []);

      /// Check if the expiry date is not yet reached
      final bool hasNotExpired = data['expiresAt'] == null ? false : DateTime.parse(data['expiresAt']).isAfter(DateTime.now());
      
      /// Check if the order for options is not empty and the expiry date is not yet reached
      if(orderForOptions.isNotEmpty && hasNotExpired) {
        
        /// Return the order for options
        return orderForOptions;

      }else{

        /// Return an empty list
        return [];

      }

    });

  }

}