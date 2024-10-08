import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/features/addresses/models/delivery_address.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/core/shared_widgets/cards/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryAddressCard extends StatefulWidget {

  final DeliveryAddress deliveryAddress;
  
  const DeliveryAddressCard({
    super.key,
    required this.deliveryAddress
  });

  @override
  State<DeliveryAddressCard> createState() => _DeliveryAddressCardState();
}

class _DeliveryAddressCardState extends State<DeliveryAddressCard> {

  DeliveryAddress get deliveryAddress => widget.deliveryAddress;
  bool get hasAddressline => deliveryAddress.addressLine != null;

  Widget get addressContent {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        /// Address Title
        Row(
          children: [
              
            /// Location Icon
            Icon(Icons.location_pin, size: 16, color: Colors.red.shade700),
      
            /// Spacer
            const SizedBox(width: 4,),
            
            /// Address Type e.g Home / Work / Grannys House
            CustomTitleSmallText(deliveryAddress.name.capitalize!),

          ],
        ),

        if(hasAddressline) ...[
        
          /// Spacer
          const SizedBox(height: 8,),
      
          /// Address Line e.g Gaborone, Tlokweng, Plot 1234
          CustomBodyText(deliveryAddress.addressLine),

        ]
    
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: addressContent,
    );
  }
}