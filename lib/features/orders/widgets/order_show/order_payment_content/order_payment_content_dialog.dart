import 'package:perfect_order/features/orders/widgets/order_show/order_collection_content/order_collection_content.dart';
import 'package:perfect_order/core/shared_widgets/icon_button/close_modal_icon_button.dart';
import 'package:perfect_order/features/orders/widgets/order_show/order_payment_content/order_payment_content.dart';
import 'package:perfect_order/features/stores/widgets/store_dialog_header.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderPaymentContentDialog extends StatefulWidget {

  final Order order;
  final Function(Order)? onUpdatedOrder;

  const OrderPaymentContentDialog({
    super.key,
    required this.order,
    this.onUpdatedOrder,
  });

  @override
  State<OrderPaymentContentDialog> createState() => _OrderRequestPaymentDialogState();
}

class _OrderRequestPaymentDialogState extends State<OrderPaymentContentDialog> {

  Order get order => widget.order;
  ShoppableStore get store => order.relationships.store!;
  Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;

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
                children: [
          
                  /// Store Dialog Header
                  StoreDialogHeader(store: store, padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)),
          
                  Expanded(
                    child: SingleChildScrollView(
                      child: OrderPaymentContent(order: order, onUpdatedOrder: onUpdatedOrder)
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