import 'package:perfect_order/features/friend_groups/providers/friend_group_provider.dart';
import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import 'package:perfect_order/features/friend_groups/models/friend_group.dart';
import '../../models/friend_group_member_filters.dart' as model;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class FriendGroupMemberFilters extends StatefulWidget {
  
  final FriendGroup friendGroup;
  final String friendGroupMemberFilter;
  final Function(String) onSelectedFriendGroupMemberFilter;

  const FriendGroupMemberFilters({
    super.key,
    required this.friendGroup,
    required this.friendGroupMemberFilter,
    required this.onSelectedFriendGroupMemberFilter,
  });

  @override
  State<FriendGroupMemberFilters> createState() => FriendGroupMemberFiltersState();
}

class FriendGroupMemberFiltersState extends State<FriendGroupMemberFilters> {
  
  String? friendGroupMemberFilter;
  model.FriendGroupMemberFilters? friendGroupMemberFilters;

  FriendGroup get friendGroup => widget.friendGroup;
  bool get hasFriendGroupMemberFilters => friendGroupMemberFilters != null;
  Function(String) get onSelectedFriendGroupMemberFilter => widget.onSelectedFriendGroupMemberFilter;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state friendGroupMemberFilter value to the widget friendGroupMemberFilter value
    friendGroupMemberFilter = widget.friendGroupMemberFilter;

    requestFriendGroupMemberFilters();
  }

  void requestFriendGroupMemberFilters() {
    
    friendGroupProvider.setFriendGroup(friendGroup).friendGroupRepository.showFriendGroupMemberFilters().then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(response.data);
        
        setState(() {
          
          /// Set the review filters
          friendGroupMemberFilters = model.FriendGroupMemberFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current friend group member filter
  void changeFriendGroupMemberFilter(String friendGroupMemberFilter) {
    selectFriendGroupMemberFilter(friendGroupMemberFilter);
    requestFriendGroupMemberFilters();
  }

  /// Select the specified friend group member filter
  void selectFriendGroupMemberFilter(String friendGroupMemberFilter) {
    setState(() => this.friendGroupMemberFilter = friendGroupMemberFilter);

    /// Notify parent widget on change
    onSelectedFriendGroupMemberFilter(friendGroupMemberFilter);
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
          key: ValueKey(hasFriendGroupMemberFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  
                  /// List friend group member filters as selectable choice chips 
                  if(hasFriendGroupMemberFilters) ...friendGroupMemberFilters!.filters.map((filter) {
                    
                    final String name = filter.name;
                    final bool isSelected = name == friendGroupMemberFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeFriendGroupMemberFilter(filter.name);
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