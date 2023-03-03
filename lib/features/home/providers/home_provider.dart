import '../services/home_service.dart';
import 'package:flutter/material.dart';

/// The HomeProvider is strictly responsible for maintaining the state 
/// of the home. This state can then be shared with the rest of the 
/// application.
class HomeProvider with ChangeNotifier {
  
  /// The selected tab index of the home tabs e.g
  /// Index 0 = Profile, Index 1 = Following, Index 2 = Groups, e.t.c
  int _selectedHomeTabIndex = 0;

  /// Get the selected tab index
  int get selectedHomeTabIndex => _selectedHomeTabIndex;

  /// Set the selected tab index
  void setSelectedTabIndex(int selectedHomeTabIndex) {
    _selectedHomeTabIndex = selectedHomeTabIndex;
    HomeService.saveSelectedHomeTabIndexOnDeviceStorage(selectedHomeTabIndex);
  }

  /// Check if we have selected the profile tab
  bool get hasSelectedProfile => _selectedHomeTabIndex == 0;

  /// Check if we have selected the following tab
  bool get hasSelectedFollowing => _selectedHomeTabIndex == 1;

  /// Check if we have selected the groups tab
  bool get hasSelectedGroups => _selectedHomeTabIndex == 2;

  /// Check if we have selected the my stores tab
  bool get hasSelectedMyStores => _selectedHomeTabIndex == 3;

  /// Check if we have selected the communities tab
  bool get hasSelectedCommunities => _selectedHomeTabIndex == 4;

}