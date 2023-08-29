import 'package:bonako_demo/features/shopping_cart/widgets/delivery_or_pickup/delivery_details.dart';
import 'package:bonako_demo/features/shopping_cart/widgets/delivery_or_pickup/pickup_details.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class DeliveryOrPickup extends StatefulWidget {
  const DeliveryOrPickup({super.key});

  @override
  State<DeliveryOrPickup> createState() => _DeliveryOrPickupState();
}

class _DeliveryOrPickupState extends State<DeliveryOrPickup> {
  
  ShoppableStore? store;

  bool get allowPickupOnly => allowPickup && !allowDelivery;
  bool get allowDeliveryOnly => allowDelivery && !allowPickup;
  bool get allowPickupOrDelivery => allowDelivery || allowPickup;
  bool get allowPickup => store == null ? false : store!.allowPickup;
  bool get allowDelivery => store == null ? false : store!.allowDelivery;
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  bool get allowPickupAndDelivery => store == null ? false : allowPickup && allowDelivery;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// If the collection type is null
    if(store!.collectionType == null) {

      /// If we allow pickup only
      if(allowPickupOnly) {

        /// Set the collection type to pickup
        setState(() => store!.collectionType = CollectionType.pickup);

      /// If we allow delivery only
      }else if(allowDeliveryOnly) {

        /// Set the collection type to delivery
        setState(() => store!.collectionType = CollectionType.delivery);

      /// If we allow both pickup and delivery
      }else if(allowPickupAndDelivery) {

        /// Set the collection type to delivery
        setState(() => store!.collectionType = CollectionType.delivery);

      }

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
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: allowPickupOrDelivery && hasSelectedProducts ? [
            
            //  Divider
            const Divider(),

            /// Spacer
            const SizedBox(height: 8),
            
            /// If the store supports delivery and pickup
            if(allowPickupAndDelivery) ...[

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// Delivery option
                  CustomChoiceChip(
                    label: 'Delivery',
                    selected: store!.collectionType == CollectionType.delivery,
                    onSelected: (bool isSelected) => store!.updateCollectionType(CollectionType.delivery),
                  ),

                  /// Spacer
                  const SizedBox(width: 8.0,),

                  /// Pickup option
                  CustomChoiceChip(
                    label: 'Pickup',
                    selected: store!.collectionType == CollectionType.pickup,
                    onSelected: (bool isSelected) => store!.updateCollectionType(CollectionType.pickup),
                  ),

                ],
              ),

              /// Spacer
              const SizedBox(height: 8),

            ],
            
            /// Delivery details
            if(store!.collectionType == CollectionType.delivery) const DeliveryDetails(),
            
            /// Pickup details
            if(store!.collectionType == CollectionType.pickup) const PickupDetails(),
              
            /// Spacer
            if(allowPickupOrDelivery) const SizedBox(height: 16),

          ] : [],
        )
      ),
    );
  }
}