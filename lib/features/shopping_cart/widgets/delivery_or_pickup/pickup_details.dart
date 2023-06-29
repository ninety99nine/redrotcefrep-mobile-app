import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
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
  bool get hasPickupDestinations => store?.pickupDestinations.isNotEmpty ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// If we have pickup destinations and the pickup destination has not been selected
    if(hasPickupDestinations && hasSelectedPickupDestination() == false) {

      /// Set the pickup destination to the first pickup destination
      setState(() => store!.pickupDestination = store!.pickupDestinations[0]);

    }

  }

  bool hasSelectedPickupDestination() {

    /// If the pickup destination is not selected, return false
    if(store!.pickupDestination == null) return false;

    /// Check if the selected pickup destination exists in the list of pickup destinations
    return store!.pickupDestinations.any((destination) => destination.name == store!.pickupDestination!.name);

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
        if(hasPickupDestinations) ...[

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
                  groupValue: store!.pickupDestination?.name,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Pickup Destination Name
                      CustomTitleSmallText(pickupDestination.name),

                      /// Pickup Destination Address
                      if(pickupDestination.address.isNotEmpty) CustomBodyText(pickupDestination.address),
                      
                    ],
                  ),
                  value: pickupDestination.name,
                  dense: true,
                  onChanged: (value) {
                    setState(() => store!.pickupDestination = store!.pickupDestinations.firstWhere((destination) => destination.name == value));
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