import '../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../repositories/friend_group_repository.dart';
import '../../models/friend_group_filters.dart' as model;
import '../../providers/friend_group_provider.dart';
import '../../enums/friend_group_enums.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class FriendGroupFilters extends StatefulWidget {
  
  final FriendGroupFilter selectedFilter;
  final Function(FriendGroupFilter) onSelectedFilter;

  const FriendGroupFilters({
    super.key,
    required this.selectedFilter,
    required this.onSelectedFilter
  });

  @override
  State<FriendGroupFilters> createState() => FriendGroupFiltersState();
}

class FriendGroupFiltersState extends State<FriendGroupFilters> {
  
  int selectedFilterIndex = 0;
  model.FriendGroupFilters? friendGroupFilters;
  bool get hasFriendGroupFilters => friendGroupFilters != null;
  Function(FriendGroupFilter) get onSelectedFilter => widget.onSelectedFilter;
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    setFilterIndex();
    requestShowFriendGroupFilters();
  }

  /// Request the friend group filters
  /// This will allow us to show menus e.g "Groups", "Shared Groups"
  void requestShowFriendGroupFilters() {
    
    friendGroupRepository.showFriendGroupFilters().then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(response.data);
        
        setState(() {
          
          /// Set the friend group menus
          friendGroupFilters = model.FriendGroupFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Set the selected menu index based on the selected menu
  void setFilterIndex() {
    
    if(widget.selectedFilter == FriendGroupFilter.groups) {
      selectedFilterIndex = 0;
    }else if(widget.selectedFilter == FriendGroupFilter.sharedGroups) {
      selectedFilterIndex = 1;
    }

  }

  /// Set the selected menu index based on the selected menu
  void setSelectedFilterIndex(int index) {

    /// Update the selectedFilterIndex on this widget state
    setState(() => selectedFilterIndex = index);

    /// Notify parent widget on change
    if(selectedFilterIndex == 0) {
      onSelectedFilter(FriendGroupFilter.groups);
    }else if(selectedFilterIndex == 1) {
      onSelectedFilter(FriendGroupFilter.sharedGroups);
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
          key: ValueKey(hasFriendGroupFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                         
                  /// List friend group filters as selectable choice chips       
                  if(hasFriendGroupFilters) ...friendGroupFilters!.filters.mapIndexed((index, option) {

                    final String name = option.name;
                    final bool isSelected = selectedFilterIndex == index;
                    final String totalSummarized = option.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: true,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (_) {
                        setSelectedFilterIndex(index);
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