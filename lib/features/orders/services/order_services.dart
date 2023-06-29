import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import '../../../../core/constants/constants.dart' as constants;
import 'package:bonako_demo/features/orders/models/order.dart';
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

  /// Get the customer display name to show when veiwing the specified order
  static String getCustomerDiplayName(Order order) {
    final UserOrderCollectionAssociation? userOrderCollectionAssociation = order.attributes.userOrderCollectionAssociation;
    final bool isAssociatedAsCustomer = userOrderCollectionAssociation?.role.toLowerCase() == 'customer';
    final bool isAnonymous = order.anonymous;

    /**
     *  The order.attributes.customerName can represent the actual customer name e.g "John Doe"
     *  or the text indication that the user is anonymous e.g "Anonymous", supposing that this
     *  order is being veiwed by anyone else but the customer, friend or team member. If it is
     *  anonymous but veiwed by the customer we modify the outcome to return "Me" otherwise if
     *  it is veiwed by a friend or team member the actual customer name will appear.
     */
    String diplayName = isAssociatedAsCustomer && isAnonymous ? 'Me' : order.attributes.customerName;

    /// If this order was placed anonymously
    if(order.anonymous) {

      /// Add the emoji that shows that this display name is anonymous
      diplayName += ' ${constants.anonymousEmoji}';

    }

    return diplayName;
  }
}