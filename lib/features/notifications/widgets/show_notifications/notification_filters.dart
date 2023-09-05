import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../models/notification_filters.dart' as model;
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class NotificationFilters extends StatefulWidget {
  
  final ShoppableStore? store;
  final String notificationFilter;
  final Function(String) onSelectedNotificationFilter;

  const NotificationFilters({
    super.key,
    required this.store,
    required this.notificationFilter,
    required this.onSelectedNotificationFilter
  });

  @override
  State<NotificationFilters> createState() => NotificationFiltersState();
}

class NotificationFiltersState extends State<NotificationFilters> {
  
  String? notificationFilter;
  model.NotificationFilters? notificationFilters;

  ShoppableStore? get store => widget.store;
  bool get hasNotificationFilters => notificationFilters != null;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  Function(String) get onSelectedNotificationFilter => widget.onSelectedNotificationFilter;
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state notificationFilter value to the widget notificationFilter value
    notificationFilter = widget.notificationFilter;
    
    requestNotificationFilters();
  }

  /// Request the authenticated user notification filters
  /// This will allow us to show filters that can be used
  /// to filter the results of notifications returned on each request
  void requestNotificationFilters() {
    
    authProvider.authRepository.showNotificationFilters()
    .then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(response.data);
        
        setState(() {
          
          /// Set the notification filters
          notificationFilters = model.NotificationFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeNotificationFilter(String notificationFilter) {
    selectNotificationFilter(notificationFilter);
    requestNotificationFilters();
  }

  /// Select the specified review filter
  void selectNotificationFilter(String notificationFilter) {
    setState(() => this.notificationFilter = notificationFilter);

    /// Notify parent widget on change
    onSelectedNotificationFilter(notificationFilter);
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
          key: ValueKey(hasNotificationFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: notificationFilters == null ? [] : [
                         
                  /// List notification filters as selectable choice chips       
                  ...notificationFilters!.filters.map((filter) {
                  
                    final String name = filter.name;
                    final bool isSelected = name == notificationFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeNotificationFilter(filter.name);
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