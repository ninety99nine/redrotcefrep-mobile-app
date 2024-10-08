import 'package:perfect_order/core/shared_models/user_order_collection_association.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../orders/models/order.dart';
import 'package:flutter/material.dart';

class CustomerProfileAvatar extends StatefulWidget {

  final Order order;

  const CustomerProfileAvatar({
    super.key,
    required this.order,
  });

  @override
  State<CustomerProfileAvatar> createState() => _CustomerAvatarProfileState();
}

class _CustomerAvatarProfileState extends State<CustomerProfileAvatar> {

  Order get order => widget.order;
  String get customerMobileNumber => '7xxxxxxx';
  int get orderForTotalUsers => order.orderForTotalUsers;
  ShoppableStore? get store => order.relationships.store;
  int get orderForTotalFriends => order.orderForTotalFriends;
  String? get customerDisplayName => order.attributes.customerDisplayName;
  bool get isOrderingForFriendsOnly => order.attributes.isOrderingForFriendsOnly;
  bool get isOrderingForMeAndFriends => order.attributes.isOrderingForMeAndFriends;
  bool get isAssociatedAsAFriend => userOrderCollectionAssociation?.isAssociatedAsFriend ?? false;
  bool get isAssociatedAsACustomer => userOrderCollectionAssociation?.isAssociatedAsCustomer ?? false;
  bool get canManageOrders => store == null ? false : store!.attributes.userStoreAssociation!.canManageOrders;
  UserOrderCollectionAssociation? get userOrderCollectionAssociation => order.attributes.userOrderCollectionAssociation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    
            /// Avatar
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
    
            /// Spacer
            const SizedBox(width: 16),
    
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Spacer
                if(!canManageOrders && !isAssociatedAsAFriend) const SizedBox(height: 12),
    
                /// Customer Display Name
                if(customerDisplayName != null) CustomTitleMediumText(customerDisplayName!),

                /// If Associated As Customer / Friend And Order Is For More Than One Person
                if((isAssociatedAsAFriend || isAssociatedAsACustomer) && orderForTotalUsers > 1) ...[
    
                  /// Spacer
                  if(customerDisplayName != null) const SizedBox(height: 4),

                  Row(
                    children: [

                      /// Group Icon
                      Icon(Icons.group_outlined, color: Colors.grey.shade400, size: 20,),

                      /// Spacer
                      const SizedBox(width: 4),
      
                      if(isAssociatedAsACustomer) ...[
                      
                        /// Shared With "Me And Friends"
                        if(isOrderingForMeAndFriends)...[

                          /// Shared with a friend / friends
                          CustomBodyText('Shared with ${orderForTotalFriends == 1 ? 'a friend' : '$orderForTotalFriends friends'}', lightShade: true),

                        ],
                      
                        /// Shared With "Friends Only"
                        if(isOrderingForFriendsOnly) ...[

                          /// Ordered for a friend / friends
                          CustomBodyText('Ordered for ${orderForTotalFriends == 1 ? 'a friend' : '$orderForTotalFriends friends'}', lightShade: true),

                        ],

                      ],
          
                      /// Shared With Me
                      if(isAssociatedAsAFriend) const CustomBodyText('Shared with me', lightShade: true),


                    ],
                  )

                ],

                if(canManageOrders) ... [
    
                  /// Spacer
                  const SizedBox(height: 4),

                  Row( 
                    children: [

                      if(customerMobileNumber != null) ...[
      
                        /// Mobile Number
                        CustomBodyText(customerMobileNumber, lightShade: true,),
    
                        /// Spacer
                        const SizedBox(width: 8),

                      ],

                      /// Open In New Page Icon
                      Icon(Icons.open_in_new_rounded, size: 16, color: Colors.blue.shade700,),
  
                      /// Spacer
                      const SizedBox(width: 4),

                      /// View Profile Button
                      const CustomBodyText('Profile', isLink: true,)

                    ],
                  )

                ] 
                
              ],

            )
    
          ],
        ),
      ],
    );
  }
}