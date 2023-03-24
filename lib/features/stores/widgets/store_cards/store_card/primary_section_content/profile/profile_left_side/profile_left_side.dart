import '../../../../../../../team_members/widgets/team_members_show/team_members_modal_bottom_sheet/team_members_modal_bottom_sheet.dart';
import '../../../../../../../followers/widgets/followers_show/followers_modal_bottom_sheet/followers_modal_bottom_sheet.dart';
import '../../../../../../../orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import '../../../../../../../reviews/widgets/reviews_show/reviews_modal_bottom_sheet/reviews_modal_popup.dart';
import '../../../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../../services/store_services.dart';
import '../../../../../../models/shoppable_store.dart';
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
  bool get hasJoinedStoreTeam => StoreServices.hasJoinedStoreTeam(store);
  bool get canAccessAsShopper => StoreServices.canAccessAsShopper(store);
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);

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
                    
              if(canAccessAsShopper && hasDescription) ... [
                
                /// Spacer
                const SizedBox(height: 8),
                          
                /// Store description
                if(hasDescription) CustomBodyText(store.description!),

              ]
              
            ]
          ),
        ),
    
        /// Followers & Team Members
        if(canAccessAsShopper) ...[
    
          /// Spacer
          const SizedBox(height: 8,),

          Row(
            children: [
              
              /// Followers
              FollowersModalBottomSheet(store: store),

              /// Spacer
              const SizedBox(width: 4,),

              /// Team Members
              TeamMembersModalBottomSheet(store: store),
      
            ]
          ),
        ],
        
        /// Coupons, Orders & Reviews
        if(canAccessAsShopper) ...[
          
          /// Spacer
          const SizedBox(height: 8),
    
          Row(
            children: [
                
              /// Coupons
              /// if(showCoupons) StoreCoupons(store: store,),
                
              /// Orders
              OrdersModalBottomSheet(store: store),

              /// Spacer
              const SizedBox(width: 4,),

              /// Reviews
              ReviewsModalBottomSheet(store: store),
            
      
            ]
          )
        ],
        
        /// Shortcode
        if(canAccessAsShopper) Column(
          children: [

            /// Spacer
            const SizedBox(height: 8),
            
            /// Visit Shortcode
            StoreVisitShortcode(store: store)

          ],
        ),

        /// Access Denied For Shopper
        if((!hasJoinedStoreTeam || (hasJoinedStoreTeam && canAccessAsTeamMember)) && !canAccessAsShopper) ...[

          /// Reason for denied access e.g "We are currently closed"
          CustomBodyText(store.attributes.shopperAccess!.description, margin: const EdgeInsets.symmetric(vertical: 4), lightShade: true),

        ],

        /// Access Denied For Team Member
        if(hasJoinedStoreTeam && !canAccessAsTeamMember) ...[

          /// Reason for denied access e.g "Subscribe to start selling"
          CustomBodyText(store.attributes.teamMemberAccess!.description, margin: const EdgeInsets.symmetric(vertical: 4), lightShade: true),

        ],
        
      ],
    );
  }
}