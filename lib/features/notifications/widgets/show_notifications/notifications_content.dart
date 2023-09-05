import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:get/get.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'notifications_in_vertical_list_view_infinite_scroll.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:bonako_demo/core/utils/pusher.dart';
import 'notifications_page/notifications_page.dart';
import '../../enums/notification_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'notification_filters.dart';

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

  model.Notification? notification;
  String notificationFilter = 'All';
  NotificationContentView notificationContentView = NotificationContentView.viewingNotifications;

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<NotificationFiltersState> notificationFiltersState = GlobalKey<NotificationFiltersState>();

  ShoppableStore? get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isViewingNotification => notificationContentView == NotificationContentView.viewingNotification;
  bool get isViewingNotifications => notificationContentView == NotificationContentView.viewingNotifications;
  String get subtitle {

    final bool showingAllNotifications = notificationFilter.toLowerCase() == 'all';
    final bool showingReadNotifications = notificationFilter.toLowerCase() == 'read';
    final bool showingUnreadNotifications = notificationFilter.toLowerCase() == 'unread';
    
    if(showingAllNotifications) {
      return 'Showing all notifications';
    }else if(showingReadNotifications) {
      return 'Showing read notifications';
    }else if(showingUnreadNotifications) {
      return 'Showing unread notifications';
    }else{
      return '';
    }

  }

  @override
  void initState() {
    super.initState();
    if(widget.notificationContentView != null) notificationContentView = widget.notificationContentView!;
  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the notifications content
    if(isViewingNotifications) {

      /// Show notifications view
      return NotificationsInVerticalListViewInfiniteScroll(
        store: store,
        notificationFilter: notificationFilter,
        onSelectedNotification: onSelectedNotification,
        notificationFiltersState: notificationFiltersState
      );

    /// If we want to view the create notification content
    }else {

      /// Show notifications view
      return NotificationsInVerticalListViewInfiniteScroll(
        store: store,
        notificationFilter: notificationFilter,
        onSelectedNotification: onSelectedNotification,
        notificationFiltersState: notificationFiltersState
      );
      
    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    /// Back button
    return SizedBox(
      width: 48,
      child: CustomElevatedButton(
        '',
        color: Colors.grey,
        onPressed: () => onGoBack(),
        prefixIcon: Icons.keyboard_double_arrow_left,
      ),
    );

  }

  void onGoBack(){
    notification = null;
    changeNotificationContentView(NotificationContentView.viewingNotifications);
  }

  void onSelectedNotification(model.Notification notification){
    notification = notification;
    changeNotificationContentView(NotificationContentView.viewingNotification);
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

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      /// Title
                      const CustomTitleMediumText('Notifications', padding: EdgeInsets.only(bottom: 8),),
                      
                      /// Subtitle
                      AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: Align(
                          key: ValueKey(subtitle),
                          alignment: Alignment.centerLeft,
                          child: CustomBodyText(subtitle),
                        )
                      ),
                  
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                
                      CustomTextButton(
                        'Settings',
                        padding: const EdgeInsets.all(12),
                        prefixIcon: Icons.settings,
                        prefixIconSize: 20,
                        onPressed: () {
                      
                        },
                      ),
                
                      CustomTextButton(
                        'Mark As Read',
                        padding: const EdgeInsets.all(12),
                        prefixIcon: Icons.check,
                        prefixIconSize: 20,
                        onPressed: () {
                      
                        },
                      ),
                
                    ],
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
          if(isViewingNotification) AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingNotifications ? 112 : 56) + topPadding,
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}