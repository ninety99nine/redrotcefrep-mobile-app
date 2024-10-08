import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import 'package:perfect_order/features/reviews/enums/review_enums.dart';
import '../../../../../core/shared_widgets/chips/custom_filter_choice_chip.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../models/review_filters.dart' as model;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class ReviewFilters extends StatefulWidget {
  
  final String reviewFilter;
  final ShoppableStore? store;
  final Function(String) onSelectedReviewFilter;
  final UserReviewAssociation? userReviewAssociation;

  const ReviewFilters({
    super.key,
    this.store,
    required this.reviewFilter,
    this.userReviewAssociation,
    required this.onSelectedReviewFilter
  });

  @override
  State<ReviewFilters> createState() => ReviewFiltersState();
}

class ReviewFiltersState extends State<ReviewFilters> {
  
  String? reviewFilter;
  model.ReviewFilters? reviewFilters;

  ShoppableStore? get store => widget.store;
  bool get hasReviewFilters => reviewFilters != null;
  Function(String) get onSelectedReviewFilter => widget.onSelectedReviewFilter;
  UserReviewAssociation? get userReviewAssociation => widget.userReviewAssociation;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    /// Set the local state reviewFilter value to the widget reviewFilter value
    reviewFilter = widget.reviewFilter;

    requestReviewFilters();
  }

  void requestReviewFilters() {

    Future<dio.Response> request;

    /// If the store is not provided
    if( store == null ) {

      /// Request the user review filters
      request = authProvider.userRepository.showReviewFilters(userReviewAssociation: userReviewAssociation!);

    /// If the store is provided
    }else{

      /// Request the store review filters
      request = storeProvider.setStore(store!).storeRepository.showReviewFilters();
      
    }
    
    request.then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = List<Map<String, dynamic>>.from(response.data);
        
        setState(() {
          
          /// Set the review filters
          reviewFilters = model.ReviewFilters.fromJson(responseBody);

        });

      }

    });

  }

  /// Change the current review filter
  void changeReviewFilter(String reviewFilter) {
    selectReviewFilter(reviewFilter);
    requestReviewFilters();
  }

  /// Select the specified review filter
  void selectReviewFilter(String reviewFilter) {
    setState(() => this.reviewFilter = reviewFilter);

    /// Notify parent widget on change
    onSelectedReviewFilter(reviewFilter);
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
          key: ValueKey(hasReviewFilters),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  
                  /// List review filters as selectable choice chips 
                  if(hasReviewFilters) ...reviewFilters!.filters.map((filter) {
                    
                    final String name = filter.name;
                    final bool isSelected = name == reviewFilter;
                    final bool showTotal = name != 'All' && !isSelected;
                    final String totalSummarized = filter.totalSummarized;

                    return CustomFilterChoiceChip(
                      name: name,
                      showTotal: showTotal,
                      isSelected: isSelected,
                      totalSummarized: totalSummarized,
                      onSelected: (value) {
                        changeReviewFilter(filter.name);
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