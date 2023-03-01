import 'package:bonako_demo/features/search/widgets/search_show/search_modal_bottom_sheet/search_modal_popup.dart';

import '../../../features/authentication/providers/auth_provider.dart';
import '../../../core/shared_widgets/chips/custom_choice_chip.dart';
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

  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  late final TabController _tabController;
  String get firstName => user.firstName;
  User get user => authProvider.user!;
  int _selectedIndex = 3;

  @override
  void initState() {
    
    super.initState();
    
    _tabController = TabController(initialIndex: _selectedIndex, length: 5, vsync: this);
    
    /**
     *  This _tabController is used to check if we have navigated to the next or previous tab
     *  by swipping between the navigation content instead of tapping on the navigation tabs
     */
    _tabController.addListener(() {
      
      /**
       *  Set the selected index to match the current tab controller 
       *  index so that the selected tab can match the tab content
       */
      if(_selectedIndex != _tabController.index) {
        setState(() => _selectedIndex = _tabController.index);
      }

    });

  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  PreferredSizeWidget get appBar {
    return AppBar(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      title:
        ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              children: [
                getNavigationTab(firstName, 0),
                getNavigationTab('Following', 1),    
                getNavigationTab('Groups', 2),        
                getNavigationTab('My stores', 3),    
                getNavigationTab('Communities', 4),    
              ],
            ),
          ),
        )
    );
  }

  Widget get searchModalBottomSheet {
    return const SearchModalBottomSheet();
  }

  Widget getNavigationTab(String label, int index) {
    return CustomChoiceChip(
      label: label,
      selected: _selectedIndex == index,
      onSelected: (_) => changeNavigationTab(index),
    );
  }

  void changeNavigationTab(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }

  Widget get body {
    return SafeArea(
      child: TabBarView(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: searchModalBottomSheet,
      drawer: const NavigationDrawer(),
      appBar: appBar,
      body: body,
    );
  }
}