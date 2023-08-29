import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/order_for/widgets/order_for_users/order_for_users_in_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/addresses/widgets/address_cards_in_vertical_view.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/addresses/models/address.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/features/stores/models/store.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class DeliveryDetails extends StatefulWidget {
  const DeliveryDetails({super.key});

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  
  User? selectedUser;
  ShoppableStore? store;
  bool isLoadingAddresses = false;

  User get authUser => authProvider.user!;
  bool get hasAddressForDelivery => store?.addressForDelivery != null;
  bool get deliverToMe => selectedUser == null || authUser.id == selectedUser!.id;
  bool get hasSelectedFriends => store == null ? false : store!.hasSelectedFriends;
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  bool get hasDeliveryDestinations => store?.deliveryDestinations.isNotEmpty ?? false;
  bool get hasSelectedFriendGroups => store == null ? false : store!.hasSelectedFriendGroups;
  bool get isOrderingForFriendsOnly => store == null ? false : store!.isOrderingForFriendsOnly;
  bool get isOrderingForMeAndFriends => store == null ? false : store!.isOrderingForMeAndFriends;
  String get orderForUsersKey => store == null ? '' : '${store!.orderFor} ${store!.friends.length} ${store!.friendGroups.length}';

  String? get deliveryAddressSummary {

    if(hasAddressForDelivery) {

      if(deliverToMe) {

        //  Note: The address line appears for this user since they own this address
        return 'Deliver to ${authUser.attributes.name} in ${store!.addressForDelivery?.addressLine}';

      }else{

        //  Note: The address line does not appear since this user does not own this address
        return 'Deliver to ${selectedUser!.attributes.name} @ ${store!.addressForDelivery?.name}';

      }

    }

    return null;

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// If we have delivery destinations and the delivery destination has not been selected
    if(hasDeliveryDestinations && hasSelectedDeliveryDestination() == false) {

      /// Set the delivery destination to the first delivery destination
      setState(() => store!.deliveryDestination = store!.deliveryDestinations[0]);

    }

  }

  bool hasSelectedDeliveryDestination() {

    /// If the delivery destination is not selected, return false
    if(store!.deliveryDestination == null) return false;

    /// Check if the selected delivery destination exists in the list of delivery destinations
    return store!.deliveryDestinations.any((destination) => destination.name == store!.deliveryDestination!.name);

  }

  void onLoadingAddresses(bool status) {

    /**
     *  The Future.delayed() function is used to prevent the following flutter error:
     * 
     *  This DeliveryDetails widget cannot be marked as needing to build because the 
     *  framework is already in the process of building widgets. A widget can be 
     *  marked as needing to be built during the build phase only if one of its 
     *  ancestors is currently building. This exception is allowed because the 
     *  framework builds parent widgets before children, which means a dirty 
     *  descendant will always be built. Otherwise, the framework might not 
     *  visit this widget during this build phase.
     */
    Future.delayed(Duration.zero, () {
      setState(() => isLoadingAddresses = status);
    });

  }

  void onSelectedUser(User selectedUser) {
    setState(() {
      this.selectedUser = selectedUser;
      store!.addressForDelivery = null;
      isLoadingAddresses = true;
    });
  }

  void onSelectedAddress(Address? address) {
    setState(() => store!.addressForDelivery = address);
  }

  Widget getDeliveryDestinationName(DeliveryDestination deliveryDestination) {

    String name = deliveryDestination.name;
    String cost;
    
    if(store!.allowFreeDelivery) {
      cost = ' - Free Delivery';
    }else{
      if(deliveryDestination.allowFreeDelivery) {
        cost = '- Free Delivery';
      }else{
        cost = '+${deliveryDestination.cost.amountWithCurrency}';
      }
    }

    return CustomBodyText([name, cost]);

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
          children: hasSelectedProducts ? [

            /// If we have delivery destinations
            if(hasDeliveryDestinations) ...[
              
              /// Select a delivery location
              const CustomTitleSmallText('Choose your delivery location', margin: EdgeInsets.only(left: 8),),

              /// Spacer
              const SizedBox(height: 8),

              /// Pickup Destinations As Radio Buttons
              Column(
                children: <Widget>[

                  ...store!.deliveryDestinations.map((deliveryDestination) {

                    /// Return a RadioListTile for each delivery destination
                    return RadioListTile(
                      title: getDeliveryDestinationName(deliveryDestination),
                      groupValue: store!.deliveryDestination?.name,
                      contentPadding: const EdgeInsets.all(0.0),
                      value: deliveryDestination.name,
                      dense: true,
                      onChanged: (value) {
                        setState(() => store!.deliveryDestination = store!.deliveryDestinations.firstWhere((destination) => destination.name == value));
                      },
                    );

                  }).toList()

                ],
              ),

              //  Divider
              const Divider(),

            ],

            /// Spacer
            const SizedBox(height: 8),
            
            /// Title
            CustomTitleSmallText(hasAddressForDelivery ? 'Choose your delivery address' : 'Where should we deliver?', margin: const EdgeInsets.only(left: 8),),

            /// Spacer
            const SizedBox(height: 8),

            if((isOrderingForMeAndFriends || isOrderingForFriendsOnly) && (hasSelectedFriends || hasSelectedFriendGroups)) ...[

              /// Order For Users
              OrderForUsersInHorizontalListViewInfiniteScroll(
                key: ValueKey(orderForUsersKey),
                onSelectedUser: onSelectedUser,
                store: store!
              ),

              /// Spacer
              const SizedBox(height: 16),

            ],

            /// Address Cards
            AddressCardsInVerticalView(
              key: ValueKey((selectedUser ?? authUser).id),
              onLoadingAddresses: onLoadingAddresses,
              onSelectedAddress: onSelectedAddress,
            
              noAddressesMargin: EdgeInsets.zero,
              user: selectedUser ?? authUser,
              screenWidthPercentage: 0.7,
              selectable: true,
              elevation: 1,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedSwitcher(
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500),
                  child: isLoadingAddresses ? null : Column(
                    children: [

                      /// Spacer
                      const SizedBox(height: 8),
                      
                      /// Delivery Address Summary (Deliver To)
                      if(hasAddressForDelivery) CustomMessageAlert(
                        deliveryAddressSummary!,
                        type: AlertMessageType.error,
                        icon: Icons.location_pin,
                      ),
              
                      /// Spacer
                      const SizedBox(height: 16),
              
                    ]
                  )
                ),
              )
            ),
            
            /// If the store has a delivery note, display it
            if(store!.deliveryNote != null) ...[
              
              /// Delivery Note
              CustomMessageAlert(
                store!.deliveryNote!,
                icon: Icons.notes_rounded,
              ),

            ],

          ] : [],
        )
      ),
    );
  }
}