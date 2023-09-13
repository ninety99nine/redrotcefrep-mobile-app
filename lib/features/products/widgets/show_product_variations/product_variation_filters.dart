import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../models/product_variation_filters.dart' as model;
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class ProductVariationFilters extends StatefulWidget {
  
  final ShoppableStore store;
  final String productVariationFilter;
  final Function(String) onSelectedProductVariationFilter;

  const ProductVariationFilters({
    super.key,
    required this.store,
    required this.productVariationFilter,
    required this.onSelectedProductVariationFilter
  });

  @override
  State<ProductVariationFilters> createState() => ProductVariationFiltersState();
}

class ProductVariationFiltersState extends State<ProductVariationFilters> {
  
  String? productVariationFilter;
  model.ProductVariationFilters? productFilters;

  ShoppableStore get store => widget.store;
  bool get hasProductFilters => productFilters != null;
  Function(String) get onSelectedProductVariationFilter => widget.onSelectedProductVariationFilter;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state productVariationFilter value to the widget productVariationFilter value
    productVariationFilter = widget.productVariationFilter;
    
    requestStoreProductFilters();
  }

  /// Request the store product filters
  /// This will allow us to show filters that can be used
  /// to filter the results of products returned on each request
  void requestStoreProductFilters() {
    
    storeProvider.setStore(store).storeRepository.showProductFilters()
    .then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(response.data);
        
        setState(() {
          
          /// Set the product filters
          productFilters = model.ProductVariationFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeProductFilter(String productVariationFilter) {
    selectProductFilter(productVariationFilter);
    requestStoreProductFilters();
  }

  /// Select the specified review filter
  void selectProductFilter(String productVariationFilter) {
    setState(() => this.productVariationFilter = productVariationFilter);

    /// Notify parent widget on change
    onSelectedProductVariationFilter(productVariationFilter);
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
                    final bool isSelected = name == productVariationFilter;
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