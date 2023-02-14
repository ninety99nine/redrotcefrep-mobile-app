import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../models/team_member_filters.dart' as model;
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class TeamMemberFilters extends StatefulWidget {
  
  final ShoppableStore store;
  final String teamMemberFilter;
  final Function(String) onSelectedTeamMemberFilter;

  const TeamMemberFilters({
    super.key,
    required this.store,
    required this.teamMemberFilter,
    required this.onSelectedTeamMemberFilter
  });

  @override
  State<TeamMemberFilters> createState() => TeamMemberFiltersState();
}

class TeamMemberFiltersState extends State<TeamMemberFilters> {
  
  String? teamMemberFilter;
  model.TeamMemberFilters? teamMemberFilters;

  ShoppableStore get store => widget.store;
  bool get hasTeamMemberFilters => teamMemberFilters != null;
  Function(String) get onSelectedTeamMemberFilter => widget.onSelectedTeamMemberFilter;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    
    /// Set the local state teamMemberFilter value to the widget teamMemberFilter value
    teamMemberFilter = widget.teamMemberFilter;
    
    requestStoreTeamMemberFilters();
  }

  /// Request the store team member filters
  /// This will allow us to show filters that can be used
  /// to filter the results of team members returned on each request
  void requestStoreTeamMemberFilters() {
    
    storeProvider.setStore(store).storeRepository.showTeamMemberFilters()
    .then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the team member filters
          teamMemberFilters = model.TeamMemberFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeTeamMemberFilter(String teamMemberFilter) {
    selectTeamMemberFilter(teamMemberFilter);
    requestStoreTeamMemberFilters();
  }

  /// Select the specified review filter
  void selectTeamMemberFilter(String teamMemberFilter) {
    setState(() => this.teamMemberFilter = teamMemberFilter);

    /// Notify parent widget on change
    onSelectedTeamMemberFilter(teamMemberFilter);
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
          key: ValueKey(hasTeamMemberFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                         
                  /// List review filters as selectable choice chips
                  if(hasTeamMemberFilters) ...teamMemberFilters!.filters.map((filter) {
                  
                    final String name = filter.name;
                    final bool isSelected = name == teamMemberFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeTeamMemberFilter(filter.name);
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