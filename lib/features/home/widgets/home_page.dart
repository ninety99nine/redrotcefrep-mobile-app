import 'package:bonako_demo/features/chat/widgets/ai_chat_modal_bottom_sheet/ai_chat_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/notifications/widgets/show_notifications/notifications_modal_bottom_sheet/notifications_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/qr_code_scanner/widgets/qr_code_scanner_modal_bottom_sheet/qr_code_scanner_modal_popup.dart';
import 'package:bonako_demo/features/search/widgets/search_show/search_modal_bottom_sheet/search_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/home/widgets/tab_content/my_stores_page_content/my_stores_page_content.dart';
import 'package:bonako_demo/features/home/widgets/tab_content/groups_page_content/groups_page_content.dart';
import 'package:bonako_demo/features/home/widgets/tab_content/order_page_content/order_page_content.dart';
import 'package:bonako_demo/features/home/widgets/tab_content/chat_page_content/chat_page_content.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/animated_widgets/custom_rotating_widget.dart';
import 'package:bonako_demo/features/home/widgets/tab_content/profile_page_content.dart';
import 'package:bonako_demo/features/authentication/repositories/auth_repository.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/introduction/widgets/landing_page.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/utils/internet_connectivity_utility.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:bonako_demo/features/user/models/resource_totals.dart';
import 'package:bonako_demo/features/home/services/home_service.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/core/utils/pusher.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  bool isLoggingOut = false;
  int totalNavigationTabs = 5;
  late PusherProvider pusherProvider;
  bool isLoadingResourceTotals = false;
  late final TabController _tabController;
  bool isGettingSelectedHomeTabIndexFromDeviceStorage = true;
  InternetConnectivityUtility internetConnectivityUtility = InternetConnectivityUtility();

  bool get hideFloatingActionButton => selectedHomeTabIndex == 4;
  bool get doesNotHaveResourceTotals => hasResourceTotals == false;
  AuthRepository get authRepository => authProvider.authRepository;
  bool get hasResourceTotals => authProvider.resourceTotals != null;
  int get selectedHomeTabIndex => homeProvider.selectedHomeTabIndex;
  bool get hasConnection => internetConnectivityUtility.hasConnection;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  bool get canShowFloatingActionButtons => selectedHomeTabIndex != 4 && hasResourceTotals;
  bool get isCheckingInternetConnectivity => internetConnectivityUtility.isCheckingInternetConnectivity;

  void _startLoggingOutLoader() => setState(() => isLoggingOut = true);
  void _stopLoggingOutLoader() => setState(() => isLoggingOut = false);
  
  void _startResourceTotalsLoader() => setState(() => isLoadingResourceTotals = true);
  void _stopResourceTotalsLoader() => setState(() => isLoadingResourceTotals = false);
  
  final List<Map> primaryNavigationTabs = [
    {
      'name': 'Profile',
      'icon': Icons.person,
      'index': 0
    },
    {
      'name': 'Order',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'index': 1
    },
    {
      'name': 'My Stores',
      'icon': Icons.storefront_outlined,
      'index': 2
    },
    {
      'name': 'Groups',
      'icon': Icons.group_rounded,
      'index': 3
    }
  ];
  
  final List<Map> secondaryNavigationTabs = [
    {
      'name': 'Ask AI',
      'icon': Icons.bubble_chart,
      'index': 4
    },
    {
      'name': 'Advertiser',
      'icon': Icons.local_convenience_store_rounded,
      'index': null
    },
    {
      'name': 'Sms Alerts',
      'icon': Icons.sms,
      'index': null
    },
    {
      'name': 'Shortcodes',
      'icon': Icons.abc,
      'index': null
    },
    {
      'name': 'Sign Out',
      'icon': Icons.exit_to_app_rounded,
      'index': null
    }
  ];

  @override
  void initState() {
    super.initState();

    _initializeTabController();
    _setupTabControllerListener();
    _navigateToLastSelectedNavigationTab();

    /// Check and update the internet connectivity status
    internetConnectivityUtility.checkAndUpdateInternetConnectivityStatus(
      setState: setState
    ).then((currentlyHasConnection) {

      /// Request the resource totals
      _requestShowResourceTotals();

      //  Subcribe to auth notifications
      _subscribeToAuthNotifications();

    });

    /// Setup the internet connectivity listener - Continue listening for connectivity changes
    internetConnectivityUtility.setupInternetConnectivityListener(
      onDisconnected: _onDisconnected,
      onConnected: _onConnected,
      setState: setState
    );

  }

  @override
  void dispose() {
    
    super.dispose();

    /// Cancel the internet connectivity listener
    internetConnectivityUtility.dispose();

    /// Unsubscribe from this specified event on this channel
    pusherProvider.unsubscribeToAuthNotifications(identifier: 'HomePage');

  }

  /// Initialize the tab controller
  void _initializeTabController() {
    _tabController = TabController(initialIndex: selectedHomeTabIndex, length: totalNavigationTabs, vsync: this);
  }

  /// Setup the tab controller listener - Continue listening for tab changes
  void _setupTabControllerListener() {
    
    /// This _tabController listener is used to check if we have navigated to another tab
    _tabController.addListener(() {

      /// Request the resource totals
      _requestShowResourceTotals();

    });

  }

  /// Navigate to the last selected navigation tab (Check device storage)
  void _navigateToLastSelectedNavigationTab() {

    Future.delayed(Duration.zero).then((value) async {

      HomeService.getSelectedHomeTabIndexFromDeviceStorage().then((lastSelectedHomeTabIndex) {

        isGettingSelectedHomeTabIndexFromDeviceStorage = false;
        _changeNavigationTab(lastSelectedHomeTabIndex);

      });

    });
  }

  /// Request the authenticated user resource totals
  Future<dio.Response?> _requestShowResourceTotals() async {

    if(hasConnection && !isLoadingResourceTotals) {

      _startResourceTotalsLoader();

      return authRepository.showResourceTotals().then((response) async {

        if(response.statusCode == 200) {

          final ResourceTotals resourceTotals = ResourceTotals.fromJson(response.data);
          authProvider.setResourceTotals(resourceTotals);

          /*
          /// The OneSignal Free plan only allows a maximum of three tags per user
          /// We can unlock more tags by using a higher plan: https://onesignal.com/pricing
            'totalOrders': resourceTotals.totalOrders,
            'totalReviews': resourceTotals.totalReviews,
            'totalGroupsJoined': resourceTotals.totalGroupsJoined,
            'totalNotifications': resourceTotals.totalNotifications,
            'totalSmsAlertCredits': resourceTotals.totalSmsAlertCredits,
            'totalStoresAsFollower': resourceTotals.totalStoresAsFollower,
            'totalStoresAsCustomer': resourceTotals.totalStoresAsCustomer,
            'totalGroupsJoinedAsCreator': resourceTotals.totalGroupsJoinedAsCreator,
            'totalStoresJoinedAsCreator': resourceTotals.totalStoresJoinedAsCreator,
            'totalStoresAsRecentVisitor': resourceTotals.totalStoresAsRecentVisitor,
            'totalGroupsJoinedAsNonCreator': resourceTotals.totalGroupsJoinedAsNonCreator,
            'totalStoresJoinedAsTeamMember': resourceTotals.totalStoresJoinedAsTeamMember,
            'totalStoresJoinedAsNonCreator': resourceTotals.totalStoresJoinedAsNonCreator,
            'totalStoresInvitedToJoinAsTeamMember': resourceTotals.totalStoresInvitedToJoinAsTeamMember,
            'totalGroupsInvitedToJoinAsGroupMember': resourceTotals.totalGroupsInvitedToJoinAsGroupMember,
          });
          */

        }else{

          SnackbarUtility.showErrorMessage(message: 'Failed to get resource totals');

        }

        return response;

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to show resource totals');

        return error;

      }).whenComplete(() {

        _stopResourceTotalsLoader();

      });

    }else{

      /// Return null as the Future value
      return Future.delayed(Duration.zero).then((_) => null);

    }

  }

  /// Subscribe to Auth notification event alerts
  void _subscribeToAuthNotifications() async {
    
    /// Set the Pusher Provider
    pusherProvider = Provider.of<PusherProvider>(context, listen: false);

    /// Subscribe to notification alerts
    pusherProvider.subscribeToAuthNotifications(
      onEvent: _onNotificationAlerts,
      identifier: 'HomePage', 
    );
  
  }

  /// Handle Auth notification event alerts
  void _onNotificationAlerts(event) {

    if (event.eventName == "Illuminate\\Notifications\\Events\\BroadcastNotificationCreated") {

      if(authProvider.hasNotifications == false) {

        /// Request the resource totals to show the notifications floating action button
        _requestShowResourceTotals();

      }else{

        /// Parse event.data into a Map
        Map<String, dynamic> eventData = jsonDecode(event.data);

        //  Get the event type
        String type = eventData['type'];

        if(!authProvider.hasStoresJoinedAsTeamMember!) {
        
          ///  Check if this is a notification of a created or deleted store
          if(type == "App\\Notifications\\Stores\\StoreCreated" || type == "App\\Notifications\\Stores\\StoreDeleted") {

            /// Request the resource totals to show/hide the qr code floating action button
            _requestShowResourceTotals();
            
          }

        }

      }

    }

  }

  /// Internet connected callback
  void _onConnected() {
      
    /// Request the resource totals
    _requestShowResourceTotals();

  }

  /// Internet disconnected callback
  void _onDisconnected() {

  }

  /// Change the navigation tab
  void _changeNavigationTab(int index) {
    setState(() {
      homeProvider.setSelectedHomeTabIndex(index);
      _tabController.index = index;
    });
  }

  /// Request to logout
  void _requestLogout() {

    if(isLoggingOut) return;

    _startLoggingOutLoader();

    //  Show logging out loader
    DialogUtility.showLoader(message: 'Signing out');

    authRepository.logout().then((response) async {

      /**
       *  OneSignal Logout
       *  ----------------
       *  It is only recommended to call this method if you do not want to send transactional push notifications 
       *  to this device upon logout. For example, if your app sends targeted or personalized messages to users 
       *  based on their aliases and its expected that upon logout, that device should not get those types of 
       *  messages anymore, then it is a good idea to call OneSignal.logout()
       * 
       *  https://documentation.onesignal.com/docs/aliases-external-id#when-should-i-call-onesignallogout
       */
      await OneSignal.logout();

      /// Hide logging out loader
      DialogUtility.hideLoader();

      if(response.statusCode == 200) {
        
        /// Show the success message
        SnackbarUtility.showSuccessMessage(message: response.data['message']);
        
      }

    }).catchError((error) {

      printError(info: error.toString());

      /**
       *  Hide logging out loader
       * 
       *  We are placing this method in the catchError() instead of the whenComplete()
       *  method because should an error occur, then this catchError() method will 
       *  run the SnackbarUtility.showErrorMessage() to show the snackbar message,
       *  but then DialogUtility.hideLoader() would hide the SnackbarUtility 
       *  message instead of the DialogUtility message since catchError() 
       *  would run before whenComplete() showing the snackbar message
       *  and then dismissing the snackbar message instead of the
       *  dialog loader.
       * 
       *  This is because SnackbarUtility.showErrorMessage() will fire first and
       *  then DialogUtility.hideLoader() will fire next. We need to make sure
       *  that DialogUtility.hideLoader() fires first and then
       *  SnackbarUtility.showErrorMessage() fires next.
       */
      DialogUtility.hideLoader();
  
      /// Show the fatal error message
      SnackbarUtility.showErrorMessage(message: 'Failed to sign out');

    }).whenComplete(() {

      _stopLoggingOutLoader();

      /**
       *  Navigate to the landing page on successful
       *  or unsuccessful signing out.
       */       
      Get.offAndToNamed(LandingPage.routeName);

    });
  }

  /// Open dialog to show secondary navigation tabs
  void _showSecondaryNavigationTabsDialog() {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Dismiss',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {

        /// Dialog content
        return dialogContent;

      },
    );
  }

  FloatingActionButtonLocation? get floatingActionButtonLocation {

    /// If the internet is connected
    if(hasConnection) {

      if(hideFloatingActionButton) {
        return FloatingActionButtonLocation.endContained;
      }else{
        return FloatingActionButtonLocation.centerDocked;
      }

    /// If the internet is disconnected
    }else{

      return null;

    }
  }

  Widget? get floatingActionButton {

    /// If the internet is connected
    if(hasConnection) {

      /// Floating Action Button
      return FloatingActionButton(
        mini: hideFloatingActionButton,
        backgroundColor: Colors.black,
        onPressed: _showSecondaryNavigationTabsDialog,
        child: floatingActionButtonLogo,
      );

    /// If the internet is disconnected
    }else{

      return null;

    }
  }

  Widget get floatingActionButtonLogo {
    return SizedBox(
      child: CustomRotatingWidget(
        maxRotations: 1,
        delayDuration: const Duration(seconds: 2),
        animationDuration: const Duration(seconds: 2),
        child: Image.asset('assets/images/logo-black.png')
      )
    );
  }

  /// Secondary navigation dialog content
  Widget get dialogContent {

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.only(bottom: hideFloatingActionButton ? 50 : 0, left: 16, right: 16),
        child: Column(
          children: [
      
            /// Dialog Logo
            dialogLogo,
            
            /// Spacer
            const SizedBox(height: 8.0),

            /// Navigation Tabs
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white54)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    childAspectRatio: 1.2
                  ),
                  itemCount: secondaryNavigationTabs.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    
                    /// Build each secondary navigation tab
                    return secondaryNavigationTab(secondaryNavigationTabs[index]);

                  },
                ),
              ),
            ),
      
          ],
        ),
      ),
    );
  }

  /// Dialog logo
  Widget get dialogLogo {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: SizedBox(
        width: 60,
        child: CustomRotatingWidget(
          delayDuration: const Duration(seconds: 60),
          animationDuration: const Duration(seconds: 2),
          child: Image.asset('assets/images/logo-black.png')
        )
      ),
    );
  }

  /// Secondary navigation tab
  Widget secondaryNavigationTab(Map tab) {

    final int? menuIndex = tab['index'];
    final String menuName = tab['name'];
    final IconData menuIcon = tab['icon'];
    final bool isSelected = selectedHomeTabIndex == menuIndex;

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      child: Material(
        elevation: 5,
        color: Colors.transparent,
        child: InkWell(
          onTap: () {

            /// Close the dialog
            Get.back();

            /// If we want to logout
            if(menuName == 'Sign Out') {

              /// Request to logout
              _requestLogout();

            }else{

              /// Navigate to the specified page
              if(menuIndex != null) _changeNavigationTab(menuIndex);

            }
          },
          splashColor: Colors.white10,
          highlightColor: Colors.white10,
          child: Column(
            children: [

              /// Navigation Icon
              CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.white10,
                child: Icon(menuIcon, color: isSelected ? Colors.yellow : Colors.white),
              ),

              /// Spacer
              const SizedBox(height: 8),

              /// Navigation Name
              CustomBodyText(menuName, fontSize: 12, color: isSelected ? Colors.yellow : Colors.white),

            ],
          ),
        ),
      ),
    );
  }

  /// Bottom navigation bar
  Widget? get bottomNavigationBar {

    if(isCheckingInternetConnectivity) {

      return null;

    }else{

      Widget bottomNavigationBarContent;
      
      if(hasConnection) {

        bottomNavigationBarContent = bottomNavigationBarNavigationTabs;

      }else{

        bottomNavigationBarContent = bottomNavigationBarNoInternetNotice;

      }

      return BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        child: bottomNavigationBarContent
      );

    }

  }

  /// Bottom navigation bar navigation tabs
  Widget get bottomNavigationBarNavigationTabs {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        /// Show the first two tabs
        ...primaryNavigationTabs.take(2).map((tab) {

          return primaryNavigationTab(tab);

        }).toList(),
        
        /// Conditional spacer - Create space for the FAB when not hidden
        if(!hideFloatingActionButton) const SizedBox(width: 60.0),

        /// Show the next two tabs
        ...primaryNavigationTabs.skip(2).map((tab) {

          return primaryNavigationTab(tab);

        }).toList(),
        
        /// Conditional spacer - Create space for the FAB when hidden
        if(hideFloatingActionButton) const SizedBox(width: 60.0),

      ]
    );

  }

  /// Bottom navigation bar no internet notice
  Widget get bottomNavigationBarNoInternetNotice {

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.wifi_off_rounded, color: Colors.white,),
          SizedBox(width: 8,),
          CustomBodyText('No internet connection', color: Colors.white),
        ]
      ),
    );

  }

  /// Primary navigation tab
  Widget primaryNavigationTab(Map tab) {

    final int menuIndex = tab['index'];
    final String menuName = tab['name'];
    final IconData menuIcon = tab['icon'];
    final bool isSelected = selectedHomeTabIndex == menuIndex;

    return InkWell(
      onTap: () {
        _changeNavigationTab(menuIndex);
      },
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Navigation Icon
            Icon(menuIcon, size: 28.0, color: isSelected ? Colors.yellow : Colors.white),

            /// Spacer
            const SizedBox(height: 4.0,),

            /// Navigation Name
            if(!hideFloatingActionButton) ...[

              CustomBodyText(
                menuName, 
                fontSize: 12, 
                color: isSelected ? Colors.yellow : Colors.white
              ),

            ]
          ],
        ),
      ),
    );
  }

  Widget get body {
    return SafeArea(
      child: Stack(
        children: [

          /// Tab content
          tabContent,

          /// Secondary floating action buttons
          secondaryFloatingActionButtons
          
        ],
      )
    );
  }

  Widget get tabContent {

    return isGettingSelectedHomeTabIndexFromDeviceStorage
      
      /// Show Loader while getting the last selected home tab index form device storage
      ? const CustomCircularProgressIndicator()

      : TabBarView(
        physics: const NeverScrollableScrollPhysics(),  // Disable navigation by swiping
        controller: _tabController,
        children: [
      
          /// Profile page
          ProfilePageContent(
            onChangeNavigationTab: _changeNavigationTab
          ),
      
          /// Order page
          OrderPageContent(
            onChangeNavigationTab: _changeNavigationTab
          ),
      
          /// My stores page
          MyStoresPageContent(
            onChangeNavigationTab: _changeNavigationTab,
            onRequestShowResourceTotals: _requestShowResourceTotals
          ),
      
          /// Groups page
          GroupsPageContent(
            onChangeNavigationTab: _changeNavigationTab,
            onRequestShowResourceTotals: _requestShowResourceTotals
          ),
      
          /// Chat page
          const ChatPageContent(),
      
        ],
      );
  }

  Widget get secondaryFloatingActionButtons {

    return Positioned(
      right: 8,
      bottom: 16,
      child: AnimatedOpacity(
        opacity: isLoadingResourceTotals ? 0 : 1,
        duration: const Duration(seconds: 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: canShowFloatingActionButtons ? [
      
            /// Notifications Floating Action Button
            if(authProvider.hasNotifications!) notificationFloatingActionButton,
            
            /// QR Code Scanner Floating Action Button
            if(authProvider.hasStoresJoinedAsTeamMember!) qrCodeScannerFloatingActionButton,
      
            /// Ask AI Floating Action Button
            askAiFloatingActionButton,
      
            /// Search Floating Action Button
            searchFloatingActionButton,
      
          ] : [],
        ),
      ),
    );

  }

  Widget get notificationFloatingActionButton {
    return const NotificationsModalBottomSheet();
  }

  Widget get qrCodeScannerFloatingActionButton {
    return const QRCodeScannerModalBottomSheet();
  }

  Widget get askAiFloatingActionButton {
    return AiChatModalBottomSheet(
      trigger: (openBottomModalSheet) => FloatingActionButton(
        mini: true,
        heroTag: 'ai-button',
        onPressed: () {
          openBottomModalSheet();
        },
        child: const Icon(Icons.bubble_chart_outlined)
      )
    );
  }

  Widget get searchFloatingActionButton {
    return const SearchModalBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    /**
     *  The GestureDetector is used to hide the soft input keyboard 
     *  after clicking outside TextField or anywhere on screen
     */
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child:  Scaffold(
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: body,
      )
    );
  }

}