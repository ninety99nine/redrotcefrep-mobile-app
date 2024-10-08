import 'package:perfect_order/features/orders/widgets/order_show/order_content_by_type/order_content_by_type.dart';
import 'package:perfect_order/core/shared_widgets/icon_button/close_modal_icon_button.dart';
import 'package:perfect_order/features/stores/widgets/store_dialog_header.dart';
import 'package:perfect_order/features/transactions/models/transaction.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderContentByTypeDialog extends StatefulWidget {

  final Order order;
  final bool showCloseButton;
  final OrderContentType orderContentType;
  final void Function(Order)? onUpdatedOrder;
  final void Function(Transaction)? onRequestPayment;

  const OrderContentByTypeDialog({
    super.key,
    required this.order,
    this.onUpdatedOrder,
    this.onRequestPayment,
    this.showCloseButton = true,
    required this.orderContentType
  });

  @override
  State<OrderContentByTypeDialog> createState() => _OrderRequestPaymentDialogState();
}

class _OrderRequestPaymentDialogState extends State<OrderContentByTypeDialog> {

  Order get order => widget.order;
  bool get showCloseButton => widget.showCloseButton;
  ShoppableStore get store => order.relationships.store!;
  OrderContentType get orderContentType => widget.orderContentType;
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  void Function(Transaction)? get onRequestPayment => widget.onRequestPayment;

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
                      child: OrderContentByType(
                        order: order, 
                        onUpdatedOrder: onUpdatedOrder,
                        onRequestPayment: onRequestPayment,
                        orderContentType: orderContentType
                      )
                    )
                  ),
                  
                ],
              )
            ),
          ),
        ),
        
        /// Close Modal Icon Button
        if(showCloseButton) const CloseModalIconButton(),

      ],
    );

  }
}