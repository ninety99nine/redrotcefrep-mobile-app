import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../models/coupon_filters.dart' as model;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class CouponFilters extends StatefulWidget {
  
  final String couponFilter;
  final ShoppableStore store;
  final Function(String) onSelectedCouponFilter;

  const CouponFilters({
    super.key,
    required this.store,
    required this.couponFilter,
    required this.onSelectedCouponFilter
  });

  @override
  State<CouponFilters> createState() => CouponFiltersState();
}

class CouponFiltersState extends State<CouponFilters> {
  
  String? couponFilter;
  model.CouponFilters? couponFilters;

  ShoppableStore get store => widget.store;
  bool get hasCouponFilters => couponFilters != null;
  Function(String) get onSelectedCouponFilter => widget.onSelectedCouponFilter;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state couponFilter value to the widget couponFilter value
    couponFilter = widget.couponFilter;
    
    requestStoreCouponFilters();
  }

  /// Request the store coupon filters
  /// This will allow us to show filters that can be used
  /// to filter the results of coupons returned on each request
  void requestStoreCouponFilters() {
    
    storeProvider.setStore(store).storeRepository.showCouponFilters()
    .then((http.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        
        setState(() {
          
          /// Set the coupon filters
          couponFilters = model.CouponFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeCouponFilter(String couponFilter) {
    selectCouponFilter(couponFilter);
    requestStoreCouponFilters();
  }

  /// Select the specified review filter
  void selectCouponFilter(String couponFilter) {
    setState(() => this.couponFilter = couponFilter);

    /// Notify parent widget on change
    onSelectedCouponFilter(couponFilter);
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
          key: ValueKey(hasCouponFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: couponFilters == null ? [] : [
                         
                  /// List coupon filters as selectable choice chips       
                  ...couponFilters!.filters.map((filter) {
                  
                    final String name = filter.name;
                    final bool isSelected = name == couponFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeCouponFilter(filter.name);
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