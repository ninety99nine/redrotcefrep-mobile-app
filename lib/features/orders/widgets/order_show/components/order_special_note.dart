import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderSpecialNote extends StatelessWidget {
  
  final Order order;

  const OrderSpecialNote({
    super.key,
    required this.order
  });

  String? get specialNote => order.specialNote;
  bool get hasSpecialNote => specialNote != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(hasSpecialNote) Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Icon
            const Icon(Icons.star, color: Colors.orange, size: 20,),

            /// Spacer
            const SizedBox(width: 8.0,),

            /// Speacial Note
            Expanded(
              child: CustomBodyText(
                specialNote,
                lightShade: true,
                margin: const EdgeInsets.only(bottom: 8),  
              ),
            ),

          ],
        ),
      ],
    );
  }
}