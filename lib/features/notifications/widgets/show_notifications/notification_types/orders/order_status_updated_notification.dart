import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_status_updated_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class OrderStatusUpdatedNotificationContent extends StatelessWidget {

  final model.Notification notification;
  
  const OrderStatusUpdatedNotificationContent({
    super.key,
    required this.notification
  });

  String get status => orderProperties.status;
  DateTime get createdAt => notification.createdAt;
  String get orderNumber => orderProperties.number;
  String get customerName => orderProperties.customerProperties.name;
  bool get isAssociatedAsFriend => orderProperties.isAssociatedAsFriend;
  String get changedByUserName => orderProperties.changedByUserProperties.name;
  StoreProperties get storeProperties => orderStatusUpdatedNotification.storeProperties;
  OrderProperties get orderProperties => orderStatusUpdatedNotification.orderProperties;
  OrderStatusUpdatedNotification get orderStatusUpdatedNotification => OrderStatusUpdatedNotification.fromJson(notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationFooter(BuildContext context) {

    if(isAssociatedAsFriend) {

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
    
          /// Activity Summary
          Expanded(
            child: RichText(
              text: TextSpan(
                /// User Name
                text: 'Ordered by ',
                style: style(context),
                children: [
                  TextSpan(
                    /// Activity
                    text: customerName,
                    style: style(context),
                  ),
                  TextSpan(
                    /// Activity
                    text: ' updated as ',
                    style: style(context, color: Colors.grey),
                  ),
                  TextSpan(
                    /// Activity
                    text: status,
                    style: style(context),
                  ),
                  TextSpan(
                    /// Activity
                    text: ' by ',
                    style: style(context, color: Colors.grey),
                  ),
                  TextSpan(
                    /// Activity
                    text: changedByUserName,
                    style: style(context),
                  ),
                ]
              ),
            ),
          ),

          /// Spacer
          const SizedBox(width: 8,),

          /// Order Number
          CustomBodyText('#$orderNumber', lightShade: true),

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
                /// Activity
                text: 'Ordered by ',
                style: style(context),
                children: [
                  TextSpan(
                    /// User Name
                    text: 'You',
                    style: style(context),
                  ),
                  TextSpan(
                    /// Activity
                    text: ' updated as ',
                    style: style(context, color: Colors.grey),
                  ),
                  TextSpan(
                    /// Status
                    text: status,
                    style: style(context),
                  ),
                  TextSpan(
                    /// Activity
                    text: ' by ',
                    style: style(context, color: Colors.grey),
                  ),
                  TextSpan(
                    /// User Name
                    text: changedByUserName,
                    style: style(context),
                  ),
                ]
              ),
            ),
          ),

          /// Order Number
          CustomBodyText('#$orderNumber', lightShade: true),

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
              CustomTitleSmallText(storeProperties.name),
              
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
                child: CustomBodyText(orderProperties.summary)
              ),
          
              /// Spacer
              const SizedBox(width: 8),
          
              /// Shopping Bag Icon
              Icon(FontAwesomeIcons.circleDot, color: Colors.blue.shade700, size: 12,)
    
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
