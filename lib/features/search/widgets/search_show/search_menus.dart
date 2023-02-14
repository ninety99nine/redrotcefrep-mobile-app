import '../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../repositories/search_repository.dart';
import '../../models/search_menus.dart' as model;
import '../../providers/search_provider.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../enums/search_enums.dart';
import 'dart:convert';

class SearchMenus extends StatefulWidget {
  
  final Menu selectedMenu;
  final Function(Menu) onSelectedMenu;

  const SearchMenus({
    super.key,
    required this.selectedMenu,
    required this.onSelectedMenu
  });

  @override
  State<SearchMenus> createState() => SearchMenusState();
}

class SearchMenusState extends State<SearchMenus> {
  
  int selectedMenuIndex = 0;
  model.SearchMenus? friendMenus;
  bool get hasSearchMenus => friendMenus != null;
  Function(Menu) get onSelectedMenu => widget.onSelectedMenu;
  SearchRepository get searchRepository => searchProvider.searchRepository;
  SearchProvider get searchProvider => Provider.of<SearchProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    setMenuIndex();
    requestShowSearchMenus();
  }

  /// Request the friend menus
  /// This will allow us to show menus e.g "Stores", "Friends", "Groups"
  void requestShowSearchMenus() {
    
    searchRepository.showSearchMenus().then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the friend menus
          friendMenus = model.SearchMenus.fromJson(responseBody);

        });

      }

    });

  }

  /// Set the selected menu index based on the selected menu
  void setMenuIndex() {

    if(widget.selectedMenu == Menu.stores) {
      selectedMenuIndex = 0;
    }else if(widget.selectedMenu == Menu.friends) {
      selectedMenuIndex = 1;
    }else if(widget.selectedMenu == Menu.friendGroups) {
      selectedMenuIndex = 2;
    }

  }

  /// Set the selected menu index based on the selected menu
  void setSelectedMenuIndex(int index) {

    /// Update the selectedMenuIndex on this widget state
    setState(() => selectedMenuIndex = index);

    /// Notify parent widget on change
    if(selectedMenuIndex == 0) {
      onSelectedMenu(Menu.stores);
    }else if(selectedMenuIndex == 1) {
      onSelectedMenu(Menu.friends);
    }else if(selectedMenuIndex == 2) {
      onSelectedMenu(Menu.friendGroups);
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
          key: ValueKey(hasSearchMenus),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                         
                  /// List friend menus as selectable choice chips       
                  if(hasSearchMenus) ...friendMenus!.menus.mapIndexed((index, option) {

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