import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_content.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/transactions/enums/transaction_enums.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderTransactionsDialog extends StatefulWidget {
  
  final Order order;
  final ShoppableStore store;
  final Transaction? transaction;
  final Widget Function(void Function())? trigger;
  final TransactionContentView? transactionContentView;

  const OrderTransactionsDialog({
    super.key,
    this.trigger,
    this.transaction,
    required this.store,
    required this.order,
    this.transactionContentView
  });

  @override
  State<OrderTransactionsDialog> createState() => _OrderTransactionsDialogState();
}

class _OrderTransactionsDialogState extends State<OrderTransactionsDialog> {

  Order get order => widget.order;
  ShoppableStore get store => widget.store;
  bool get isPaid => order.attributes.isPaid;
  Transaction? get transaction => widget.transaction;
  Widget Function(void Function())? get trigger => widget.trigger;
  TransactionContentView? get transactionContentView => widget.transactionContentView;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  Widget get _trigger {

    if(trigger != null) {

      /// Return the custom trigger
      return trigger!(openDialog);

    }else{

      /// Return the total transactions and total transactions text
      return CustomElevatedButton(
        'BonakoPay',
        width: 120,
        onPressed: openDialog,
        prefixIcon: Icons.payment,
        alignment: Alignment.center,
      );

    }

  }

  void openDialog() {

    /// Open the dialog to show the order transactions content
    DialogUtility.showInfiniteScrollContentDialog(
      context: context,
      heightRatio: 0.9,
      showCloseIcon: false,
      content: OrderTransactionsContent(
        order: order,
        store: store,
        transaction: transaction,
        transactionContentView: transactionContentView ?? (isPaid ? TransactionContentView.viewingTransactions : TransactionContentView.requestPayment)
      )
    );

  }

  @override
  Widget build(BuildContext context) {
    return _trigger;
  }
}