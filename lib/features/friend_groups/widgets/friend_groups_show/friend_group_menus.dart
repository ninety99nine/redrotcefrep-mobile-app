import '../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../repositories/friend_group_repository.dart';
import '../../models/friend_group_menus.dart' as model;
import '../../providers/friend_group_provider.dart';
import '../../enums/friend_group_enums.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class FriendGroupMenus extends StatefulWidget {
  
  final Menu selectedMenu;
  final Function(Menu) onSelectedMenu;

  const FriendGroupMenus({
    super.key,
    required this.selectedMenu,
    required this.onSelectedMenu
  });

  @override
  State<FriendGroupMenus> createState() => FriendGroupMenusState();
}

class FriendGroupMenusState extends State<FriendGroupMenus> {
  
  int selectedMenuIndex = 0;
  model.FriendGroupMenus? friendGroupMenus;
  bool get hasFriendGroupMenus => friendGroupMenus != null;
  Function(Menu) get onSelectedMenu => widget.onSelectedMenu;
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    setMenuIndex();
    requestShowFriendGroupMenus();
  }

  /// Request the friend menus
  /// This will allow us to show menus e.g "Groups", "Shared Groups"
  void requestShowFriendGroupMenus() {
    
    friendGroupRepository.showFriendGroupMenus(
      context: context
    ).then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the friend group menus
          friendGroupMenus = model.FriendGroupMenus.fromJson(responseBody);

        });

      }

    });

  }

  /// Set the selected menu index based on the selected menu
  void setMenuIndex() {
    
    if(widget.selectedMenu == Menu.groups) {
      selectedMenuIndex = 0;
    }else if(widget.selectedMenu == Menu.sharedGroups) {
      selectedMenuIndex = 1;
    }

  }

  /// Set the selected menu index based on the selected menu
  void setSelectedMenuIndex(int index) {

    /// Update the selectedMenuIndex on this widget state
    setState(() => selectedMenuIndex = index);

    /// Notify parent widget on change
    if(selectedMenuIndex == 0) {
      onSelectedMenu(Menu.groups);
    }else if(selectedMenuIndex == 1) {
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
          key: ValueKey(hasFriendGroupMenus),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                         
                  /// List friend menus as selectable choice chips       
                  if(hasFriendGroupMenus) ...friendGroupMenus!.menus.mapIndexed((index, option) {

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