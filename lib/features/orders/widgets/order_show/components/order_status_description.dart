import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderStatusDescription extends StatelessWidget {
  
  final Order order;

  const OrderStatusDescription({
    super.key,
    required this.order
  });

  String get statusDescription => order.status.description;

  @override
  Widget build(BuildContext context) {
    return CustomBodyText(
      statusDescription,
      lightShade: true,
      margin: const EdgeInsets.only(bottom: 8),  
    );
  }
}