import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/notifications/providers/notification_provider.dart';
import 'package:bonako_demo/features/user/models/resource_totals.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'notifications_in_vertical_list_view_infinite_scroll.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'notifications_page/notifications_page.dart';
import '../../enums/notification_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'notification_filters.dart';
import 'package:get/get.dart';

class NotificationsContent extends StatefulWidget {
  
  final bool showingFullPage;
  final ShoppableStore? store;
  final NotificationContentView? notificationContentView;

  const NotificationsContent({
    super.key,
    required this.store,
    this.notificationContentView,
    this.showingFullPage = false,
  });

  @override
  State<NotificationsContent> createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<NotificationsContent> {

  bool isMarkingAsRead = false;
  ResourceTotals? resourceTotals;
  String notificationFilter = 'All';
  NotificationContentView notificationContentView = NotificationContentView.viewingNotifications;
  final GlobalKey<NotificationFiltersState> notificationFiltersState = GlobalKey<NotificationFiltersState>();
  final GlobalKey<NotificationsInVerticalListViewInfiniteScrollState> notificationsInVerticalListViewInfiniteScrollState = GlobalKey<NotificationsInVerticalListViewInfiniteScrollState>();

  ShoppableStore? get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  bool get hasUnreadNotifications => resourceTotals?.totalUnreadNotifications != 0;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isViewingSettings => notificationContentView == NotificationContentView.viewingSettings;
  NotificationProvider get notificationProvider => Provider.of<NotificationProvider>(context, listen: false);
  bool get isViewingNotifications => notificationContentView == NotificationContentView.viewingNotifications;

  void _startMarkingAsReadLoader() => setState(() => isMarkingAsRead = true);
  void _stopMarkingAsReadLoader() => setState(() => isMarkingAsRead = false);

  @override
  void initState() {
    super.initState();
    if(widget.notificationContentView != null) notificationContentView = widget.notificationContentView!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the authenticated user's resource totals
    final ResourceTotals? updateResourceTotals = Provider.of<AuthProvider>(context, listen: false).resourceTotals;
  
    /// Update the local resourceTotals
    resourceTotals = updateResourceTotals;
    
  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the notifications content
    if(isViewingNotifications) {

      /// Show notifications view
      return NotificationsInVerticalListViewInfiniteScroll(
        store: store,
        notificationFilter: notificationFilter,
        notificationFiltersState: notificationFiltersState,
        key: notificationsInVerticalListViewInfiniteScrollState,
      );

    /// If we want to view the create notification content
    }else {

      /// Show notifications view
      return const CustomBodyText('Settings');
      
    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    /// Back button
    return CustomElevatedButton(
      'Back',
      width: 60,
      color: Colors.grey,
      onPressed: () => onGoBack(),
      prefixIcon: Icons.keyboard_double_arrow_left,
    );

  }

  void onGoBack(){
    changeNotificationContentView(NotificationContentView.viewingNotifications);
  }

  /// Called when the settings button has been tapped
  void showSettings() {
    changeNotificationContentView(NotificationContentView.viewingSettings);
  }

  /// Called when the order filter has been changed,
  /// such as changing from "Joined" to "Left"
  void onSelectedNotificationFilter(String notificationFilter) {
    setState(() => this.notificationFilter = notificationFilter);
  }

  /// Called to change the view to the specified view
  void changeNotificationContentView(NotificationContentView notificationContentView) {
    setState(() => this.notificationContentView = notificationContentView);
  }

  /// Request notification filters
  void refreshNotificationFilters() {
    notificationFiltersState.currentState?.requestNotificationFilters();
  }

  void requestMarkNotificationsAsRead() {

    if(isMarkingAsRead) return;

    _startMarkingAsReadLoader();

    notificationProvider.notificationRepository
      .markNotificationsAsRead()
      .then((response) async {

        if(response.statusCode == 200) {
          
          /// Set the total unread notifications to zero
          authProvider.resourceTotals!.totalUnreadNotifications = 0;
          authProvider.setResourceTotals(authProvider.resourceTotals!);
          notificationsInVerticalListViewInfiniteScrollState.currentState?.setAllNotificationsAsRead();

          /// We know that the total notifications that have been marked as unread is zero, however its hard 
          /// to determine the total notifications that have been marked as read. We are therefore forced to 
          /// request the notification filters so that we can return the correct number of notifications 
          /// that have been marked as read. 
          refreshNotificationFilters();

        }

      }).catchError((error) {

        printError(info: error.toString());

      }).whenComplete(() {

        _stopMarkingAsReadLoader();

      });
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

    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(notificationContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, bottom: isViewingSettings ? 8 : 0, left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      /// Title
                      CustomTitleMediumText(isViewingNotifications ? 'Notifications' : 'Notification Settings', padding: EdgeInsets.only(bottom: 8),),
                  
                      //  Filter
                      if(isViewingNotifications) NotificationFilters(
                        store: store,
                        key: notificationFiltersState,
                        notificationFilter: notificationFilter,
                        onSelectedNotificationFilter: onSelectedNotificationFilter,
                      ),
                      
                    ],
                  ),
                ),

                const Divider(height: 0,),

                /// Settings
                SizedBox(
                  width: double.infinity,
                  child: AnimatedSize(
                    clipBehavior: Clip.none,
                    duration: const Duration(milliseconds: 500),
                    child: AnimatedSwitcher(
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      duration: const Duration(milliseconds: 500),
                      child: isViewingSettings ? null : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                      
                            CustomTextButton(
                              'Settings',
                              padding: const EdgeInsets.all(12),
                              prefixIcon: Icons.settings,
                              onPressed: showSettings,
                              prefixIconSize: 20,
                            ),
                      
                            if(hasUnreadNotifications) CustomTextButton(
                              'Mark As Read',
                              onPressed: requestMarkNotificationsAsRead,
                              padding: const EdgeInsets.all(12),
                              isLoading: isMarkingAsRead,
                              prefixIcon: Icons.check,
                              prefixIconSize: 20,
                            ),
                      
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          
                /// Content
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    color: Colors.white,
                    child: content,
                  ),
                )
            
              ],
            ),
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();

                /// Set the store
                if(store != null) storeProvider.setStore(store!);
                
                /// Navigate to the page
                Get.toNamed(NotificationsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button (show if provided)
          if(isViewingSettings) AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingNotifications ? 112 : 60) + topPadding,
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}