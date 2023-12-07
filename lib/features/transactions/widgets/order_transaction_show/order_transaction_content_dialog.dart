import 'package:bonako_demo/features/transactions/widgets/order_transaction_show/order_transaction_content.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/close_modal_icon_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderTransactionContentDialog extends StatefulWidget {

  final Order order;
  final Transaction transaction;
  final Function(String)? onSubmittedFile;
  final Function(Transaction)? onUpdatedTransaction;

  const OrderTransactionContentDialog({
    super.key,
    required this.order,
    this.onSubmittedFile,
    required this.transaction,
    required this.onUpdatedTransaction
  });

  @override
  State<OrderTransactionContentDialog> createState() => _OrderTransactionContentDialogState();
}

class _OrderTransactionContentDialogState extends State<OrderTransactionContentDialog> {

  Order get order => widget.order;
  Transaction get transaction => widget.transaction;
  Function(String)? get onSubmittedFile => widget.onSubmittedFile;
  Function(Transaction)? get onUpdatedTransaction => widget.onUpdatedTransaction;

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
                        onUpdatedTransaction: onUpdatedTransaction
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