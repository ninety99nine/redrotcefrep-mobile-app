import '../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../repositories/search_repository.dart';
import '../../models/search_filters.dart' as model;
import '../../providers/search_provider.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../enums/search_enums.dart';
import 'dart:convert';

class SearchFilters extends StatefulWidget {
  
  final Filter selectedFilter;
  final Function(Filter) onSelectedFilter;

  const SearchFilters({
    super.key,
    required this.selectedFilter,
    required this.onSelectedFilter
  });

  @override
  State<SearchFilters> createState() => SearchFiltersState();
}

class SearchFiltersState extends State<SearchFilters> {
  
  int selectedFilterIndex = 0;
  model.SearchFilters? friendFilters;
  bool get hasSearchFilters => friendFilters != null;
  Function(Filter) get onSelectedFilter => widget.onSelectedFilter;
  SearchRepository get searchRepository => searchProvider.searchRepository;
  SearchProvider get searchProvider => Provider.of<SearchProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    setFilterIndex();
    requestShowSearchFilters();
  }

  /// Request the search filters
  /// This will allow us to show filters e.g "Stores", "Friends", "Groups"
  void requestShowSearchFilters() {
    
    searchRepository.showSearchFilters().then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the search filters
          friendFilters = model.SearchFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Set the selected filter index based on the selected filter
  void setFilterIndex() {

    if(widget.selectedFilter == Filter.stores) {
      selectedFilterIndex = 0;
    }else if(widget.selectedFilter == Filter.friends) {
      selectedFilterIndex = 1;
    }else if(widget.selectedFilter == Filter.friendGroups) {
      selectedFilterIndex = 2;
    }

  }

  /// Set the selected filter index based on the selected filter
  void setSelectedFilterIndex(int index) {

    /// Update the selectedFilterIndex on this widget state
    setState(() => selectedFilterIndex = index);

    /// Notify parent widget on change
    if(selectedFilterIndex == 0) {
      onSelectedFilter(Filter.stores);
    }else if(selectedFilterIndex == 1) {
      onSelectedFilter(Filter.friends);
    }else if(selectedFilterIndex == 2) {
      onSelectedFilter(Filter.friendGroups);
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
          key: ValueKey(hasSearchFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                         
                  /// List friend filters as selectable choice chips       
                  if(hasSearchFilters) ...friendFilters!.filters.mapIndexed((index, option) {

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