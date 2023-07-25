import 'package:bonako_demo/features/notifications/models/notification_types/stores/store_created_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class StoreCreatedNotificationContent extends StatelessWidget {

  final model.Notification notification;
  
  const StoreCreatedNotificationContent({
    super.key,
    required this.notification
  });

  String get userName => userProperties.name;
  String get storeName => storeProperties.name;
  DateTime get createdAt => notification.createdAt;
  UserProperties get userProperties => storeCreatedNotification.userProperties;
  StoreProperties get storeProperties => storeCreatedNotification.storeProperties;
  StoreCreatedNotification get storeCreatedNotification => StoreCreatedNotification.fromJson(notification.data);

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
            CustomTitleSmallText(storeName),
            
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
                  /// User Name
                  text: userName,
                  style: style(context),
                  children: [
                    TextSpan(
                      /// Activity
                      text: ' created this store',
                      style: style(context, color: Colors.grey),
                    )
                  ]
                ),
              ),
            ),
        
            /// Spacer
            const SizedBox(width: 8),
        
            /// Store Icon
            const Icon(Icons.store_outlined, color: Colors.green, size: 16,),
    
          ],
        ),

      ],
    );
  }
}