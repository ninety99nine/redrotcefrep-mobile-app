import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../models/product_filters.dart' as model;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ProductFilters extends StatefulWidget {
  
  final ShoppableStore store;
  final String productFilter;
  final Function(String) onSelectedProductFilter;

  const ProductFilters({
    super.key,
    required this.store,
    required this.productFilter,
    required this.onSelectedProductFilter
  });

  @override
  State<ProductFilters> createState() => ProductFiltersState();
}

class ProductFiltersState extends State<ProductFilters> {
  
  String? productFilter;
  model.ProductFilters? productFilters;

  ShoppableStore get store => widget.store;
  bool get hasProductFilters => productFilters != null;
  Function(String) get onSelectedProductFilter => widget.onSelectedProductFilter;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state productFilter value to the widget productFilter value
    productFilter = widget.productFilter;
    
    requestStoreProductFilters();
  }

  /// Request the store product filters
  /// This will allow us to show filters that can be used
  /// to filter the results of products returned on each request
  void requestStoreProductFilters() {
    
    storeProvider.setStore(store).storeRepository.showProductFilters()
    .then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the product filters
          productFilters = model.ProductFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeProductFilter(String productFilter) {
    selectProductFilter(productFilter);
    requestStoreProductFilters();
  }

  /// Select the specified review filter
  void selectProductFilter(String productFilter) {
    setState(() => this.productFilter = productFilter);

    /// Notify parent widget on change
    onSelectedProductFilter(productFilter);
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
          key: ValueKey(hasProductFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: productFilters == null ? [] : [
                         
                  /// List product filters as selectable choice chips       
                  ...productFilters!.filters.map((filter) {
                  
                    final String name = filter.name;
                    final bool isSelected = name == productFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeProductFilter(filter.name);
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