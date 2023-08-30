import 'package:bonako_demo/features/notifications/widgets/show_notifications/notification_types/orders/order_paid_notification.dart';
import 'package:bonako_demo/features/notifications/widgets/show_notifications/notification_types/subscriptions/subscription_created_notification.dart';

import 'notification_types/friend_groups/friend_group_store_removed_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'notification_types/friend_groups/friend_group_user_added_notification.dart';
import 'notification_types/friend_groups/friend_group_store_added_notification.dart';
import 'notification_types/orders/order_status_updated_notification.dart';
import 'notification_types/stores/store_created_notification.dart';
import 'notification_types/stores/store_deleted_notification.dart';
import 'notification_types/orders/order_created_notification.dart';
import 'notification_types/orders/order_updated_notification.dart';
import 'notification_types/orders/order_seen_notification.dart';
import 'notification_types/users/following_store_notification.dart';
import 'notification_types/users/invitation_to_follow_store_accepted_notification.dart';
import 'notification_types/users/invitation_to_follow_store_created_notification.dart';
import 'notification_types/users/invitation_to_follow_store_declined_notification.dart';
import 'notification_types/users/invitation_to_join_store_team_accepted_notification.dart';
import 'notification_types/users/invitation_to_join_store_team_created_notification.dart';
import 'notification_types/users/invitation_to_join_store_team_declined_notification.dart';
import 'notification_types/users/remove_store_team_member_notification.dart';
import 'notification_types/users/unfollowed_store_notification.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  
  final int index;
  final model.Notification notification;
  final Function(model.Notification) onSelectedNotification;

  const NotificationItem({
    super.key,
    required this.index,
    required this.notification,
    required this.onSelectedNotification,
  });

  Widget get notificationContent {

    /// Order created
    if (notification.type == "App\\Notifications\\Orders\\OrderCreated") {
      
      return OrderCreatedNotificationContent(notification: notification);

    /// Order updated
    }else if (notification.type == "App\\Notifications\\Orders\\OrderUpdated") {
      
      return OrderUpdatedNotificationContent(notification: notification);

    /// Order seen
    }else if (notification.type == "App\\Notifications\\Orders\\OrderSeen") {
      
      return OrderSeenNotificationContent(notification: notification);

    /// Order status changed
    }else if (notification.type == "App\\Notifications\\Orders\\OrderStatusUpdated") {
      
      return OrderStatusUpdatedNotificationContent(notification: notification);

    /// Order paid
    }else if (notification.type == "App\\Notifications\\Orders\\OrderPaid") {
      
      return OrderPaidNotificationContent(notification: notification);

    /// Friend group user added
    }else if (notification.type == "App\\Notifications\\FriendGroups\\FriendGroupUserAdded") {
      
      return FriendGroupUserAddedNotificationContent(notification: notification);

    /// Friend group user removed
    }else if (notification.type == "App\\Notifications\\FriendGroups\\FriendGroupUserRemoved") {
      
      return FriendGroupUserAddedNotificationContent(notification: notification);

    /// Friend group store added
    }else if (notification.type == "App\\Notifications\\FriendGroups\\FriendGroupStoreAdded") {
      
      return FriendGroupStoreAddedNotificationContent(notification: notification);

    /// Friend group store removed
    }else if (notification.type == "App\\Notifications\\FriendGroups\\FriendGroupStoreRemoved") {
      
      return FriendGroupStoreRemovedNotificationContent(notification: notification);

    /// Store created
    }else if (notification.type == "App\\Notifications\\Stores\\StoreCreated") {
      
      return StoreCreatedNotificationContent(notification: notification);

    /// Store deleted
    }else if (notification.type == "App\\Notifications\\Stores\\StoreDeleted") {
      
      return StoreDeletedNotificationContent(notification: notification);

    /// Following store
    }else if (notification.type == "App\\Notifications\\Users\\FollowingStore") {
      
      return FollowingStoreNotificationContent(notification: notification);

    /// Invitation to follow store accepted
    }else if (notification.type == "App\\Notifications\\Users\\InvitationToFollowStoreAccepted") {
      
      return InvitationToFollowStoreAcceptedNotificationContent(notification: notification);

    /// Invitation to follow store created
    }else if (notification.type == "App\\Notifications\\Users\\InvitationToFollowStoreCreated") {
      
      return InvitationToFollowStoreCreatedNotificationContent(notification: notification);

    /// Invitation to follow store declined
    }else if (notification.type == "App\\Notifications\\Users\\InvitationToFollowStoreDeclined") {
      
      return InvitationToFollowStoreDeclinedNotificationContent(notification: notification);

    /// Invitation to join store team accepted
    }else if (notification.type == "App\\Notifications\\Users\\InvitationToJoinStoreTeamAccepted") {
      
      return InvitationToJoinStoreTeamAcceptedNotificationContent(notification: notification);

    /// Invitation to join store team created
    }else if (notification.type == "App\\Notifications\\Users\\InvitationToJoinStoreTeamCreated") {
      
      return InvitationToJoinStoreTeamCreatedNotificationContent(notification: notification);

    /// Invitation to join store team declined
    }else if (notification.type == "App\\Notifications\\Users\\InvitationToJoinStoreTeamDeclined") {
      
      return InvitationToJoinStoreTeamDeclinedNotificationContent(notification: notification);

    /// Remove store team member
    }else if (notification.type == "App\\Notifications\\Users\\RemoveStoreTeamMember") {
      
      return RemoveStoreTeamMemberNotificationContent(notification: notification);

    /// Unfollow store
    }else if (notification.type == "App\\Notifications\\Users\\UnfollowedStore") {
      
      return UnfollowedStoreNotificationContent(notification: notification);

    /// Subscription created
    }else if (notification.type == "App\\Notifications\\Subscriptions\\SubscriptionCreated") {
      
      return SubscriptionCreatedNotificationContent(notification: notification);

    }else{
      
      return Text(notification.type);

    }

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.readAt == null ? Colors.amber.shade50 : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400, width: 1.0),  // Add a bottom border to separate the tiles
          ),
        ),
        child: ListTile(
          dense: false,
          title: notificationContent,
          onTap: () => onSelectedNotification(notification),
        ),
      ),
    );
  }
}