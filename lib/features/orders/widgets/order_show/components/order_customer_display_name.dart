import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderCustomerDisplayName extends StatelessWidget {
  
  final Order order;

  const OrderCustomerDisplayName({
    Key? key,
    required this.order
  }) : super(key: key);

  bool get hasCustomerDisplayName => customerDisplayName != null;
  String? get customerDisplayName => order.attributes.customerDisplayName;

  @override
  Widget build(BuildContext context) {
    return hasCustomerDisplayName ? CustomBodyText(customerDisplayName!, lightShade: true,) : const SizedBox();
  }
}