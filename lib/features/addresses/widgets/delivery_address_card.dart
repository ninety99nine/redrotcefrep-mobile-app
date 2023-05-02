import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/addresses/models/delivery_address.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/cards/custom_card.dart';
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

  Widget get addressContent {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        /// Address Title
        Row(
          children: [
              
            /// Location Icon
            const Icon(Icons.location_pin, size: 16, color: Colors.grey),
      
            /// Spacer
            const SizedBox(width: 4,),
            
            /// Address Type e.g Home / Work / Friend / Business
            CustomTitleSmallText(deliveryAddress.type.name.capitalize!),

          ],
        ),
        
        /// Spacer
        const SizedBox(height: 8,),
    
        /// Address Line e.g Gaborone, Tlokweng, Plot 1234
        CustomBodyText(deliveryAddress.addressLine),
    
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