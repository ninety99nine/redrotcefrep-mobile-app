import 'package:bonako_demo/features/notifications/models/notification_types/stores/store_created_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/subscriptions/subscription_created_notification.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class SubscriptionCreatedNotificationContent extends StatelessWidget {

  final model.Notification notification;
  
  const SubscriptionCreatedNotificationContent({
    super.key,
    required this.notification
  });

  DateTime get createdAt => notification.createdAt;
  String get subscriptionForName => subscriptionForProperties.name;
  String get subscriptionForType => subscriptionForProperties.type;
  String get transactionDescription => transactionProperties.description;
  TransactionProperties get transactionProperties => storeCreatedNotification.transactionProperties;
  SubscriptionProperties get subscriptionProperties => storeCreatedNotification.subscriptionProperties;
  SubscriptionForProperties get subscriptionForProperties => storeCreatedNotification.subscriptionForProperties;
  SubscriptionByUserProperties get subscriptionByUserProperties => storeCreatedNotification.subscriptionByUserProperties;
  SubscriptionForUserProperties get subscriptionForUserProperties => storeCreatedNotification.subscriptionForUserProperties;
  SubscriptionCreatedNotification get storeCreatedNotification => SubscriptionCreatedNotification.fromJson(notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Store Name
            CustomTitleSmallText(subscriptionForName),
            
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
    
            /// Activity Summary
            Expanded(
              child: RichText(
                text: TextSpan(
                  /// Activity
                  text: '$transactionDescription paid successfully for this $subscriptionForType',
                  style: style(context, color: Colors.grey),
                )
              ),
            ),
        
            /// Spacer
            const SizedBox(width: 8),
          
            /// Icon
            const Icon(Icons.attach_money_rounded, color: Colors.green, size: 16,),
    
          ],
        ),

      ],
    );
  }
}