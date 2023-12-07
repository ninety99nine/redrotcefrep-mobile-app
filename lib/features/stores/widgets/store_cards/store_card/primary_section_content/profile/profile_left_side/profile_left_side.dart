import '../../../../../../../team_members/widgets/team_members_show/team_members_modal_bottom_sheet/team_members_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/products/widgets/show_products/products_modal_bottom_sheet/products_modal_bottom_sheet.dart';
import '../../../../../../../followers/widgets/followers_show/followers_modal_bottom_sheet/followers_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/coupons/widgets/show_coupons/coupons_modal_bottom_sheet/coupons_modal_bottom_sheet.dart';
import '../../../../../../../orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import '../../../../../../../reviews/widgets/reviews_show/reviews_modal_bottom_sheet/reviews_modal_bottom_sheet.dart';
import '../../../../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import '../../../../../../services/store_services.dart';
import '../../../../../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'store_visit_shortcode.dart';
import 'store_name.dart';

class StoreProfileLeftSide extends StatefulWidget {
  
  final ShoppableStore store;

  const StoreProfileLeftSide({
    super.key,
    required this.store,
  });

  @override
  State<StoreProfileLeftSide> createState() => _StoreProfileLeftSideState();
}

class _StoreProfileLeftSideState extends State<StoreProfileLeftSide> {

  ShoppableStore get store => widget.store;
  bool get hasDescription => store.description != null;
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  bool get canManageCoupons => StoreServices.canManageCoupons(store);
  bool get canManageProducts => StoreServices.canManageProducts(store);
  bool get canAccessAsShopper => StoreServices.canAccessAsShopper(store);
  bool get canManageTeamMembers => StoreServices.canManageTeamMembers(store);
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);
  bool get showEditableMode => (isShowingStorePage || hasSelectedMyStores) && isTeamMemberWhoHasJoined && !teamMemberWantsToViewAsCustomer;
  UserOrderAssociation get userOrderAssociation => isTeamMemberWhoHasJoined ? UserOrderAssociation.teamMember : UserOrderAssociation.customerOrFriend;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        /// Clickable Store name and description
        GestureDetector(
          onTap: () => StoreServices.navigateToStorePage(store),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
              /// Store name
              StoreName(store: store),
            
              /// Team Member Role
              if(isTeamMemberWhoHasJoined) CustomBodyText('@${store.attributes.userStoreAssociation!.teamMemberRole}', lightShade: true,),
                    
              if(canAccessAsShopper && hasDescription) ... [
                
                /// Spacer
                const SizedBox(height: 8),
                          
                /// Store description
                if(hasDescription) CustomBodyText(store.description!),

              ]
              
            ]
          ),
        ),

        if(canAccessAsShopper) ...[
                
          /// Spacer
          const SizedBox(height: 8),

          SizedBox(
            width: 200,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                      
                /// Followers
                if(showEditableMode) FollowersModalBottomSheet(store: store),
          
                /// Team Members
                if(showEditableMode && canManageTeamMembers) TeamMembersModalBottomSheet(store: store),
              
                /// Coupons
                if(showEditableMode && canManageCoupons) CouponsModalBottomSheet(store: store),
                
                /// Products
                if(showEditableMode && canManageProducts) ProductsModalBottomSheet(store: store),
                  
                /// Orders
                OrdersModalBottomSheet(store: store, userOrderAssociation: userOrderAssociation),
          
                /// Reviews
                ReviewsModalBottomSheet(store: store),
                
                /// Visit Shortcode
                StoreVisitShortcode(store: store)
          
              ],
            ),
          ),

          /// Spacer
          const SizedBox(height: 8),

        ],

        /// Access Denied For Shopper
        if((!isTeamMemberWhoHasJoined || teamMemberWantsToViewAsCustomer) && !canAccessAsShopper) ...[

          /// Reason for denied access e.g "We are currently closed"
          CustomBodyText(store.attributes.shopperAccess!.description, margin: const EdgeInsets.symmetric(vertical: 4), lightShade: true),

        ],

        /// Access Denied For Team Member
        if(isTeamMemberWhoHasJoined && !teamMemberWantsToViewAsCustomer && !canAccessAsTeamMember) ...[

          /// Spacer
          const SizedBox(height: 4),

          /// Reason for denied access e.g "Subscribe to start selling"
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange.shade700,),
              const SizedBox(width: 4),
              CustomBodyText(
                store.attributes.teamMemberAccess!.description, margin: const EdgeInsets.symmetric(vertical: 4), isWarning: true
              ),
            ],
          )

        ],
        
      ],
    );
  }
}