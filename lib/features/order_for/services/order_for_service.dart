import 'package:shared_preferences/shared_preferences.dart';

class OrderForService {

  /// Save the order for options on to the device storage
  static saveOrderForOptionsOnDeviceStorage(List<String> orderForOptions) {
    
    SharedPreferences.getInstance().then((prefs) {

      //  Store order for options on device storage (long-term storage)
      prefs.setStringList('orderForOptions', orderForOptions);

    });

  }

  /// Get the order for options that is saved on the device storage
  static Future<List<String>> getOrderForOptionsFromDeviceStorage() async {
    
    return await SharedPreferences.getInstance().then((prefs) {

      //  Return the order for options stored on the device (long-term storage)
      return prefs.getStringList('orderForOptions') ?? [];

    });

  }

}