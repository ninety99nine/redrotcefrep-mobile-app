import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment/order_request_payment/order_request_payment_dialog_content.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/close_modal_icon_button.dart';
import 'package:bonako_demo/features/stores/widgets/store_dialog_header.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderRequestPaymentDialog extends StatefulWidget {

  final Order order;
  final Function(Transaction)? onRequestPayment;

  const OrderRequestPaymentDialog({
    super.key,
    required this.order,
    this.onRequestPayment,
  });

  @override
  State<OrderRequestPaymentDialog> createState() => _OrderRequestPaymentDialogState();
}

class _OrderRequestPaymentDialogState extends State<OrderRequestPaymentDialog> {

  Order get order => widget.order;
  ShoppableStore get store => order.relationships.store!;
  Function(Transaction)? get onRequestPayment => widget.onRequestPayment;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.red,
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
                children: [
          
                  /// Store Dialog Header
                  StoreDialogHeader(store: store, padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)),
          
                  Expanded(
                    child: SingleChildScrollView(
                      child: OrderRequestPaymentDialogContent(order: order, onRequestPayment: onRequestPayment)
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