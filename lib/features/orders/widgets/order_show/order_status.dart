import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class OrderStatus extends StatelessWidget {
  
  final String status;
  final bool lightShade;
  final String dotPlacement;

  const OrderStatus({
    super.key,
    required this.status,
    this.lightShade = false,
    this.dotPlacement = 'left',
  });

  Color get dotColor {

    /// If this order is completed
    if(status.toLowerCase() == 'completed') {
      
      return Colors.green;

    /// If this order is cancelled
    }else if(status.toLowerCase() == 'cancelled') {
      
      return Colors.red;

    /// If this order is waiting
    }else if(status.toLowerCase() == 'waiting') {
      
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
          const SizedBox(width: 8,),
        ],
        
        /// Status
        CustomBodyText(status, lightShade: lightShade),

        /// Right Dot 
        if(dotPlacement == 'right') ...[
          const SizedBox(width: 8,),
          dotWidget,
        ],
        
      ],
    );
  }
}