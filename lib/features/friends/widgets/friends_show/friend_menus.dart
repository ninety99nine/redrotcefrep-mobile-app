import '../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../../authentication/repositories/auth_repository.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../models/friend_menus.dart' as model;
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../enums/friend_enums.dart';
import 'dart:convert';

class FriendMenus extends StatefulWidget {
  
  final Menu selectedMenu;
  final Function(Menu) onSelectedMenu;

  const FriendMenus({
    super.key,
    required this.selectedMenu,
    required this.onSelectedMenu
  });

  @override
  State<FriendMenus> createState() => FriendMenusState();
}

class FriendMenusState extends State<FriendMenus> {
  
  int selectedMenuIndex = 0;
  model.FriendMenus? friendMenus;
  bool get hasFriendMenus => friendMenus != null;
  AuthRepository get authRepository => authProvider.authRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  Function(Menu) get onSelectedMenu => widget.onSelectedMenu;
  
  @override
  void initState() {
    super.initState();
    setMenuIndex();
    requestShowFriendMenus();
  }

  /// Request the friend menus
  /// This will allow us to show menus e.g "Friend", "Groups", "Friend Groups"
  void requestShowFriendMenus() {
    
    authRepository.showFriendMenus(
      context: context
    ).then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the friend menus
          friendMenus = model.FriendMenus.fromJson(responseBody);

        });

      }

    });

  }

  /// Set the selected menu index based on the selected menu
  void setMenuIndex() {

    if(widget.selectedMenu == Menu.friends) {
      selectedMenuIndex = 0;
    }else if(widget.selectedMenu == Menu.groups) {
      selectedMenuIndex = 1;
    }else if(widget.selectedMenu == Menu.sharedGroups) {
      selectedMenuIndex = 2;
    }

  }

  /// Set the selected menu index based on the selected menu
  void setSelectedMenuIndex(int index) {

    /// Update the selectedMenuIndex on this widget state
    setState(() => selectedMenuIndex = index);

    /// Notify parent widget on change
    if(selectedMenuIndex == 0) {
      onSelectedMenu(Menu.friends);
    }else if(selectedMenuIndex == 1) {
      onSelectedMenu(Menu.groups);
    }else if(selectedMenuIndex == 2) {
      onSelectedMenu(Menu.sharedGroups);
    }

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Align(
          key: ValueKey(hasFriendMenus),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                         
                  /// List friend menus as selectable choice chips       
                  if(hasFriendMenus) ...friendMenus!.menus.mapIndexed((index, option) {

                    final String name = option.name;
                    final bool isSelected = selectedMenuIndex == index;
                    final String totalSummarized = option.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: true,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (_) {
                        setSelectedMenuIndex(index);
                      },
                    );
            
                  }).toList(),
          
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
  }
}