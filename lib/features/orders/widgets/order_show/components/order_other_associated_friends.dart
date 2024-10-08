import 'package:perfect_order/core/shared_widgets/button/custom_text_button.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderOtherAssociatedFriends extends StatelessWidget {
  
  final Order order;

  const OrderOtherAssociatedFriends({
    Key? key,
    required this.order
  }) : super(key: key);

  bool get hasOtherAssociatedFriends => otherAssociatedFriends != null;
  String? get otherAssociatedFriends => order.attributes.otherAssociatedFriends;

  @override
  Widget build(BuildContext context) {

    /// Other Associated Friends e.g "+ 2 friends" or "for 2 friends"
    return hasOtherAssociatedFriends ? CustomTextButton(otherAssociatedFriends!, padding: EdgeInsets.zero) : const SizedBox();
  
  }
}