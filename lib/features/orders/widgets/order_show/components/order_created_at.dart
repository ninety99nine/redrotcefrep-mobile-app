import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class OrderCreatedAt extends StatelessWidget {
  
  final Order order;
  final bool short;

  const OrderCreatedAt({
    Key? key,
    this.short = false,
    required this.order
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    /// Order Payment Method e.g about an hour ago
    return CustomBodyText(timeago.format(order.createdAt, locale: short ? 'en_short' : null), lightShade: true);
  
  }
}