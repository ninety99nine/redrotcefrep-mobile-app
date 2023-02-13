import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../models/follower_filters.dart' as model;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class FollowerFilters extends StatefulWidget {
  
  final ShoppableStore store;
  final String followerFilter;
  final Function(String) onSelectedFollowerFilter;

  const FollowerFilters({
    super.key,
    required this.store,
    required this.followerFilter,
    required this.onSelectedFollowerFilter
  });

  @override
  State<FollowerFilters> createState() => FollowerFiltersState();
}

class FollowerFiltersState extends State<FollowerFilters> {
  
  String? followerFilter;
  model.FollowerFilters? followerFilters;

  ShoppableStore get store => widget.store;
  bool get hasFollowerFilters => followerFilters != null;
  Function(String) get onSelectedFollowerFilter => widget.onSelectedFollowerFilter;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state followerFilter value to the widget followerFilter value
    followerFilter = widget.followerFilter;
    
    requestStoreFollowerFilters();
  }

  /// Request the store follower filters
  /// This will allow us to show filters that can be used
  /// to filter the results of followers returned on each request
  void requestStoreFollowerFilters() {
    
    storeProvider.setStore(store).storeRepository.showFollowerFilters(
      context: context
    ).then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the follower filters
          followerFilters = model.FollowerFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeFollowerFilter(String followerFilter) {
    selectFollowerFilter(followerFilter);
    requestStoreFollowerFilters();
  }

  /// Select the specified review filter
  void selectFollowerFilter(String followerFilter) {
    setState(() => this.followerFilter = followerFilter);

    /// Notify parent widget on change
    onSelectedFollowerFilter(followerFilter);
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
          key: ValueKey(hasFollowerFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                         
                  /// List review filters as selectable choice chips       
                  if(hasFollowerFilters) ...followerFilters!.filters.where((filter) {
                    
                    /// Return any other filters except the "All" filter
                    return filter.name.toLowerCase() != 'all';
              
                  }).map((filter) {
                  
                    final String name = filter.name;
                    final bool isSelected = name == followerFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeFollowerFilter(filter.name);
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