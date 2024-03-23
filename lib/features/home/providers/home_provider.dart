import '../services/home_service.dart';
import 'package:flutter/material.dart';

/// The HomeProvider is strictly responsible for maintaining the state 
/// of the home. This state can then be shared with the rest of the 
/// application.
class HomeProvider with ChangeNotifier {

  /////////////////////////
  /// HOME TAB SETTINGS ///
  /////////////////////////
  
  final int profileTabIndex = 0;
  final int orderTabIndex = 1;
  final int myStoresTabIndex = 2;
  final int groupsTabIndex = 3;
  
  /// The selected tab index of the home tabs e.g
  /// Index 0 = Profile, Index 1 = Order, Index 2 = My Stores, e.t.c
  int _selectedHomeTabIndex = 0;

  /// Get the selected tab index
  int get selectedHomeTabIndex => _selectedHomeTabIndex;

  /// Set the selected tab index
  void setSelectedHomeTabIndex(int selectedHomeTabIndex) {
    _selectedHomeTabIndex = selectedHomeTabIndex;
    HomeService.saveSelectedHomeTabIndexOnDeviceStorage(selectedHomeTabIndex);
  }

  /// Check if we have selected the profile tab
  bool get hasSelectedProfile => _selectedHomeTabIndex == profileTabIndex;

  /// Check if we have selected the order tab
  bool get hasSelectedOrder => _selectedHomeTabIndex == orderTabIndex;

  /// Check if we have selected the my stores tab
  bool get hasSelectedMyStores => _selectedHomeTabIndex == myStoresTabIndex;

  /// Check if we have selected the groups tab
  bool get hasSelectedGroups => _selectedHomeTabIndex == groupsTabIndex;
  
}