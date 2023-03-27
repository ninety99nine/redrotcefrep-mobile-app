import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/user/providers/user_provider.dart';

import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/services/store_services.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../models/order_filters.dart' as model;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderFilters extends StatefulWidget {
  
  final String orderFilter;
  final ShoppableStore? store;
  final Function(String) onSelectedOrderFilter;

  const OrderFilters({
    super.key,
    this.store,
    required this.orderFilter,
    required this.onSelectedOrderFilter
  });

  @override
  State<OrderFilters> createState() => OrderFiltersState();
}

class OrderFiltersState extends State<OrderFilters> {
  
  String? orderFilter;
  model.OrderFilters? orderFilters;

  ShoppableStore? get store => widget.store;
  bool get hasOrderFilters => orderFilters != null;
  Function(String) get onSelectedOrderFilter => widget.onSelectedOrderFilter;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get canManageOrders => store == null ? false : StoreServices.hasPermissionsToManageOrders(store!);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state orderFilter value to the widget orderFilter value
    orderFilter = widget.orderFilter;
    
    requestStoreOrderFilters();
  }

  /// Request the store order filters
  /// This will allow us to show filters that can be used
  /// to filter the results of orders returned on each request
  void requestStoreOrderFilters() {

    Future<http.Response> request;

    /// If the store is not provided
    if( store == null ) {

      /// Request the user order filters
      request = userProvider.setUser(authProvider.user!).userRepository.showOrderFilters();

    /// If the store is provided
    }else{

      /// Request the store order filters
      request = storeProvider.setStore(store!).storeRepository.showOrderFilters();
      
    }
    
    request.then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the order filters
          orderFilters = model.OrderFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeOrderFilter(String orderFilter) {
    selectOrderFilter(orderFilter);
    requestStoreOrderFilters();
  }

  /// Select the specified review filter
  void selectOrderFilter(String orderFilter) {
    setState(() => this.orderFilter = orderFilter);

    /// Notify parent widget on change
    onSelectedOrderFilter(orderFilter);
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
          key: ValueKey(hasOrderFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                         
                  /// List review filters as selectable choice chips       
                  if(hasOrderFilters) ...orderFilters!.filters.where((filter) {
                    
                    /// If we cannot manage orders
                    if(canManageOrders == false) {
              
                      /// Return only the "All" and "Me" filter
                      return ['All', 'Me', 'Friends'].contains(filter.name);
              
                    }

                    /// Return every filter except
                    return true;
              
                  }).map((filter) {
                  
                    final String name = filter.name;
                    final bool isSelected = name == orderFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeOrderFilter(filter.name);
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