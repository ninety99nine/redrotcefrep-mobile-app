import 'dart:convert';

import 'package:bonako_demo/core/utils/pusher.dart';

import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/notifications/providers/notification_provider.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'notification_filters.dart';
import 'notification_item.dart';

class NotificationsInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final ShoppableStore? store;
  final String notificationFilter;
  final Function(model.Notification) onSelectedNotification;
  final GlobalKey<NotificationFiltersState> notificationFiltersState;

  const NotificationsInVerticalListViewInfiniteScroll({
    super.key,
    required this.store,
    required this.notificationFilter,
    required this.onSelectedNotification,
    required this.notificationFiltersState,
  });

  @override
  State<NotificationsInVerticalListViewInfiniteScroll> createState() => _NotificationsInVerticalListViewInfiniteScrollState();
}

class _NotificationsInVerticalListViewInfiniteScrollState extends State<NotificationsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  late PusherProvider pusherProvider;

  ShoppableStore? get store => widget.store;
  String get notificationFilter => widget.notificationFilter;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  Function(model.Notification) get onSelectedNotification => widget.onSelectedNotification;
  GlobalKey<NotificationFiltersState> get notificationFiltersState => widget.notificationFiltersState;
  NotificationProvider get notificationProvider => Provider.of<NotificationProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the Pusher Provider
    pusherProvider = Provider.of<PusherProvider>(context, listen: false);

    listenForNewNotificationAlerts();
  }

  @override
  void dispose() {
    super.dispose();
    /// Unsubscribe from this specified event on this channel
    pusherProvider.unsubscribeToAuthNotifications(identifier: 'NotificationsInVerticalListViewInfiniteScroll');
  }

  void listenForNewNotificationAlerts() async {

      /// Subscribe to notification alerts
      pusherProvider.subscribeToAuthNotifications(
        identifier: 'NotificationsInVerticalListViewInfiniteScroll', 
        onEvent: onNotificationAlerts
      );

  }

  void onNotificationAlerts(event) {

    if (event.eventName == "Illuminate\\Notifications\\Events\\BroadcastNotificationCreated") {

      /// Refresh the notifications to show the new notification
      _customVerticalListViewInfiniteScrollState.currentState?.startRequest();

    }

  }

  /// Render each request item as an NotificationItem
  Widget onRenderItem(notification, int index, List notifications, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => NotificationItem(
    notification: (notification as model.Notification),
    onSelectedNotification: onSelectedNotification,
    index: index
  );
  
  /// Render each request item as an Notification
  model.Notification onParseItem(notification) => model.Notification.fromJson(notification);
  Future<http.Response> requestStoreNotifications(int page, String searchWord) {
    return authProvider.authRepository.showNotifications(
      /// Filter by the notification filter specified (notificationFilter)
      filter: notificationFilter,
      page: page
    );
  }

  @override
  void didUpdateWidget(covariant NotificationsInVerticalListViewInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the notification filter changed
    if(notificationFilter != oldWidget.notificationFilter) {

      /// Start a new request
      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      showSeparater: false,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      listPadding: const EdgeInsets.all(0),
      catchErrorMessage: 'Can\'t show notifications',
      key: _customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestStoreNotifications(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
    );
  }
}