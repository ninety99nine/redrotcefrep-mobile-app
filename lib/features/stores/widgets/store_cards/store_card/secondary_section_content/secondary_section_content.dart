import 'package:bonako_demo/core/shared_widgets/checkboxes/custom_checkbox.dart';
import 'package:bonako_demo/features/products/widgets/modifiable_product_cards/edit_product_cards/edit_product_cards.dart';
import '../../../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import '../../../../../shopping_cart/widgets/shopping_cart_content.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import '../../../../services/store_services.dart';
import '../../../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StoreSecondarySectionContent extends StatefulWidget {

  final ShoppableStore store;
  final bool canShowSubscribeCallToAction;
  final ShoppingCartCurrentView shoppingCartCurrentView;

  const StoreSecondarySectionContent({
    Key? key,
    required this.store,
    required this.shoppingCartCurrentView,
    this.canShowSubscribeCallToAction = true
  }) : super(key: key);

  @override
  State<StoreSecondarySectionContent> createState() => _StoreSecondarySectionContentState();
}

class _StoreSecondarySectionContentState extends State<StoreSecondarySectionContent> {

  bool teamMemberWantsToViewAsCustomer = false;

  ShoppableStore get store => widget.store;
  bool get isOpen => StoreServices.isOpen(store);
  bool get hasProducts => store.relationships.products.isNotEmpty;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  bool get hasSelectedFollowing => homeProvider.hasSelectedFollowing;
  bool get canShowSubscribeCallToAction => widget.canShowSubscribeCallToAction;
  bool get hasJoinedStoreTeam => StoreServices.hasJoinedStoreTeam(widget.store);
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  bool get hasAuthActiveSubscription => store.relationships.authActiveSubscription != null;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        if(!isOpen && hasJoinedStoreTeam && !hasAuthActiveSubscription && canShowSubscribeCallToAction) ...[

          /// Subscribe Modal Bottom Sheet
          SubscribeToStoreModalBottomSheet(store: widget.store)

        ],

        /// View As Customer Checkbox
        if(hasSelectedMyStores && hasProducts) ...[

          CustomCheckbox(
            value: teamMemberWantsToViewAsCustomer,
            text: 'View as customer',
            onChanged: (value) {
              setState(() => teamMemberWantsToViewAsCustomer = value ?? false); 
            }
          ),

        ],

        /// Shopping Cart (If selected the Following Tab)
        if((isOpen && hasSelectedFollowing) || teamMemberWantsToViewAsCustomer) ShoppingCartContent(
          shoppingCartCurrentView: widget.shoppingCartCurrentView
        ),

        /// Create Product Button (If selected the My Stores Tab)
        if(hasSelectedMyStores && hasAuthActiveSubscription && !teamMemberWantsToViewAsCustomer) ...[

          /// Create Product Button
          EditProductCards(
            shoppingCartCurrentView: widget.shoppingCartCurrentView
          )
        ]

      ],
    );
  }
}