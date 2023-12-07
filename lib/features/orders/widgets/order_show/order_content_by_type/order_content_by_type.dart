import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment/order_request_payment/order_request_payment_dialog_content.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/order_collection_content/order_collection_content.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/order_full_content/order_full_content.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderContentByType extends StatefulWidget {
  
  final Order order;
  final OrderContentType orderContentType;
  final void Function(Order)? onUpdatedOrder;
  final void Function(Transaction)? onRequestPayment;

  const OrderContentByType({
    super.key,
    required this.order,
    this.onUpdatedOrder,
    this.onRequestPayment,
    required this.orderContentType
  });

  @override
  State<OrderContentByType> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderContentByType> {

  Order get order => widget.order;
  ShoppableStore get store => order.relationships.store!;
  OrderContentType get orderContentType => widget.orderContentType;
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  void Function(Transaction)? get onRequestPayment => widget.onRequestPayment;

  Widget get orderContent {

    if(orderContentType == OrderContentType.orderFullContent) {

      /// Order Summary
      return OrderFullContent(
        order: order,
        onUpdatedOrder: onUpdatedOrder,
        key: ValueKey<String>(order.status.name),
      );

    }else if(orderContentType == OrderContentType.orderPaymentContent) {

      /// Order Request Payment Dialog Content
      return OrderRequestPaymentDialogContent(
        order: order,
        onRequestPayment: onRequestPayment,
        key: ValueKey<String>(order.status.name),
      );
    
    }else if(orderContentType == OrderContentType.orderCollectionContent) {
      
      /// Order Collection Content
      return OrderCollectionContent(
        order: order,
        onUpdatedOrder: onUpdatedOrder,
        key: ValueKey<String>(order.status.name),
      );
    
    }else{

      return const SizedBox();

    }

  }

  @override
  Widget build(BuildContext context) {

    return orderContent;
    
  }
}