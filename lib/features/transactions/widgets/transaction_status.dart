import 'package:perfect_order/features/transactions/models/transaction.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class TransactionStatus extends StatelessWidget {
  
  final bool lightShade;
  final String dotPlacement;
  final Transaction transaction;

  const TransactionStatus({
    super.key,
    this.lightShade = false,
    required this.transaction,
    this.dotPlacement = 'left',
  });

  Color get dotColor {

    /// If this transaction is paid
    if(transaction.attributes.isPaid) {
      
      return Colors.green;

    /// If this transaction is pending payment
    }else if(transaction.attributes.isPendingPayment) {
      
      return Colors.orange;

    /// If any other status
    }else {
      
      return Colors.grey;

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
        CustomBodyText(transaction.paymentStatus.name, lightShade: lightShade),

        /// Right Dot 
        if(dotPlacement == 'right') ...[
          const SizedBox(width: 8,),
          dotWidget,
        ],
        
      ],
    );
  }
}