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

  bool get isOnline => store.online;
  ShoppableStore get store => widget.store;
  bool get isOpen => StoreServices.isOpen(store);
  bool get hasDescription => store.description != null;
  bool get hasJoinedStoreTeam => StoreServices.hasJoinedStoreTeam(store);
  bool get isClosedButNotTeamMember => StoreServices.isClosedButNotTeamMember(store);
  bool get hasAuthActiveSubscription => store.relationships.authActiveSubscription != null;
  String get offlineMessage => store.offlineMessage.isNotEmpty ? store.offlineMessage : 'We are closed';

  Widget get offlineMessageWidget {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, color: Colors.grey.shade400, size: 16,),
        const SizedBox(width: 4,),
        Expanded(child: CustomBodyText(offlineMessage, lightShade: true)),
      ],
    );
  }

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
                    
              if(hasDescription && isOpen || isClosedButNotTeamMember) ... [
                
                /// Spacer
                const SizedBox(height: 8),
                          
                /// Store description
                if(hasDescription) CustomBodyText(store.description!),

              ]
              
            ]
          ),
        ),
    
        /// Followers & Team Members
        if(isOpen || isClosedButNotTeamMember) ...[
    
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
        if(isOpen || isClosedButNotTeamMember) ...[
          
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

        if(isOpen) Column(
          children: [

            /// Spacer
            const SizedBox(height: 8),
            
            /// Visit Shortcode
            StoreVisitShortcode(store: store)

          ],
        ),

        if(!isOpen && hasJoinedStoreTeam) ...[

          /// Spacer
          const SizedBox(height: 4),

          /// (If Requires Subscription) Subscribe Instruction
          if(!hasAuthActiveSubscription) const CustomBodyText('Subscribe to continue selling', margin: EdgeInsets.symmetric(vertical: 4), lightShade: true),
          
          /// (If Does Not Require Subscription But Offline) Custom Store Offline Message (If provided) / We Are Closed
          if(hasAuthActiveSubscription && !isOnline) offlineMessageWidget

        ],
        
        /// Store Closure Notice
        if(!isOpen && !hasJoinedStoreTeam) ...[

          /// Spacer
          const SizedBox(height: 4),

          /// Custom Store Offline Message (If provided) / We Are Closed
          offlineMessageWidget

        ]
        
      ],
    );
  }
}