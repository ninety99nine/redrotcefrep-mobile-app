import 'package:bonako_demo/features/notifications/models/notification_types/users/invitation_to_follow_store_created_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class InvitationToFollowStoreCreatedNotificationContent extends StatelessWidget {

  final model.Notification notification;
  
  const InvitationToFollowStoreCreatedNotificationContent({
    super.key,
    required this.notification
  });

  String get storeName => storeProperties.name;
  DateTime get createdAt => notification.createdAt;
  String get userName => invitedByUserProperties.name;
  StoreProperties get storeProperties => invitationToFollowStoreCreatedNotification.storeProperties;
  InvitedByUserProperties get invitedByUserProperties => invitationToFollowStoreCreatedNotification.invitedByUserProperties;
  InvitationToFollowStoreCreatedNotification get invitationToFollowStoreCreatedNotification => InvitationToFollowStoreCreatedNotification.fromJson(notification.data);

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
                      text: ' invited you to follow this store',
                      style: style(context, color: Colors.grey),
                    )
                  ]
                ),
              ),
            ),
        
            /// Spacer
            const SizedBox(width: 8),
          
            /// Icon
            const Icon(Icons.email_outlined, size: 16),
    
          ],
        ),

      ],
    );
  }
}