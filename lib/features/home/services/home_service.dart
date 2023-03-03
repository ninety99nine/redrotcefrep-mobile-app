import 'package:shared_preferences/shared_preferences.dart';

class HomeService {

  /// Save the selected home tab index on to the device storage
  static saveSelectedHomeTabIndexOnDeviceStorage(int index) {
    
    SharedPreferences.getInstance().then((prefs) {

      //  Store selected home tab index on device storage (long-term storage)
      prefs.setInt('selectedHomeTabIndex', index);

    });

  }

  /// Get the selected home tab index that is saved on the device storage
  static Future<int> getSelectedHomeTabIndexFromDeviceStorage() async {
    
    return await SharedPreferences.getInstance().then((prefs) {

      //  Return the selected home tab index stored on the device (long-term storage)
      return prefs.getInt('selectedHomeTabIndex') ?? 0;

    });

  }

}