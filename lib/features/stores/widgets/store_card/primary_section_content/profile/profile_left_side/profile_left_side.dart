import '../../../../../../team_members/widgets/team_members_show/team_members_modal_bottom_sheet/team_members_modal_bottom_sheet.dart';
import '../../../../../../followers/widgets/followers_show/followers_modal_bottom_sheet/followers_modal_bottom_sheet.dart';
import '../../../../../../friends/widgets/friends_show/friends_modal_bottom_sheet/friends_modal_bottom_sheet.dart';
import '../../../../../../orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import '../../../../../../reviews/widgets/reviews_show/reviews_modal_bottom_sheet/reviews_modal_popup.dart';
import '../../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../../friends/enums/friend_enums.dart';
import '../../../../../providers/store_provider.dart';
import '../../../../../services/store_services.dart';
import '../../../../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'store_name.dart';

class StoreProfileLeftSide extends StatefulWidget {
  
  final ShoppableStore store;

  const StoreProfileLeftSide({required this.store, super.key});

  @override
  State<StoreProfileLeftSide> createState() => _StoreProfileLeftSideState();
}

class _StoreProfileLeftSideState extends State<StoreProfileLeftSide> {

  ShoppableStore get store => widget.store;
  bool get hasDescription => store.description != null;

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
                    
              /// Spacer
              if(hasDescription) const SizedBox(height: 8),
                          
              /// Store description
              if(hasDescription) CustomBodyText(store.description!),
              
            ]
          ),
        ),
    
        /// Spacer
        const SizedBox(height: 8,),
    
        Row(
          children: [
    
            /// Store Shortcode
    ///           if(hasActiveVisitShortcode) StoreShortcode(store: store),
            
            /// Spacer
    ///           if(hasActiveVisitShortcode) const SizedBox(width: 16,),
              
            /// Store Followers
            FollowersModalBottomSheet(store: store),

            /// Spacer
            const SizedBox(width: 4,),

            /// Store Followers
            TeamMembersModalBottomSheet(store: store),
    
          ]
        ),
              
        /// Spacer
        const SizedBox(height: 8),
    
        Row(
          children: [
              
            /// Store Total Coupons
    ///             if(showCoupons) StoreCoupons(store: store,),
            
            /// Spacer
    ///             if(showFollowers || showReviews) const SizedBox(width: 16,),
              
            /// Store Total Orders Verified As Received
    ///           if(showReviews) StoreOrders(store: store,),
              
            /// Spacer
    ///           if(showFollowers && showReviews) const SizedBox(width: 16,),
              
            /// Store Total Orders
            OrdersModalBottomSheet(store: store),

            /// Spacer
            const SizedBox(width: 4,),

            /// Store Total Reviews
            ReviewsModalBottomSheet(store: store),
          
    
          ]
        ),
              
        /// Spacer
        const SizedBox(height: 8),
    
        Row(
          children: [

            FriendsModalBottomSheet(
              onSelectedFriends: (_) {},
              onSelectedFriendGroups: (_) {},
              purpose: Purpose.addFriendsToOrder,
            ),
    
          ]
        ),
    
        /// Bottom Divider
    ///       if(showBottomDivider) const Divider(),
        
      ],
    );
  }
}