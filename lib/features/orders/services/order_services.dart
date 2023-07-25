import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/utils/browser.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/transactions/widgets/transaction_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
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

  void sharePaymentLink(Order order, Transaction transaction) {
    Share.share(transaction.dpoPaymentUrl!, subject: 'Order #${order.attributes.number} Payment Link');
  }

  void launchPaymentLink(Transaction transaction, BuildContext context) {
    BrowserUtility.launch(url: transaction.dpoPaymentUrl!);
  }

  showTransactionDialog(Transaction transaction, Order order, BuildContext context) {

    final bool isPendingPayment = transaction.attributes.isPendingPayment;
    final User requestingUser = transaction.relationships.requestingUser!;
    final User payingUser = transaction.relationships.payingUser!;
    final bool isPayingUser = payingUser.id == requestingUser.id;

    DialogUtility.showContentDialog(
      context: context,
      title: 'Transaction #${transaction.attributes.number}',
      content: Column(
        children: [
          Row(
            children: [
              const CustomBodyText('Payer:', margin: EdgeInsets.only(right: 8),),
              CustomBodyText(payingUser.attributes.name)
            ],
          ),
          Row(
            children: [
              const CustomBodyText('Requester:', margin: EdgeInsets.only(right: 8),),
              CustomBodyText(requestingUser.attributes.name)
            ],
          ),
          Row(
            children: [
              const CustomBodyText('Status:', margin: EdgeInsets.only(right: 8),),
              TransactionStatus(transaction: transaction)
            ],
          ),
          const SizedBox(height: 16,),
          Row(
            children: [
              CustomTitleLargeText(transaction.amount.amountWithCurrency)
            ],
          ),
          const Divider(),
          CustomBodyText(transaction.description)
        ],
      ),
      actions: [
        if(isPendingPayment) Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            if(isPayingUser) ...[

              /// Pay For Me
              CustomElevatedButton('Pay For Me', 
                color: Colors.grey,
                suffixIcon: Icons.share_rounded,
                onPressed: () {
                  Get.back(closeOverlays: true);
                  sharePaymentLink(order, transaction);
                },
              ),

              /// Spacer
              const SizedBox(width: 8,),

              /// Pay Now
              CustomElevatedButton(
                'Pay Now',
                onPressed: () {
                  Get.back(closeOverlays: true);
                  launchPaymentLink(transaction, context);
                }
              ),

            ],

            if(!isPayingUser) ...[

              /// Pay Yourself
              CustomElevatedButton(
                'Pay Yourself', 
                color: Colors.grey,
                onPressed: () {
                  Get.back(closeOverlays: true);
                  launchPaymentLink(transaction, context);
                },
              ),

              /// Spacer
              const SizedBox(width: 8,),

              /// Share
              CustomElevatedButton('Share', 
                suffixIcon: Icons.share_rounded,
                onPressed: () {
                  Get.back(closeOverlays: true);
                  sharePaymentLink(order, transaction);
                }
              )
            ]
          ],
        )
      ]
    );
  }
}