import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderDestinationName extends StatelessWidget {
  
  final Order order;

  const OrderDestinationName({
    Key? key,
    required this.order
  }) : super(key: key);

  bool get hasDestinationName => order.destinationName != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: hasDestinationName ? [

        /// Destination Name e.g Gaborone
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CustomBodyText('Location: ', lightShade: true,),
            CustomTitleSmallText(order.destinationName!),
          ],
        ),

        /// Spacer
        const SizedBox(height: 16,),

      ] : [],
    );
  }
}