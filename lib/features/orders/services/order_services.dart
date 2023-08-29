import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/features/transactions/widgets/transaction_status.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/browser.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class OrderServices {

  void sharePaymentLink(Order order, Transaction transaction) {
    
    final ShoppableStore store = order.relationships.store!;
    
    final String message = '${store.name} 👋,\n\n${order.summary}\n\nTotal:${transaction.amount.amountWithCurrency}\n\nPlease use this link to pay using any card\n\n${transaction.dpoPaymentUrl}';

    Share.share(message, subject: 'Order #${order.attributes.number} Payment Link');
    
  }

  void launchPaymentLink(Transaction transaction, BuildContext context) {
    BrowserUtility.launch(url: transaction.dpoPaymentUrl!);
  }

  showTransactionDialog(Transaction transaction, Order order, BuildContext context) {

    final bool isPendingPayment = transaction.attributes.isPendingPayment;
    final User requestingUser = transaction.relationships.requestingUser!;
    final User payingUser = transaction.relationships.payingUser!;
    final bool requesterIsNotPayer = payingUser.id != requestingUser.id;
    final bool isPayingUser = payingUser.id == requestingUser.id;
    final bool isPaid = transaction.attributes.isPaid;

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
          if(requesterIsNotPayer) Row(
            children: [
              const CustomBodyText('Requester:', margin: EdgeInsets.only(right: 8),),
              CustomBodyText(requestingUser.attributes.name)
            ],
          ),
          if(isPaid) ...[
            Row(
              children: [
                const CustomBodyText('Paid Date:', margin: EdgeInsets.only(right: 8),),
                CustomBodyText(DateFormat('dd MMM yyyy HH:mm').format(transaction.updatedAt))
              ],
            ),
          ],
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