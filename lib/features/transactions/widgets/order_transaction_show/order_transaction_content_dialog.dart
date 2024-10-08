import 'package:perfect_order/features/transactions/widgets/order_transaction_show/order_transaction_content.dart';
import 'package:perfect_order/core/shared_widgets/icon_button/close_modal_icon_button.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:perfect_order/features/transactions/models/transaction.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderTransactionContentDialog extends StatefulWidget {

  final Order order;
  final Transaction transaction;
  final Function(String)? onSubmittedFile;
  final Function(Transaction)? onUpdatedTransaction;
  final Function(Transaction)? onDeletedTransaction;

  const OrderTransactionContentDialog({
    super.key,
    required this.order,
    this.onSubmittedFile,
    required this.transaction,
    this.onDeletedTransaction,
    this.onUpdatedTransaction
  });

  @override
  State<OrderTransactionContentDialog> createState() => _OrderTransactionContentDialogState();
}

class _OrderTransactionContentDialogState extends State<OrderTransactionContentDialog> {

  Order get order => widget.order;
  Transaction get transaction => widget.transaction;
  Function(String)? get onSubmittedFile => widget.onSubmittedFile;
  Function(Transaction)? get onUpdatedTransaction => widget.onUpdatedTransaction;
  Function(Transaction)? get onDeletedTransaction => widget.onDeletedTransaction;

  void _onDeletedTransaction(Transaction transaction) {

    /// Notify parent widget
    if(onDeletedTransaction != null) onDeletedTransaction!(transaction); 
    
    /// Close the dialog
    Get.back();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0)
              ),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  /// Title
                  CustomTitleLargeText('Transaction #${transaction.attributes.number}', overflow: TextOverflow.ellipsis, margin: const EdgeInsets.only(top: 16, left: 16, bottom: 16),),

                  /// Divider
                  const Divider(height: 0),
          
                  Expanded(
                    child: SingleChildScrollView(
                      child: OrderTransactionContent(
                        order: order, 
                        transaction: transaction, 
                        onSubmittedFile: onSubmittedFile,
                        onUpdatedTransaction: onUpdatedTransaction,
                        onDeletedTransaction: _onDeletedTransaction
                      )
                    )
                  ),
                  
                ],
              )
            ),
          ),
        ),
        
        /// Close Modal Icon Button
        const CloseModalIconButton(),

      ],
    );

  }
}