import 'package:shared_preferences/shared_preferences.dart';

class AiService {

  /// Save the AI message category id on to the device storage
  static Future<bool> saveAiMessageCategoryIdOnDeviceStorage(int aiMessageCategoryId) async {
    
    return await SharedPreferences.getInstance().then((prefs) {

      //  Store AI message category id on device storage (long-term storage)
      return prefs.setInt('aiMessageCategoryId', aiMessageCategoryId);

    });

  }

  /// Get the AI message category id that is saved on the device storage
  static Future<int?> getAiMessageCategoryIdFromDeviceStorage() async {
    
    return await SharedPreferences.getInstance().then((prefs) {

      //  Return the AI message category id stored on the device (long-term storage)
      return prefs.getInt('aiMessageCategoryId');

    });

  }

}