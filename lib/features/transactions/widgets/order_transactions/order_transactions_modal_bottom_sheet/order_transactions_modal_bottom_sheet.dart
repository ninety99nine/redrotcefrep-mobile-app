import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_content.dart';
import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/transactions/enums/transaction_enums.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:flutter/material.dart';

class OrderTransactionsModalBottomSheet extends StatefulWidget {
  
  final Order order;
  final User? paidByUser;
  final Transaction? transaction;
  final String? transactionFilter;
  final Widget Function(Function())? trigger;
  final Function(Transaction, String)? onSubmittedFile;
  final TransactionContentView? transactionContentView;

  const OrderTransactionsModalBottomSheet({
    super.key,
    this.trigger,
    this.paidByUser,
    this.transaction,
    required this.order,
    this.onSubmittedFile,
    this.transactionFilter,
    this.transactionContentView,
  });

  @override
  State<OrderTransactionsModalBottomSheet> createState() => _OrderTransactionsModalBottomSheetState();
}

class _OrderTransactionsModalBottomSheetState extends State<OrderTransactionsModalBottomSheet> {

  Order get order => widget.order;
  User? get paidByUser => widget.paidByUser;
  Transaction? get transaction => widget.transaction;
  String? get transactionFilter => widget.transactionFilter;
  Widget Function(Function())? get trigger => widget.trigger;
  Function(Transaction, String)? get onSubmittedFile => widget.onSubmittedFile;
  TransactionContentView? get transactionContentView => widget.transactionContentView;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    final Widget defaultTrigger = CustomElevatedButton(
      'Transactions', 
      onPressed: openBottomModalSheet,
    );

    return trigger == null ? defaultTrigger : trigger!(openBottomModalSheet);
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
        paidByUser: paidByUser,
        transaction: transaction,
        onSubmittedFile: onSubmittedFile,
        transactionFilter: transactionFilter,
        transactionContentView: transactionContentView
      ),
    );
  }
}