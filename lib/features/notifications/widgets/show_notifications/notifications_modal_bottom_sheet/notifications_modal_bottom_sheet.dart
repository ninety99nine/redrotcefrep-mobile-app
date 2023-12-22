import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_paid_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_created_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_seen_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_status_updated_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/users/invitation_to_follow_store_created_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/users/invitation_to_join_store_team_created_notification.dart';
import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/features/notifications/enums/notification_enums.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:bonako_demo/core/shared_models/money.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/pusher.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../notifications_content.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class NotificationsModalBottomSheet extends StatefulWidget {
  
  final ShoppableStore? store;
  final Widget Function(void Function())? trigger;
  final NotificationContentView? notificationContentView;

  const NotificationsModalBottomSheet({
    super.key,
    this.store,
    this.trigger,
    this.notificationContentView
  });

  @override
  State<NotificationsModalBottomSheet> createState() => _NotificationsModalBottomSheetState();
}

class _NotificationsModalBottomSheetState extends State<NotificationsModalBottomSheet> {

  PusherChannelsFlutter? pusher;
  int totalUnreadNotifications = 0;
  late PusherProvider pusherProvider;
  ShoppableStore? get store => widget.store;
  NotificationContentView? notificationContentView;
  Widget Function(void Function())? get trigger => widget.trigger;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  //// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  //// We can then fire methods of the child widget from this current Widget state. 
  //// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();
  
  @override
  void initState() {
    super.initState();
    
    /// Set the Pusher Provider
    pusherProvider = Provider.of<PusherProvider>(context, listen: false);

    requestCountNotifications();
    listenForNewNotificationAlerts();
  }

  @override
  void dispose() {
    super.dispose();
    /// Unsubscribe from this specified event on this channel
    pusherProvider.unsubscribeToAuthNotifications(identifier: 'NotificationsModalBottomSheet');
  }

