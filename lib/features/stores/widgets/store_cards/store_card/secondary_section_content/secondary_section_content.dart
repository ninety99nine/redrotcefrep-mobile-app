import 'package:bonako_demo/features/products/widgets/modifiable_product_cards/edit_product_cards/edit_product_cards.dart';
import '../../../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import '../../../../../shopping_cart/widgets/shopping_cart_content.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import '../../../../services/store_services.dart';
import '../../../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StoreSecondarySectionContent extends StatelessWidget {

  final ShoppableStore store;
  final bool canShowSubscribeCallToAction;
  final ShoppingCartCurrentView shoppingCartCurrentView;

  const StoreSecondarySectionContent({
    Key? key,
    required this.store,
    required this.shoppingCartCurrentView,
    this.canShowSubscribeCallToAction = true
  }) : super(key: key);

  bool get isOpen => StoreServices.isOpen(store);
  bool get hasJoinedStoreTeam => StoreServices.hasJoinedStoreTeam(store);

  @override
  Widget build(BuildContext context) {

    HomeProvider homeProvider = Provider.of<HomeProvider>(context, listen: false);
    bool hasSelectedFollowing = homeProvider.hasSelectedFollowing;
    bool hasSelectedMyStores = homeProvider.hasSelectedMyStores;

    return Column(
      children: [

        if(!isOpen && hasJoinedStoreTeam && canShowSubscribeCallToAction) ...[

          /// Subscribe Modal Bottom Sheet
          SubscribeToStoreModalBottomSheet(store: store)

        ],

        /// Shopping Cart (If selected the Following Tab)
        if(isOpen && hasSelectedFollowing) ShoppingCartContent(
          shoppingCartCurrentView: shoppingCartCurrentView
        ),

        /// Create Product Button (If selected the My Stores Tab)
        if(isOpen && hasSelectedMyStores) ...[

          /// Create Product Button
          EditProductCards(
            shoppingCartCurrentView: shoppingCartCurrentView
          )
        ]

      ],
    );
  }
}