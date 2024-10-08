import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/core/shared_models/mobile_number.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:perfect_order/core/shared_models/user.dart';
import 'package:flutter/material.dart';

class OrderCustomerMobileNumber extends StatelessWidget {
  
  final Order order;

  const OrderCustomerMobileNumber({
    Key? key,
    required this.order
  }) : super(key: key);

  bool get hasMobileNumber => mobileNumber != null;
  User get customer => order.relationships.customer!;
  MobileNumber? get mobileNumber => customer.mobileNumber;

  @override
  Widget build(BuildContext context) {
    return hasMobileNumber ? CustomBodyText(mobileNumber!.withoutExtension, lightShade: true,) : const SizedBox();
  }
}