  //// Request the total authenticated user notifications
  //// This will allow us to show filters that can be used
  //// to filter the results of notifications returned on each request
  void requestCountNotifications() {
    
    authProvider.authRepository.countNotifications()
    .then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {
        
        //// Set the total notifications
        setState(() => totalUnreadNotifications = response.data['totalUnreadNotifications']);

      }

    });

  }

  void listenForNewNotificationAlerts() async {

      /// Subscribe to notification alerts
      pusherProvider.subscribeToAuthNotifications(
        identifier: 'NotificationsModalBottomSheet', 
        onEvent: onNotificationAlerts
      );

  }

  void onNotificationAlerts(event) {

    if (event.eventName == "Illuminate\\Notifications\\Events\\BroadcastNotificationCreated") {

      //// Increment the total notifications
      setState(() => ++totalUnreadNotifications);

      /// Parse event.data into a Map
      Map<String, dynamic> eventData = jsonDecode(event.data);

      //  Get the event type
      String type = eventData['type'];

      ///  Check if this is an order created notification
      if(type == 'App\\Notifications\\Orders\\OrderCreated') {
        
        final OrderCreatedNotification notification = OrderCreatedNotification.fromJson(eventData);
        final String customerFirstName = notification.orderProperties.customerProperties.firstName;
        final bool isAssociatedAsFriend = notification.orderProperties.isAssociatedAsFriend;
        final int orderForTotalFriends = notification.orderProperties.orderForTotalFriends;
        final String amount = notification.orderProperties.amount.amountWithCurrency;
        final String storeName = notification.storeProperties.name;
        final int otherTotalFriends = orderForTotalFriends - 1;

        if(isAssociatedAsFriend) {

          //  Set the message indicating the user's part in the order
          String message = '$customerFirstName ordered for you';

          //  Add more details indicating other user's part in the order
          if(otherTotalFriends > 0) message += ' and $otherTotalFriends ${otherTotalFriends == 1 ? 'other friend' : 'other friends'}';

          //  Add more details indicating the store that this order was placed at
          message += ' @$storeName';

          /// Show the message
          SnackbarUtility.showSuccessMessage(message: message, duration: 4);

        }else{

          /// Show the message that informs the team member of a new order
          SnackbarUtility.showSuccessMessage(message: 'New order placed @$storeName - $amount', duration: 4);
          
        }
        
      }else if(type == 'App\\Notifications\\Orders\\OrderSeen') {

        final OrderSeenNotification notification = OrderSeenNotification.fromJson(eventData);
        final String seenByUserName = notification.orderProperties.seenByUserProperties.firstName;
        final bool isAssociatedAsFriend = notification.orderProperties.isAssociatedAsFriend;
        final String storeName = notification.storeProperties.name;

        if(isAssociatedAsFriend) {

          /// Show the message that informs the friend that their order has been seen
          SnackbarUtility.showSuccessMessage(message: 'Tagged order has been seen by $seenByUserName @$storeName', duration: 4);

        }else{

          /// Show the message that informs the customer that their order has been seen
          SnackbarUtility.showSuccessMessage(message: 'Your order has been seen by $seenByUserName @$storeName', duration: 4);
          
        }
        
      }else if(type == 'App\\Notifications\\Orders\\OrderStatusUpdated') {

        final OrderStatusUpdatedNotification notification = OrderStatusUpdatedNotification.fromJson(eventData);
        final bool isAssociatedAsFriend = notification.orderProperties.isAssociatedAsFriend;
        final String status = notification.orderProperties.status.toLowerCase();
        final String storeName = notification.storeProperties.name;

        if(isAssociatedAsFriend) {

          /// Show the message that informs the friend that their order status has changed
          SnackbarUtility.showSuccessMessage(message: 'Tagged order is $status @$storeName', duration: 4);

        }else{

          /// Show the message that informs the customer that their order status has changed
          SnackbarUtility.showSuccessMessage(message: 'Your order is $status @$storeName', duration: 4);
          
        }
        
      }else if(type == 'App\\Notifications\\Orders\\OrderPaid') {

        final OrderPaidNotification notification = OrderPaidNotification.fromJson(eventData);
        final bool isAssociatedAsFriend = notification.orderProperties.isAssociatedAsFriend;
        final String payerName = notification.transactionProperties.payerName;
        final Money amount = notification.transactionProperties.amount;
        final String storeName = notification.storeProperties.name;
        final String number = notification.orderProperties.number;

        if(isAssociatedAsFriend) {

          /// Show the message that informs the friend that this order has been paid
          SnackbarUtility.showSuccessMessage(message: 'Tagged order has been paid @$storeName - ${amount.amountWithCurrency} by $payerName', duration: 4);

        }else{

          /// Show the message that informs the everyone else that this order has been paid
          SnackbarUtility.showSuccessMessage(message: 'Order #$number paid @$storeName - ${amount.amountWithCurrency} by $payerName', duration: 4);
          
        }
        
      ///  Check if this is an invitation to follow a store
      }else if(type == 'App\\Notifications\\Users\\InvitationToFollowStoreCreated') {

        final InvitationToFollowStoreCreatedNotification notification = InvitationToFollowStoreCreatedNotification.fromJson(eventData);
        final String invitedByUserName = notification.invitedByUserProperties.name;
        final String storeName = notification.storeProperties.name;

        /// Show the message that informs the user about a new invitation
        SnackbarUtility.showSuccessMessage(message: '$invitedByUserName invited you to follow $storeName', duration: 4);
        
      ///  Check if this is an invitation to join store team
      }else if(type == 'App\\Notifications\\Users\\InvitationToJoinStoreTeamCreated') {

        final InvitationToJoinStoreTeamCreatedNotification notification = InvitationToJoinStoreTeamCreatedNotification.fromJson(eventData);
        final String invitedByUserName = notification.invitedByUserProperties.name;
        final String storeName = notification.storeProperties.name;

        /// Show the message that informs the user about a new invitation
        SnackbarUtility.showSuccessMessage(message: '$invitedByUserName invited you to join $storeName team', duration: 4);
        
      }
    }
  }

  Widget get _trigger {

    Widget counterBadge = GestureDetector(
      onTap: openBottomModalSheet,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          /*
          boxShadow: [
            BoxShadow(
              spreadRadius: 1,
              blurRadius: 5,
              color: Colors.black.withAlpha(50))
          ],
          */
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        ),
        child: Text("$totalUnreadNotifications", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1)),
      ),
    );

    floatingActionButton(openBottomModalSheet) => FloatingActionButton(
      mini: true,
      heroTag: 'notifications-button',
      onPressed: openBottomModalSheet,
      child: const Icon(Icons.notifications_none_rounded)
    );

    return FittedBox(
      child: Stack(
        alignment: const Alignment(1.4, -1.4),
        children: [

          //// Floating Action Button
          floatingActionButton(openBottomModalSheet),

          //// Counter Badge
          if(totalUnreadNotifications > 0) counterBadge,

        ],
      ),
    );

  }

  //// Open the bottom modal sheet
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      //// Trigger to open the bottom modal sheet
      trigger: _trigger,
      //// Content of the bottom modal sheet
      content: NotificationsContent(
        store: store,
        notificationContentView: notificationContentView,
      ),
    );
  }
}