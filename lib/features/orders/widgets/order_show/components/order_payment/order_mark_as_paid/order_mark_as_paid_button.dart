import 'package:perfect_order/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:perfect_order/core/utils/dialog.dart';
import 'order_mark_as_paid_dialog.dart';
import 'package:flutter/material.dart';

class OrderMarkAsPaidButton extends StatefulWidget {
  
  final Order order;
  final Function()? onMarkedAsPaid;

  const OrderMarkAsPaidButton({
    Key? key,
    required this.order,
    this.onMarkedAsPaid
  }) : super(key: key);

  @override
  State<OrderMarkAsPaidButton> createState() => _OrderMarkAsPaidButtonState();
}

class _OrderMarkAsPaidButtonState extends State<OrderMarkAsPaidButton> {

  Order get order => widget.order;
  Function()? get onMarkedAsPaid => widget.onMarkedAsPaid;
  bool get canMarkAsPaid => order.attributes.canMarkAsPaid;


  Widget get markAsPaidButton {
    return CustomElevatedButton(
      width: 100,
      fontSize: 12,
      'Mark As Paid',
      prefixIcon: Icons.check_circle_sharp,
      onPressed: () {
        
        DialogUtility.showContentDialog(
          context: context,
          content: MarkAsPaidDialog(
            order: order,
            onMarkedAsPaid: onMarkedAsPaid,
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        if(canMarkAsPaid) markAsPaidButton
      ],
    );
  }
}