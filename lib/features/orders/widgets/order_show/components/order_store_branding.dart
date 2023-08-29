import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderStoreBranding extends StatelessWidget {
  
  final Order order;

  const OrderStoreBranding({
    Key? key,
    required this.order
  }) : super(key: key);

  ShoppableStore get store => order.relationships.store!;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 20.0, right: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
    
          //  Store Logo
          StoreLogo(store: store, radius: 24),
    
          /// Spacer
          const SizedBox(width: 8,),
        
          /// Store Name
          CustomTitleMediumText(
            store.name, 
            overflow: TextOverflow.ellipsis, 
            margin: const EdgeInsets.only(top: 4, bottom: 4)
          ),

        ],
      ),
    );
  }
}