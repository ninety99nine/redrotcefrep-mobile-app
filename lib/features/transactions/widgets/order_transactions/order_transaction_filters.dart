import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import '../../models/transaction_filters.dart' as model;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class OrderTransactionFilters extends StatefulWidget {
  
  final Order order;
  final String transactionFilter;
  final Function(String) onSelectedTransactionFilter;

  const OrderTransactionFilters({
    super.key,
    required this.order,
    required this.transactionFilter,
    required this.onSelectedTransactionFilter
  });

  @override
  State<OrderTransactionFilters> createState() => OrderTransactionFiltersState();
}

class OrderTransactionFiltersState extends State<OrderTransactionFilters> {
  
  String? transactionFilter;
  model.TransactionFilters? transactionFilters;

  Order get order => widget.order;
  bool get hasOrderTransactionFilters => transactionFilters != null;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  Function(String) get onSelectedTransactionFilter => widget.onSelectedTransactionFilter;
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state transactionFilter value to the widget transactionFilter value
    transactionFilter = widget.transactionFilter;
    
    requestStoreOrderTransactionFilters();
  }

  /// Request the store transaction filters
  /// This will allow us to show filters that can be used
  /// to filter the results of transactions returned on each request
  void requestStoreOrderTransactionFilters() {
    
    orderProvider.setOrder(order).orderRepository.showTransactionFilters()
    .then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(response.data);
        
        setState(() {
          
          /// Set the transaction filters
          transactionFilters = model.TransactionFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeTransactionFilter(String transactionFilter) {
    selectTransactionFilter(transactionFilter);
    requestStoreOrderTransactionFilters();
  }

  /// Select the specified review filter
  void selectTransactionFilter(String transactionFilter) {
    setState(() => this.transactionFilter = transactionFilter);

    /// Notify parent widget on change
    onSelectedTransactionFilter(transactionFilter);
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
          key: ValueKey(hasOrderTransactionFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: transactionFilters == null ? [] : [
                         
                  /// List transaction filters as selectable choice chips       
                  ...transactionFilters!.filters.map((filter) {
                  
                    final String name = filter.name;
                    final bool isSelected = name == transactionFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeTransactionFilter(filter.name);
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