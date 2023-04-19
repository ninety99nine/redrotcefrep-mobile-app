import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/addresses/models/address.dart';
import 'package:bonako_demo/features/addresses/widgets/address_cards_in_vertical_view.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/order_for/widgets/order_for_users/order_for_users_in_horizontal_list_view_infinite_scroll.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class PickupDetails extends StatefulWidget {
  const PickupDetails({super.key});

  @override
  State<PickupDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<PickupDetails> {
  
  ShoppableStore? store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// If the pickup destination is null and we have pickup destinations
    if(store!.pickupDestination == null && store!.pickupDestinations.isNotEmpty) {

      /// Set the pickup destination to the first pickup destination
      setState(() => store!.pickupDestination = store!.pickupDestinations[0].name);

    }

  }

  @override
  Widget build(BuildContext context) {

    /// Capture the store that was passed on ListenableProvider.value() of the StoreCard. 
    /// This store is accessible if the StoreCard is an ancestor of this 
    /// ShoppableProductCards. We can use this shoppable store instance 
    /// for shopping purposes e.g selecting this product so that we 
    /// can place an order.
    store = Provider.of<ShoppableStore>(context, listen: true);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// If the store has a pickup note, display it
        if(store!.pickupNote != null) ...[
          
          /// Pickup Note
          CustomMessageAlert(store!.pickupNote!),

          /// Spacer
          const SizedBox(height: 8),

        ],

        /// If we have pickup destinations
        if(store!.pickupDestinations.isNotEmpty) ...[

          /// Spacer
          const SizedBox(height: 8),
          
          /// Select a pickup location
          const CustomTitleSmallText('Choose your pickup location', margin: EdgeInsets.only(left: 8),),

          /// Spacer
          const SizedBox(height: 8),

          /// Pickup Destinations As Radio Buttons
          Column(
            children: <Widget>[

              ...store!.pickupDestinations.map((pickupDestination) {

                /// Return a RadioListTile for each pickup destination
                return RadioListTile(
                  groupValue: store!.pickupDestination,
                  title: Text(pickupDestination.name),
                  value: pickupDestination.name,
                  dense: true,
                  onChanged: (value) {
                    setState(() => store!.pickupDestination = value);
                  },
                );

              }).toList()

            ],
          )

        ]

      ]
    );
  }
}