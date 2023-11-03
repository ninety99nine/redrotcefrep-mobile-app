
import 'package:bonako_demo/core/shared_widgets/animated_widgets/custom_rotating_widget.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/features/authentication/repositories/auth_repository.dart';
import 'package:bonako_demo/features/introduction/widgets/landing_page.dart';
import 'package:bonako_demo/features/notifications/widgets/show_notifications/notifications_modal_bottom_sheet/notifications_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/qr_code_scanner/widgets/qr_code_scanner_modal_bottom_sheet/qr_code_scanner_modal_popup.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import '../../search/widgets/search_show/search_modal_bottom_sheet/search_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/user/models/resource_totals.dart';
import 'tab_content/following_page_content/following_page_content.dart';
import 'tab_content/my_stores_page_content/my_stores_page_content.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/home/services/home_service.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import '../../../core/shared_widgets/chips/custom_choice_chip.dart';
import 'tab_content/chat_page_content/chat_page_content.dart';
import '../../../features/home/providers/home_provider.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/pusher.dart';
import '../../../../core/shared_models/user.dart';
import 'tab_content/profile_page_content.dart';
import 'tab_content/groups_page_content.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_drawer.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  int totalTabs = 5;
  late PusherProvider pusherProvider;
  User get user => authProvider.user!;
  bool isLoadingResourceTotals = false;
  String get firstName => user.firstName;
  late final TabController _tabController;
  bool isGettingSelectedHomeTabIndexFromDeviceStorage = true;

  bool get hideFloatingActionButton => selectedHomeTabIndex == 4;
  AuthRepository get authRepository => authProvider.authRepository;
  int get selectedHomeTabIndex => homeProvider.selectedHomeTabIndex;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  bool get canShowFloatingActionButtons => selectedHomeTabIndex != 4 && authProvider.resourceTotals != null;


  void _startResourceTotalsLoader() => setState(() => isLoadingResourceTotals = true);
  void _stopResourceTotalsLoader() => setState(() => isLoadingResourceTotals = false);


  final List<Map> secondaryNavigationTabs = [
    {
      'name': 'Ask AI',
      'icon': Icons.wb_incandescent_sharp,
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
    
    /// Set the Pusher Provider
    pusherProvider = Provider.of<PusherProvider>(context, listen: false);

    /// Listen for new invitation alerts
    listenForNewInvitationAlerts();

    /// Request the resource totals
    _requestShowResourceTotals();
    
    _tabController = TabController(initialIndex: selectedHomeTabIndex, length: totalTabs, vsync: this);

    /**
     *  This _tabController is used to check if we have navigated to the next or previous tab
     *  by swipping between the navigation content instead of tapping on the navigation tabs
     */
    _tabController.addListener(() {
      
      /**
       *  Set the selected index to match the current tab controller 
       *  index so that the selected tab can match the tab content
       */
      if(selectedHomeTabIndex != _tabController.index) {
        setState(() => homeProvider.setSelectedHomeTabIndex(_tabController.index));
      }

      /// Request the resource totals
      _requestShowResourceTotals();

    });

    Future.delayed(Duration.zero).then((value) async {

      HomeService.getSelectedHomeTabIndexFromDeviceStorage().then((selectedHomeTabIndex) {

        isGettingSelectedHomeTabIndexFromDeviceStorage = false;
        changeNavigationTab(selectedHomeTabIndex);

      });

    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    /// Unsubscribe from this specified event on this channel
    pusherProvider.unsubscribeToAuthNotifications(identifier: 'HomePage');
  }

  void changeNavigationTab(int index) {
    setState(() {
      homeProvider.setSelectedHomeTabIndex(index);
      _tabController.index = index;
    });
  }
  
  /// Request resource totals
  void _requestShowResourceTotals() {

    if(!isLoadingResourceTotals) {

      _startResourceTotalsLoader();

      authRepository.showResourceTotals().then((response) async {

        if(response.statusCode == 200) {

          final ResourceTotals resourceTotals = ResourceTotals.fromJson(response.data);

          authProvider.setResourceTotals(resourceTotals);

        }else{

          SnackbarUtility.showErrorMessage(message: 'Failed to get resource totals');

        }

        return response;

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to show resource totals');

      }).whenComplete(() {

        _stopResourceTotalsLoader();

      });

    }

  }

  void listenForNewInvitationAlerts() async {

    print('*************** listenForNewInvitationAlerts');

    /// Subscribe to notification alerts
    pusherProvider.subscribeToAuthNotifications(
      identifier: 'HomePage', 
      onEvent: onNotificationAlerts
    );
  
  }

  void onNotificationAlerts(event) {

    print('*************** HomePage: onNotificationAlerts');

    if (event.eventName == "Illuminate\\Notifications\\Events\\BroadcastNotificationCreated") {

      if(!authProvider.hasNotifications) {

        /// Request the resource totals to show the notifications floating action button
        _requestShowResourceTotals();

      }else{

        /// Parse event.data into a Map
        Map<String, dynamic> eventData = jsonDecode(event.data);

        //  Get the event type
        String type = eventData['type'];

        if(!authProvider.hasStores) {
        
          ///  Check if this is a notification of a created or deleted store
          if(type == "App\\Notifications\\Stores\\StoreCreated" || type == "App\\Notifications\\Stores\\StoreDeleted") {

            /// Request the resource totals to show the qr code floating action button (if necessary)
            _requestShowResourceTotals();
            
          }

        }

      }

    }

  }

  PreferredSizeWidget get appBar {
    return AppBar(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      title:
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: Wrap(
                key: ValueKey(isGettingSelectedHomeTabIndexFromDeviceStorage),
                spacing: 8,
                /// Don't show any tabs until we are done getting the
                /// selected home tab index form device storage.
                children: isGettingSelectedHomeTabIndexFromDeviceStorage ? [] : [
                  getNavigationTab(firstName, 0),
                  getNavigationTab('Following', 1),     
                  getNavigationTab('My stores', 2),  
                  getNavigationTab('Groups', 3),     
                  getNavigationTab('Chat', 4),
                  //getNavigationTab('Communities', 5),    
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget get body {
    return SafeArea(
      child: isGettingSelectedHomeTabIndexFromDeviceStorage 
      /// Create a place holder container widget until we are done
      /// getting the selected home tab index form device storage.
      ? Container()
      : TabBarView(
        controller: _tabController,
        children: const [

          /// Profile
          ProfilePageContent(),

          /// Following page
          FollowingPageContent(),

          /// My stores page
          MyStoresPageContent(),

          /// Groups page
          GroupsPageContent(),

          /// Chat page
          ChatPageContent(),

          /// Communities page
          /// CommunitiesPageContent(),

        ],
      )
    );
  }

  Widget getNavigationTab(String label, int index) {
    return CustomChoiceChip(
      label: label,
      selected: selectedHomeTabIndex == index,
      onSelected: (_) => changeNavigationTab(index),
    );
  }

  Widget get floatingActionButtons {

    return AnimatedOpacity(
      opacity: isLoadingResourceTotals ? 0 : 1,
      duration: const Duration(seconds: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: canShowFloatingActionButtons ? [
    
          /// Notifications Modal Bottom Sheet
          if(authProvider.hasNotifications) notificationModalBottomSheet,
          
          /// QR Code Scanner Modal Bottom Sheet
          if(authProvider.hasStores) qrCodeScannerModalBottomSheet,
    
          /// Orders Modal Bottom Sheet
          ordersModalBottomSheet,
    
          /// Search Modal Bottom Sheet
          searchModalBottomSheet,
    
        ] : [],
      ),
    );

  }

  Widget get notificationModalBottomSheet {
    return const NotificationsModalBottomSheet();
  }

  Widget get qrCodeScannerModalBottomSheet {
    return const QRCodeScannerModalBottomSheet();
  }

  Widget get searchModalBottomSheet {
    return const SearchModalBottomSheet();
  }

  Widget get ordersModalBottomSheet {
    return OrdersModalBottomSheet(
      trigger: (openBottomModalSheet) => FloatingActionButton(
        mini: true,
        heroTag: 'orders-button',
        onPressed: openBottomModalSheet,
        child: const Icon(Icons.shopping_bag_outlined)
      )
    );
  }

   Widget get dialogContent {

    return Column(
      children: [

        GestureDetector(
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
        ),
        
        const SizedBox(height: 8.0),

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

                final int? menuIndex = secondaryNavigationTabs[index]['index'];
                final String menuName = secondaryNavigationTabs[index]['name'];
                final IconData menuIcon = secondaryNavigationTabs[index]['icon'];
                final bool isSelected = selectedHomeTabIndex == menuIndex;

                return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: Material(
                    elevation: 5,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        if(menuName == 'Sign Out') {
                          _requestLogout();
                        }else{
                          if(menuIndex != null) changeNavigationTab(menuIndex);
                        }
                      },
                      splashColor: Colors.white10,
                      highlightColor: Colors.white10,
                      child: Column(
                        children: [
                          CircleAvatar(
                            maxRadius: 20,
                            backgroundColor: Colors.white10,
                            child: Icon(menuIcon, color: isSelected ? Colors.yellow : Colors.white),
                          ),
                          const SizedBox(height: 8),
                          CustomBodyText(menuName, fontSize: 12, color: isSelected ? Colors.yellow : Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

      ],
    );
  }

  void _requestLogout() {

    //  Show logging out loader
    DialogUtility.showLoader(message: 'Signing out');

    authRepository.logout().then((response) async {

      //  Hide logging out loader
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

      /**
       *  Navigate to the landing page on successful
       *  or unsuccessful signing out.
       */       
      Get.offAndToNamed(LandingPage.routeName);

    });

  }
  
  Widget _buildNavItem(int index, IconData iconData, String label) {

    final bool isSelected = selectedHomeTabIndex == index;

    return InkWell(
      onTap: () {
        changeNavigationTab(index);
      },
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 28.0, color: isSelected ? Colors.yellow : Colors.white),

            const SizedBox(height: 4.0,),

            if(!hideFloatingActionButton) ...[
              CustomBodyText(
                label, 
                fontSize: 12, 
                color: isSelected ? Colors.yellow : Colors.white
              ),

            ]
          ],
        ),
      ),
    );
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
        //floatingActionButton: floatingActionButtons,
        //drawer: const HomeDrawer(),
        //appBar: appBar,
        body: body,
        floatingActionButtonLocation: hideFloatingActionButton ? FloatingActionButtonLocation.endContained : FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          mini: hideFloatingActionButton,
          onPressed: () {
            showGeneralDialog(
              barrierLabel: "Label",
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.5),
              transitionDuration: const Duration(milliseconds: 500),
              context: context,
              pageBuilder: (context, anim1, anim2) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: EdgeInsets.only(bottom: hideFloatingActionButton ? 50 : 0, left: 16, right: 16),
                    child: dialogContent,
                  ),
                );
              },
              transitionBuilder: (context, anim1, anim2, child) {
                return SlideTransition(
                  position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
                  child: child,
                );
              },
            );
          },
          backgroundColor: Colors.black, 
          child: SizedBox(
            child: CustomRotatingWidget(
              maxRotations: 1,
              delayDuration: const Duration(seconds: 2),
              animationDuration: const Duration(seconds: 2),
              child: Image.asset('assets/images/logo-black.png')
            ) 
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(0, Icons.person, 'Profile'),
              _buildNavItem(1, Icons.sentiment_very_satisfied_rounded, 'Order'),
              if(!hideFloatingActionButton) const SizedBox(width: 60.0), // Create space for the FAB
              _buildNavItem(2, Icons.storefront_outlined, 'My Stores'),
              _buildNavItem(3, Icons.group_rounded, 'Groups'),
              if(hideFloatingActionButton) const SizedBox(width: 60.0), // Create space for the FAB
            ],
          ),
        ),
      )
    );
  }
}