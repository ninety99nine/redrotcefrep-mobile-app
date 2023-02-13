import 'package:shared_preferences/shared_preferences.dart';
import '../enums/order_enums.dart';

class OrderServices {

  /// Get the last selected preview order mode
  /// This allows us to know what to do when swipping to the right
  /// to preview an order on the scrollable order list. We can either
  /// show a dialog that will showcase the selected order alone, or a
  /// dialog that will showcase the selected order alongside multiple
  /// other orders that are part of the same scrollable list.
  static Future<PreviewOrderMode> getSelectedPreviewOrderModeOnDevice() async {
    
    final String? name = await SharedPreferences.getInstance().then((prefs) {
      return prefs.getString('previewOrderMode');
    });

    if(name != null) {

      for (var i = 0; i < PreviewOrderMode.values.length; i++) {

        if(name == PreviewOrderMode.values[i].name) {

          /// Return selected option
          return PreviewOrderMode.values[i];

        }
        
      }

    }

    /// Return default option
    return PreviewOrderMode.singleOrder;
    
  }

  /// Get the last selected preview order mode
  /// This allows us to know what to do when swipping to the right
  /// to preview an order on the scrollable order list. We can either
  /// show a dialog that will showcase the selected order alone, or a
  /// dialog that will showcase the selected order alongside multiple
  /// other orders that are part of the same scrollable list.
  static void saveSelectedPreviewOrderModeOnDevice(PreviewOrderMode previewOrderMode) {
    
    SharedPreferences.getInstance().then((prefs) {
      return prefs.setString('previewOrderMode', previewOrderMode.name);
    });

  }
}