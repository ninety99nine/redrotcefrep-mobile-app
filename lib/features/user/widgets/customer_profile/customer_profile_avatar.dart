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
  ShoppableStore? get store => widget.store;
  String get name => order.attributes.customerName;
  String get mobileNumber => order.customerMobileNumber.withoutExtension;
  bool get canManageOrders => store == null ? false : StoreServices.hasPermissionsToManageOrders(store!);

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
                if(canManageOrders == false) const SizedBox(height: 12),
    
                /// Name
                CustomTitleMediumText(name),

                if(canManageOrders) ... [
    
                  /// Spacer
                  const SizedBox(height: 4),

                  Row( 
                    children: [
      
                      /// Mobile Number
                      CustomBodyText(mobileNumber, lightShade: true,),
  
                      /// Spacer
                      const SizedBox(width: 8),

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