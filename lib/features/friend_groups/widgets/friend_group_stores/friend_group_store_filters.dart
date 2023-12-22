import 'package:bonako_demo/features/friend_groups/providers/friend_group_provider.dart';
import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import '../../models/friend_group_store_filters.dart' as model;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class FriendGroupStoreFilters extends StatefulWidget {
  
  final FriendGroup friendGroup;
  final String friendGroupStoreFilter;
  final Function(String) onSelectedFriendGroupStoreFilter;

  const FriendGroupStoreFilters({
    super.key,
    required this.friendGroup,
    required this.friendGroupStoreFilter,
    required this.onSelectedFriendGroupStoreFilter,
  });

  @override
  State<FriendGroupStoreFilters> createState() => FriendGroupStoreFiltersState();
}

class FriendGroupStoreFiltersState extends State<FriendGroupStoreFilters> {
  
  String? friendGroupStoreFilter;
  model.FriendGroupStoreFilters? friendGroupStoreFilters;

  FriendGroup get friendGroup => widget.friendGroup;
  bool get hasFriendGroupStoreFilters => friendGroupStoreFilters != null;
  Function(String) get onSelectedFriendGroupStoreFilter => widget.onSelectedFriendGroupStoreFilter;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state friendGroupStoreFilter value to the widget friendGroupStoreFilter value
    friendGroupStoreFilter = widget.friendGroupStoreFilter;

    requestFriendGroupStoreFilters();
  }

  void requestFriendGroupStoreFilters() {
    
    friendGroupProvider.setFriendGroup(friendGroup).friendGroupRepository.showFriendGroupStoreFilters().then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(response.data);
        
        setState(() {
          
          /// Set the review filters
          friendGroupStoreFilters = model.FriendGroupStoreFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current friend group store filter
  void changeFriendGroupStoreFilter(String friendGroupStoreFilter) {
    selectFriendGroupStoreFilter(friendGroupStoreFilter);
    requestFriendGroupStoreFilters();
  }

  /// Select the specified friend group store filter
  void selectFriendGroupStoreFilter(String friendGroupStoreFilter) {
    setState(() => this.friendGroupStoreFilter = friendGroupStoreFilter);

    /// Notify parent widget on change
    onSelectedFriendGroupStoreFilter(friendGroupStoreFilter);
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
          key: ValueKey(hasFriendGroupStoreFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  
                  /// List friend group store filters as selectable choice chips 
                  if(hasFriendGroupStoreFilters) ...friendGroupStoreFilters!.filters.map((filter) {
                    
                    final String name = filter.name;
                    final bool isSelected = name == friendGroupStoreFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeFriendGroupStoreFilter(filter.name);
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