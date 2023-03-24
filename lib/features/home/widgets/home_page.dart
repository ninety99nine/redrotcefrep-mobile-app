import 'package:bonako_demo/features/home/services/home_service.dart';
import 'package:bonako_demo/features/qr_code_scanner/widgets/qr_code_scanner_modal_bottom_sheet/qr_code_scanner_modal_popup.dart';

import '../../../features/search/widgets/search_show/search_modal_bottom_sheet/search_modal_popup.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../../core/shared_widgets/chips/custom_choice_chip.dart';
import '../../../features/home/providers/home_provider.dart';
import 'tab_content/communities_page_content.dart';
import '../../../../core/shared_models/user.dart';
import 'tab_content/following_page_content.dart';
import 'tab_content/my_stores_page_content.dart';
import 'tab_content/profile_page_content.dart';
import 'tab_content/groups_page_content.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'navigation_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  int totalTabs = 5;
  User get user => authProvider.user!;
  String get firstName => user.firstName;
  late final TabController _tabController;
  bool isGettingSelectedHomeTabIndexFromDeviceStorage = true;

  int get selectedHomeTabIndex => homeProvider.selectedHomeTabIndex;
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  @override
  void initState() {
    
    super.initState();
    
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
        setState(() => homeProvider.setSelectedTabIndex(_tabController.index));
      }

    });

    Future.delayed(Duration.zero).then((value) async {
      await HomeService.getSelectedHomeTabIndexFromDeviceStorage().then((selectedHomeTabIndex) {

        isGettingSelectedHomeTabIndexFromDeviceStorage = false;
        changeNavigationTab(selectedHomeTabIndex);

      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void changeNavigationTab(int index) {
    setState(() {
      homeProvider.setSelectedTabIndex(index);
      _tabController.index = index;
    });
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
                  getNavigationTab('Groups', 2),        
                  getNavigationTab('My stores', 3),    
                  getNavigationTab('Communities', 4),    
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

          /// Groups page
          GroupsPageContent(),

          /// My Stores
          MyStoresPageContent(),

          /// Communities page
          CommunitiesPageContent(),

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

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        
        /// QR Code Scanner Modal Bottom Sheet
        qrCodeScannerModalBottomSheet,

        /// Search Modal Bottom Sheet
        searchModalBottomSheet,

      ],
    );

  }

  Widget get qrCodeScannerModalBottomSheet {
    return const QRCodeScannerModalBottomSheet();
  }

  Widget get searchModalBottomSheet {
    return const SearchModalBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButtons,
      drawer: const NavigationDrawer(),
      appBar: appBar,
      body: body,
    );
  }
}