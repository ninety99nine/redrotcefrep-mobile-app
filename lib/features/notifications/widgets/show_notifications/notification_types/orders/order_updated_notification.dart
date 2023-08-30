import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_updated_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class OrderUpdatedNotificationContent extends StatelessWidget {

  final model.Notification notification;
  
  const OrderUpdatedNotificationContent({
    super.key,
    required this.notification
  });

  DateTime get createdAt => notification.createdAt;
  String get orderNumber => orderProperties.number;

  bool get hasOccasion => ocassionProperties != null;
  int get otherTotalFriends => orderForTotalFriends - 1;
  int get orderForTotalFriends => orderProperties.orderForTotalFriends;
  bool get isAssociatedAsFriend => orderProperties.isAssociatedAsFriend;
  bool get isAssociatedAsCustomer => orderProperties.isAssociatedAsCustomer;
  String get customerFirstName => orderProperties.customerProperties.firstName;
  OrderProperties get orderProperties => orderUpdatedNotification.orderProperties;
  String get updatedByUserFirstName => orderProperties.updatedByUserProperties.firstName;
  OcassionProperties? get ocassionProperties => orderUpdatedNotification.ocassionProperties;
  OrderUpdatedNotification get orderUpdatedNotification => OrderUpdatedNotification.fromJson(notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationFooter(BuildContext context) {

    if(isAssociatedAsFriend) {

      //  Set the message indicating the user's part in the order
      String activityMessage = 'and tagged you';

      //  Add more details indicating other user's part in the order
      if(otherTotalFriends > 0) activityMessage += ' and $otherTotalFriends ${otherTotalFriends == 1 ? 'other friend' : 'other friends'}';

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
    
          /// Activity Summary
          Expanded(
            child: RichText(
              text: TextSpan(
                /// Activity
                text: updatedByUserFirstName,
                style: style(context),
                children: [
                  TextSpan(
                    /// Activity
                    text: ' updated an order placed by ',
                    style: style(context, color: Colors.grey),
                  ),
                  TextSpan(
                    /// User Name
                    text: customerFirstName,
                    style: style(context),
                  ),
                  TextSpan(
                    /// Activity
                    text: ' $activityMessage ',
                    style: style(context, color: Colors.grey),
                  ),
                  if(hasOccasion) TextSpan(
                    /// Occasion
                    text: ocassionProperties!.name,
                    style: style(context, color: Colors.grey),
                  )
                ]
              ),
            ),
          ),

          /// Spacer
          const SizedBox(width: 8,),

          /// Order Number
          CustomBodyText('#$orderNumber', lightShade: true,),

        ],
      );

    }else{

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
    
          /// Activity Summary
          Expanded(
            child: RichText(
              text: TextSpan(
                /// User Name
                text: updatedByUserFirstName,
                style: style(context),
                children: [
                  TextSpan(
                    /// Activity
                    text: ' updated ${isAssociatedAsCustomer ? 'your' : 'an'} order',
                    style: style(context, color: Colors.grey),
                  )
                ]
              ),
            ),
          ),

          /// Spacer
          const SizedBox(width: 8,),

          /// Order Number
          CustomBodyText('#$orderNumber', lightShade: true,),

        ],
      );

    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// Store Name
              CustomTitleSmallText(orderUpdatedNotification.storeProperties.name),
              
              /// Notificaiton Date And Time Ago
              CustomBodyText(timeago.format(createdAt, locale: 'en_short')),

            ],
          ),

          /// Spacer
          const SizedBox(height: 4),
          
          /// Notification Content
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    
              /// Order Summary
              Expanded(
                child: CustomBodyText(orderUpdatedNotification.orderProperties.summary)
              ),
          
              /// Spacer
              const SizedBox(width: 8),
          
              /// Icon
              const Icon(Icons.shopping_bag_outlined, size: 16,),
    
            ],
          ),
          
          /// Spacer
          const SizedBox(height: 4),

          /// Notification Footer
          notificationFooter(context)

        ],
      ),
    );
  }
}