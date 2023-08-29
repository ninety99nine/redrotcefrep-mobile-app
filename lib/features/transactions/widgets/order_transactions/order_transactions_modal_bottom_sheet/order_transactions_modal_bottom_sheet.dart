import 'package:bonako_demo/features/transactions/enums/transaction_enums.dart';
import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_content.dart';
import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderTransactionsModalBottomSheet extends StatefulWidget {
  
  final Order order;
  final Transaction? transaction;
  final Widget Function(void Function())? trigger;
  final TransactionContentView? transactionContentView;

  const OrderTransactionsModalBottomSheet({
    super.key,
    this.trigger,
    this.transaction,
    required this.order,
    this.transactionContentView
  });

  @override
  State<OrderTransactionsModalBottomSheet> createState() => _OrderTransactionsModalBottomSheetState();
}

class _OrderTransactionsModalBottomSheetState extends State<OrderTransactionsModalBottomSheet> {

  Order get order => widget.order;
  Transaction? get transaction => widget.transaction;
  Widget Function(void Function())? get trigger => widget.trigger;
  TransactionContentView? get transactionContentView => widget.transactionContentView;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    if(trigger != null) {

      /// Return the custom trigger
      return trigger!(openBottomModalSheet);

    }else{

      /// Return the total transactions and total transactions text
      return CustomElevatedButton(
        'Pay Now',
        width: 120,
        prefixIcon: Icons.payment,
        alignment: Alignment.center,
        onPressed: openBottomModalSheet,
      );

    }

  }

  /// Open the bottom modal sheet to show the new order placed
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: OrderTransactionsContent(
        order: order,
        transaction: transaction,
        transactionContentView: transactionContentView
      ),
    );
  }
}