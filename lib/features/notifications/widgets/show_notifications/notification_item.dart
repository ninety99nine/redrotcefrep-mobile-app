import 'package:perfect_order/core/utils/string.dart';
import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import 'package:perfect_order/features/notifications/models/notification_filters.dart';
import 'package:perfect_order/features/notifications/providers/notification_provider.dart';
import 'package:perfect_order/features/notifications/widgets/show_notifications/notification_filters.dart';
import 'package:perfect_order/features/notifications/widgets/show_notifications/notification_types/orders/order_paid_using_dpo_notification.dart';
import 'package:perfect_order/features/notifications/widgets/show_notifications/notification_types/orders/order_payment_request_notification.dart';
import 'package:perfect_order/features/notifications/widgets/show_notifications/notification_types/subscriptions/subscription_created_notification.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:perfect_order/features/orders/providers/order_provider.dart';
import 'package:perfect_order/features/orders/services/order_services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'notification_types/friend_groups/friend_group_store_removed_notification.dart';
import 'package:perfect_order/features/notifications/models/notification.dart' as model;
import 'notification_types/friend_groups/friend_group_user_added_notification.dart';
import 'notification_types/friend_groups/friend_group_store_added_notification.dart';
import 'notification_types/orders/order_status_updated_notification.dart';
import 'notification_types/orders/order_marked_as_paid_notification.dart';
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

class NotificationItem extends StatefulWidget {
  
  final int index;
  final model.Notification notification;
  final GlobalKey<NotificationFiltersState> notificationFiltersState;

  const NotificationItem({
    super.key,
    required this.index,
    required this.notification,
    required this.notificationFiltersState
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  
  bool isLoadingOrder = false;
  bool isMarkingAsRead = false;
  
  model.Notification get notification => widget.notification;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  GlobalKey<NotificationFiltersState> get notificationFiltersState => widget.notificationFiltersState;
  NotificationProvider get notificationProvider => Provider.of<NotificationProvider>(context, listen: false);

  Widget get notificationContent {

    /// Order created
    if (notification.type == "App\\Notifications\\Orders\\OrderCreated") {
      
      return OrderCreatedNotificationContent(notification: notification, isLoading: isLoadingOrder);

    /// Order updated
    }else if (notification.type == "App\\Notifications\\Orders\\OrderUpdated") {
      
      return OrderUpdatedNotificationContent(notification: notification, isLoading: isLoadingOrder);

    /// Order seen
    }else if (notification.type == "App\\Notifications\\Orders\\OrderSeen") {
      
      return OrderSeenNotificationContent(notification: notification, isLoading: isLoadingOrder);

    /// Order status changed
    }else if (notification.type == "App\\Notifications\\Orders\\OrderStatusUpdated") {
      
      return OrderStatusUpdatedNotificationContent(notification: notification, isLoading: isLoadingOrder);

    /// Order mark as paid
    }else if (notification.type == "App\\Notifications\\Orders\\OrderMarkedAsPaid") {
      
      return OrderMarkedAsPaidNotificationContent(notification: notification, isLoading: isLoadingOrder);

    /// Order payment request
    }else if (notification.type == "App\\Notifications\\Orders\\OrderPaymentRequest") {
      
      return OrderPaymentRequestNotificationContent(notification: notification, isLoading: isLoadingOrder);

    /// Order paid
    }else if (notification.type == "App\\Notifications\\Orders\\OrderPaidUsingDpo") {
      
      return OrderPaidUsingDpoNotificationContent(notification: notification, isLoading: isLoadingOrder);

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

  Function? get notificationAction {

    final canShowOrder = [
      "App\\Notifications\\Orders\\OrderSeen",
      "App\\Notifications\\Orders\\OrderCreated",
      "App\\Notifications\\Orders\\OrderUpdated",
      "App\\Notifications\\Orders\\OrderPaidUsingDpo",
      "App\\Notifications\\Orders\\OrderMarkedAsPaid",
      "App\\Notifications\\Orders\\OrderStatusUpdated",
      "App\\Notifications\\Orders\\OrderPaymentRequest",
    ].contains(notification.type);

    if(canShowOrder) {
    
      return showOrderDialog;
    
    }else{
      
      return null;

    }

  }

  void showOrderDialog() {

    if(isLoadingOrder) return;

    OrderServices().showOrderDialogViaUrl(
      orderContentType: OrderContentType.orderFullContent,
      orderUrl: widget.notification.links.showOrder!.href,
      onStartLoader: _startShowOrderLoader,
      onStopLoader: _stopShowOrderLoader,
      orderProvider: orderProvider,
      context: context
    );

  }
  
  void _startShowOrderLoader() => setState(() => isLoadingOrder = true);
  void _stopShowOrderLoader() => setState(() => isLoadingOrder = false);
  void _startMarkingAsReadLoader() => setState(() => isMarkingAsRead = true);
  void _stopMarkingAsReadLoader() => setState(() => isMarkingAsRead = false);

  void onTap() {
    if(notificationAction != null) notificationAction!();
    if(notification.readAt == null) requestMarkNotificationAsRead();
  }

  void requestMarkNotificationAsRead() {

    if(isMarkingAsRead) return;

    _startMarkingAsReadLoader();

    /// Set that the notification has been read
    notification.readAt = DateTime.now();

    notificationProvider.setNotification(notification).notificationRepository
      .markNotificationAsRead()
      .then((response) async {

        if(response.statusCode == 200) {

          /// Decrement the total unread notifications by 1
          authProvider.resourceTotals!.totalUnreadNotifications -= 1;
          authProvider.setResourceTotals(authProvider.resourceTotals!);

          /**
           *  Refresh the notification filters
           *  ----
           * 
           *  Note that we prefer to set the "filter.total" and "filter.totalSummarized"
           *  manually than to make an API request to fetch the latest notification
           *  filters e.g:
           * 
           *  notificationFiltersState.currentState?.requestNotificationFilters()
           * 
           *  This is because we don't want to abuse this endpoint by having to make 
           *  a request evertime the user taps on each notification. Instead we will
           *  set the "filter.total" and manually work out the format of the
           *  "filter.totalSummarized" e.g 
           * 
           *  1,000       into  1k
           *  1,000,000   into  1m
           * 
           *  This way we can improve the performance of the application
           */
          for(Filter filter in notificationFiltersState.currentState?.notificationFilters?.filters ?? []) {

            final String filterName = filter.name.toLowerCase();

            if(filterName == 'read') {

              final int totalReadNotifications = filter.total + 1;
              
              notificationFiltersState.currentState?.setState(() {
                filter.total = totalReadNotifications;
                filter.totalSummarized = StringUtility.convertNumberToShortenedPrefix(totalReadNotifications);
              });

            }else if(filterName == 'unread') {

              final int totalUnreadNotifications = filter.total - 1;
          
              notificationFiltersState.currentState?.setState(() {
                filter.total = totalUnreadNotifications;
                filter.totalSummarized = StringUtility.convertNumberToShortenedPrefix(totalUnreadNotifications);
              });

            }

          }

        }else{

          /// Set that the notification has not been read
          notification.readAt = null;

        }

      }).catchError((error) {

        printError(info: error.toString());

      }).whenComplete(() {

        _stopMarkingAsReadLoader();

      });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.readAt == null ? Colors.amber.shade50 : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400, width: 1.0),  // Add a bottom border to separate the tiles
          ),
        ),
        child: ListTile(
          dense: false,
          onTap: onTap,
          title: notificationContent,
        ),
      ),
    );
  }
}