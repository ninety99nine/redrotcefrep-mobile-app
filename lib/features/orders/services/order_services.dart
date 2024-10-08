import 'package:perfect_order/features/orders/widgets/order_show/order_content_by_type/order_content_by_type_dialog.dart';
import 'package:perfect_order/features/transactions/widgets/order_transaction_show/order_transaction_content_dialog.dart';
import 'package:perfect_order/features/orders/providers/order_provider.dart';
import 'package:perfect_order/features/transactions/models/transaction.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:perfect_order/core/utils/snackbar.dart';
import 'package:perfect_order/core/utils/browser.dart';
import 'package:perfect_order/core/utils/dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
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

  void showOrderDialogViaUrl({ required String orderUrl, required OrderContentType orderContentType, required OrderProvider orderProvider, required BuildContext context, required void Function() onStartLoader, required void Function() onStopLoader, void Function(Order)? onUpdatedOrder, void Function(Transaction)? onRequestPayment }) async {

    onStartLoader();

    orderProvider.orderRepository.showOrder(
      url: orderUrl,
      withCart: true,
      withStore: true,
      withCustomer: true,
      withOccasion: true,
      withDeliveryAddress: true,
      withCountTransactions: true,
    ).then((response) async {

      if(response.statusCode == 200) {

      final order = Order.fromJson(response.data);

        DialogUtility.showInfiniteScrollContentDialog(
          context: context,
          heightRatio: 0.9,
          showCloseIcon: false,
          backgroundColor: Colors.transparent,
          content: OrderContentByTypeDialog(
            order: order,
            onUpdatedOrder: onUpdatedOrder,
            onRequestPayment: onRequestPayment,
            orderContentType: orderContentType
          )
        );

      }

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to show order');

    }).whenComplete(() {

      onStopLoader();

    });

  }

  showOrderTransactionDialog({ required Transaction transaction, required Order order, Function(Transaction)? onUpdatedTransaction, Function(Transaction)? onDeletedTransaction, Function(String)? onSubmittedFile, required BuildContext context }) {

    /// If this transaction is subject to user verification, then we can increase the dialog height ratio
    /// since we would want to show the proof of payment. It makes it much easier to see the transaction
    /// details together with the proof of payment photo. If this transaction is subject to system 
    /// verification, then the dialog height ratio can be lower since we don't need to display
    /// any proof of payment photo. 
    bool isSubjectToUserVerification = transaction.attributes.isSubjectToUserVerification;

    DialogUtility.showInfiniteScrollContentDialog(
      context: context,
      showCloseIcon: false,
      backgroundColor: Colors.transparent,
      heightRatio: isSubjectToUserVerification ? 0.8 : 0.6,
      content: OrderTransactionContentDialog(
        order: order,
        transaction: transaction,
        onSubmittedFile: onSubmittedFile,
        onUpdatedTransaction: onUpdatedTransaction,
        onDeletedTransaction: onDeletedTransaction
      )
    );

  }
}