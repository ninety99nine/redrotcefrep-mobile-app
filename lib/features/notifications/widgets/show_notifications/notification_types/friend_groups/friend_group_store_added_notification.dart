import 'package:bonako_demo/features/notifications/models/notification_types/friend_groups/friend_group_store_added_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class FriendGroupStoreAddedNotificationContent extends StatelessWidget {

  final model.Notification notification;
  
  const FriendGroupStoreAddedNotificationContent({
    super.key,
    required this.notification
  });

  String get storeName => storeProperties.name;
  DateTime get createdAt => notification.createdAt;
  String get friendGroupName => friendGroupProperties.name;
  String get addedByUserName => addedByUserProperties.name;
  StoreProperties get storeProperties => friendGroupStoreAddedNotification.storeProperties;
  AddedByUserProperties get addedByUserProperties => friendGroupStoreAddedNotification.addedByUserProperties;
  FriendGroupProperties get friendGroupProperties => friendGroupStoreAddedNotification.friendGroupProperties;
  FriendGroupStoreAddedNotification get friendGroupStoreAddedNotification => FriendGroupStoreAddedNotification.fromJson(notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
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

              /// Friend Group Name
              CustomTitleSmallText(friendGroupName),
              
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
                    text: addedByUserName,
                    style: style(context),
                    children: [
                      TextSpan(
                        /// Activity
                        text: ' added ',
                        style: style(context, color: Colors.grey),
                      ),
                      TextSpan(
                        /// Store Name
                        text: storeName,
                        style: style(context),
                      ),
                      TextSpan(
                        /// Activity
                        text: ' to group',
                        style: style(context, color: Colors.grey),
                      ),
                    ]
                  ),
                ),
              ),
          
              /// Spacer
              const SizedBox(width: 8),
          
              /// Icon
              const Icon(Icons.group_add_outlined, size: 16,),
    
            ],
          ),

        ],
      ),
    );
  }
}