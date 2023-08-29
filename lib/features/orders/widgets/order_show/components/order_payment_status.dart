import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderPaymentStatus extends StatelessWidget {
  
  final Order order;
  final bool lightShade;
  final String dotPlacement;

  const OrderPaymentStatus({
    super.key,
    required this.order,
    this.lightShade = false,
    this.dotPlacement = 'left',
  });

  String get paymentStatus => order.paymentStatus.name;

  Color get dotColor {

    /// If this order is paid
    if(paymentStatus.toLowerCase() == 'paid') {
      
      return Colors.green;

    /// If this order is unpaid
    }else if(paymentStatus.toLowerCase() == 'unpaid') {
      
      return Colors.grey.shade300;

    /// If this order is partially paid
    }else if(paymentStatus.toLowerCase() == 'partially paid') {
      
      return Colors.orange;

    /// If this order is pending payment
    }else if(paymentStatus.toLowerCase() == 'pending payment') {
      
      return Colors.orange;

    /// If any other status
    }else {
      
      return Colors.blue;

    }

  }

  Widget get dotWidget {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: dotColor,
        borderRadius: BorderRadius.circular(4)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        /// Left Dot 
        if(dotPlacement == 'left') ...[
          dotWidget,
          const SizedBox(width: 4,),
        ],
        
        /// Status
        CustomBodyText(paymentStatus, lightShade: lightShade),

        /// Right Dot 
        if(dotPlacement == 'right') ...[
          const SizedBox(width: 4,),
          dotWidget,
        ],
        
      ],
    );
  }
}