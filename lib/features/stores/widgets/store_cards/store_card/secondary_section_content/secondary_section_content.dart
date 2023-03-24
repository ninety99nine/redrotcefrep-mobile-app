import 'package:bonako_demo/features/products/widgets/modifiable_product_cards/edit_product_cards/edit_product_cards.dart';
import '../../../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/checkboxes/custom_checkbox.dart';
import '../../../../../shopping_cart/widgets/shopping_cart_content.dart';
import '../../../../services/store_services.dart';
import '../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreSecondarySectionContent extends StatefulWidget {

  final ShoppableStore store;
  final bool canShowSubscribeCallToAction;
  final Alignment subscribeButtonAlignment;
  final ShoppingCartCurrentView shoppingCartCurrentView;

  const StoreSecondarySectionContent({
    Key? key,
    required this.store,
    required this.shoppingCartCurrentView,
    this.canShowSubscribeCallToAction = true,
    this.subscribeButtonAlignment = Alignment.centerRight
  }) : super(key: key);

  @override
  State<StoreSecondarySectionContent> createState() => _StoreSecondarySectionContentState();
}

class _StoreSecondarySectionContentState extends State<StoreSecondarySectionContent> {

  ShoppableStore get store => widget.store;
  bool get hasProducts => store.relationships.products.isNotEmpty;
  bool get canAccessAsShopper => StoreServices.canAccessAsShopper(store);
  Alignment get subscribeButtonAlignment => widget.subscribeButtonAlignment;
  bool get canShowSubscribeCallToAction => widget.canShowSubscribeCallToAction;
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get hasJoinedStoreTeam => StoreServices.hasJoinedStoreTeam(widget.store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        /// View As Customer Checkbox
        if(canAccessAsTeamMember && hasProducts) ...[

          CustomCheckbox(
            value: teamMemberWantsToViewAsCustomer,
            text: 'View as customer',
            onChanged: (value) {
              if(value != null) store.updateTeamMemberWantsToViewAsCustomer(value);
            }
          ),

        ],

        /// Shopping Cart
        if((!hasJoinedStoreTeam && canAccessAsShopper) || (hasJoinedStoreTeam && canAccessAsTeamMember && teamMemberWantsToViewAsCustomer)) ShoppingCartContent(
          shoppingCartCurrentView: widget.shoppingCartCurrentView
        ),

        /// Edit Product Cards
        if(hasJoinedStoreTeam && canAccessAsTeamMember && !teamMemberWantsToViewAsCustomer)  ...[

          EditProductCards(
            shoppingCartCurrentView: widget.shoppingCartCurrentView
          )

        ],

        /// Subscribe Modal Bottom Sheet
        if(hasJoinedStoreTeam && !canAccessAsTeamMember && canShowSubscribeCallToAction) ...[

          SubscribeToStoreModalBottomSheet(
            store: widget.store,
            subscribeButtonAlignment: subscribeButtonAlignment,
          )

        ],

      ],
    );
  }
}