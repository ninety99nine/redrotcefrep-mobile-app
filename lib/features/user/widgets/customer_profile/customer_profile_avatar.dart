import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';

import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../stores/services/store_services.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../../../orders/models/order.dart';

class CustomerProfileAvatar extends StatefulWidget {

  final Order order;
  final ShoppableStore? store;

  const CustomerProfileAvatar({
    super.key,
    required this.order,
    required this.store,
  });

  @override
  State<CustomerProfileAvatar> createState() => _CustomerAvatarProfileState();
}

class _CustomerAvatarProfileState extends State<CustomerProfileAvatar> {

  Order get order => widget.order;
  String get orderFor => order.orderFor;
  ShoppableStore? get store => widget.store;
  int get orderForTotalUsers => order.orderForTotalUsers;
  String get customerName => order.attributes.customerName;
  int get orderForTotalFriends => order.orderForTotalFriends;
  String? get mobileNumber => order.customerMobileNumber?.withoutExtension;
  bool get hasUserOrderCollectionAssociation => userOrderCollectionAssociation != null;
  bool get canManageOrders => store == null ? false : StoreServices.hasPermissionsToManageOrders(store!);
  UserOrderCollectionAssociation? get userOrderCollectionAssociation => order.attributes.userOrderCollectionAssociation;
  bool get isAssociatedAsAFriend => hasUserOrderCollectionAssociation && userOrderCollectionAssociation!.role == 'Friend';
  bool get isAssociatedAsACustomer => hasUserOrderCollectionAssociation && userOrderCollectionAssociation!.role == 'Customer';

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
    
                /// Name
                CustomTitleMediumText(customerName),

                /// If Associated As Customer / Friend And Order Is For More Than One Person
                if((isAssociatedAsAFriend || isAssociatedAsACustomer) && orderForTotalUsers > 1) ...[
    
                  /// Spacer
                  const SizedBox(height: 4),

                  Row(
                    children: [

                      /// Group Icon
                      Icon(Icons.group_outlined, color: Colors.grey.shade400, size: 20,),

                      /// Spacer
                      const SizedBox(width: 4),
      
                      if(isAssociatedAsACustomer) ...[
                      
                        /// Shared With "Me And Friends"
                        if(orderFor == 'Me And Friends') ...[

                          /// Shared with a friend / friends
                          CustomBodyText('Shared with ${orderForTotalFriends == 1 ? 'a friend' : '$orderForTotalFriends friends'}', lightShade: true),

                        ],
                      
                        /// Shared With "Friends Only"
                        if(orderFor == 'Friends Only') ...[

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

                      if(mobileNumber != null) ...[
      
                        /// Mobile Number
                        CustomBodyText(mobileNumber, lightShade: true,),
    
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