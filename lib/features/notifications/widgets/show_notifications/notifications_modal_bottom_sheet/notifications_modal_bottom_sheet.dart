import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_mark_as_paid_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_paid_using_dpo_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_created_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_payment_request_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_seen_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_status_updated_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/users/invitation_to_follow_store_created_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification_types/users/invitation_to_join_store_team_created_notification.dart';
import 'package:bonako_demo/features/user/models/resource_totals.dart';
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
  ResourceTotals? resourceTotals;
  late PusherProvider pusherProvider;
  ShoppableStore? get store => widget.store;
  NotificationContentView? notificationContentView;
  Widget Function(void Function())? get trigger => widget.trigger;
  int? get totalUnreadNotifications => resourceTotals?.totalUnreadNotifications;
  bool get hasUnreadNotifications => resourceTotals?.totalUnreadNotifications != 0;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  //// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  //// We can then fire methods of the child widget from this current Widget state. 
  //// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();
  
  @override
  void initState() {
    super.initState();
    pusherProvider = Provider.of<PusherProvider>(context, listen: false);
    listenForNewNotificationAlerts();
  }

  @override
  void dispose() {
    super.dispose();
    /// Unsubscribe from this specified event on this channel
    pusherProvider.unsubscribeToAuthNotifications(identifier: 'NotificationsModalBottomSheet');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the authenticated user's resource totals
    final ResourceTotals? updateResourceTotals = Provider.of<AuthProvider>(context, listen: false).resourceTotals;
  
    /// Update the local resourceTotals
    resourceTotals = updateResourceTotals;
    
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

      /// Increment the total unread notifications by 1
      authProvider.resourceTotals!.totalUnreadNotifications += 1;
      authProvider.setResourceTotals(authProvider.resourceTotals!);

      /// Parse event.data into a Map
      Map<String, dynamic> eventData = jsonDecode(event.data);

      //  Get the event type
      String type = eventData['type'];

      ///  Check if this is an order created notification
      if(type == 'App\\Notifications\\Orders\\OrderCreated') {
        
        final OrderCreatedNotification notification = OrderCreatedNotification.fromJson(eventData);
        final bool isAssociatedAsFriend = notification.orderProperties.isAssociatedAsFriend;
        final int orderForTotalFriends = notification.orderProperties.orderForTotalFriends;
        final String amount = notification.orderProperties.amount.amountWithCurrency;
        final String customerFirstName = notification.customerProperties.firstName;
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
        final bool isAssociatedAsFriend = notification.orderProperties.isAssociatedAsFriend;
        final String seenByUserFirstName = notification.seenByUserProperties.firstName;
        final String storeName = notification.storeProperties.name;

        if(isAssociatedAsFriend) {

          /// Show the message that informs the friend that their order has been seen
          SnackbarUtility.showSuccessMessage(message: 'Tagged order has been seen by $seenByUserFirstName @$storeName', duration: 4);

        }else{

          /// Show the message that informs the customer that their order has been seen
          SnackbarUtility.showSuccessMessage(message: 'Your order has been seen by $seenByUserFirstName @$storeName', duration: 4);
          
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
        
      /// Order payment request
      }else if(type == 'App\\Notifications\\Orders\\OrderPaymentRequest') {

        final OrderPaymentRequestNotification notification = OrderPaymentRequestNotification.fromJson(eventData);
        final String requestedByUserFirstName = notification.requestedByUserProperties.firstName;
        final Money amount = notification.transactionProperties.amount;
        final String storeName = notification.storeProperties.name;
        final String number = notification.orderProperties.number;

        /// Show the message that informs the payer of the payment request
        SnackbarUtility.showSuccessMessage(message: 'Payment requested by $requestedByUserFirstName @$storeName - ${amount.amountWithCurrency} for order #$number', duration: 4);
          
      }else if(type == 'App\\Notifications\\Orders\\OrderPaidUsingDpo') {

        final OrderPaidUsingDpoNotification notification = OrderPaidUsingDpoNotification.fromJson(eventData);
        final bool isAssociatedAsFriend = notification.orderProperties.isAssociatedAsFriend;
        final String dpoCustomerName = notification.transactionProperties.dpoCustomerName;
        final bool fullPayment = notification.transactionProperties.percentage == 100;
        final Money amount = notification.transactionProperties.amount;
        final String storeName = notification.storeProperties.name;
        final String number = notification.orderProperties.number;

        if(isAssociatedAsFriend) {

          /// Show the message that informs the friend that this order has been paid
          SnackbarUtility.showSuccessMessage(message: 'Tagged order has been ${fullPayment ? 'Fully' : 'Partially'} paid @$storeName - ${amount.amountWithCurrency} by $dpoCustomerName', duration: 4);

        }else{

          /// Show the message that informs everyone else that this order has been paid
          SnackbarUtility.showSuccessMessage(message: 'Order #$number ${fullPayment ? 'Fully' : 'Partially'} paid @$storeName - ${amount.amountWithCurrency} by $dpoCustomerName', duration: 4);
          
        }
        
      }else if(type == 'App\\Notifications\\Orders\\OrderMarkedAsPaid') {

        final OrderMarkedAsPaidNotification notification = OrderMarkedAsPaidNotification.fromJson(eventData);
        final bool isAssociatedAsFriend = notification.orderProperties.isAssociatedAsFriend;
        final bool fullPayment = notification.transactionProperties.percentage == 100;
        final String verifiedByUserName = notification.verifiedByUserProperties.name;
        final String paidByUserName = notification.paidByUserProperties.name;
        final Money amount = notification.transactionProperties.amount;
        final String storeName = notification.storeProperties.name;
        final String number = notification.orderProperties.number;

        if(isAssociatedAsFriend) {

          /// Show the message that informs the friend that this order has been marked as paid
          SnackbarUtility.showSuccessMessage(message: 'Tagged order has been marked as ${fullPayment ? 'Fully' : 'Partially'} paid @$storeName - ${amount.amountWithCurrency} by $paidByUserName and verified by $verifiedByUserName', duration: 4);

        }else{

          /// Show the message that informs everyone else that this order has been marked as paid
          SnackbarUtility.showSuccessMessage(message: 'Order #$number marked as ${fullPayment ? 'Fully' : 'Partially'} paid @$storeName - ${amount.amountWithCurrency} by $paidByUserName and verified by $verifiedByUserName', duration: 4);
          
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
          if(hasUnreadNotifications) counterBadge,

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

  void _listenForAuthProviderChanges(BuildContext context) {

    /// Listen for changes on the AuthProvider so that we can know when the authProvider.resourceTotals 
    /// have been updated. Once these changes occur, we can use the didChangeDependencies() to capture 
    /// and set these changes.
    Provider.of<AuthProvider>(context, listen: true);

  }

  @override
  Widget build(BuildContext context) {

    _listenForAuthProviderChanges(context);

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