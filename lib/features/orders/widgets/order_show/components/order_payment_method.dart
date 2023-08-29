import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderPaymentMethod extends StatelessWidget {
  
  final Order order;

  const OrderPaymentMethod({
    Key? key,
    required this.order
  }) : super(key: key);

  bool get hasPaymentMethod => paymentMethod != null;
  PaymentMethod? get paymentMethod => order.relationships.paymentMethod;

  @override
  Widget build(BuildContext context) {

    /// Order Payment Method e.g Cash
    return hasPaymentMethod ? CustomBodyText(paymentMethod!.name, height: 1, lightShade: true,) : const SizedBox();

  }
}