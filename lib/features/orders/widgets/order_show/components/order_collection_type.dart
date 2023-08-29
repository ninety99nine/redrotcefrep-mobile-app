import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderCollectionType extends StatelessWidget {
  
  final Order order;

  const OrderCollectionType({
    Key? key,
    required this.order
  }) : super(key: key);

  bool get hasCollectionType => order.collectionType != null;

  @override
  Widget build(BuildContext context) {

    /// Order Collection Type e.g Delivery / Pickup
    return hasCollectionType ? CustomBodyText(order.collectionType!.description, lightShade: true,) : const SizedBox();
  
  }
}