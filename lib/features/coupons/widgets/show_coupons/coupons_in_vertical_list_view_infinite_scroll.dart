import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/tags/custom_tag.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/coupons/providers/coupon_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/coupons/models/coupon.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'coupon_filters.dart';
import 'dart:convert';

class CouponsInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final String couponFilter;
  final ShoppableStore store;
  final Function(Coupon) onEditCoupon;
  final GlobalKey<CouponFiltersState> couponFiltersState;

  const CouponsInVerticalListViewInfiniteScroll({
    super.key,
    required this.store,
    required this.onEditCoupon,
    required this.couponFilter,
    required this.couponFiltersState,
  });

  @override
  State<CouponsInVerticalListViewInfiniteScroll> createState() => _CouponsInVerticalListViewInfiniteScrollState();
}

class _CouponsInVerticalListViewInfiniteScrollState extends State<CouponsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  ShoppableStore get store => widget.store;
  String get couponFilter => widget.couponFilter;
  Function(Coupon) get onEditCoupon => widget.onEditCoupon;
  GlobalKey<CouponFiltersState> get couponFiltersState => widget.couponFiltersState;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  CouponProvider get couponProvider => Provider.of<CouponProvider>(context, listen: false);

  /// Render each request item as an CouponItem
  Widget onRenderItem(coupon, int index, List coupons, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => CouponItem(
    coupon: (coupon as Coupon), 
    onEditCoupon: onEditCoupon,
    index: index
  );
  
  /// Render each request item as an Coupon
  Coupon onParseItem(coupon) => Coupon.fromJson(coupon);
  Future<http.Response> requestStoreCoupons(int page, String searchWord) {
    return storeProvider.setStore(store).storeRepository.showCoupons(
      /// Filter by the coupon filter specified (couponFilter)
      filter: couponFilter,
      searchWord: searchWord,
      page: page
    ).then((response) {

      if(response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);

        /// If the response coupon count does not match the store coupon count
        if(couponFilter == 'All' && store.couponsCount != responseBody['total']) {

          store.couponsCount = responseBody['total'];
          store.runNotifyListeners();

        }

      }

      return response;

    });
  }

  @override
  void didUpdateWidget(covariant CouponsInVerticalListViewInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the coupon filter changed
    if(couponFilter != oldWidget.couponFilter) {

      /// Start a new request
      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }
  }

  Widget contentBeforeSearchBar(bool isLoading, int totalCoupons) {
    return const CustomMessageAlert('Update your coupons during times when people are not shopping so that you don\'t disrupt their shopping experience.', margin: EdgeInsets.only(bottom: 16),);
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      listPadding: const EdgeInsets.all(0),
      catchErrorMessage: 'Can\'t show coupons',
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: _customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestStoreCoupons(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
    );
  }
}

class CouponItem extends StatelessWidget {
  
  final int index;
  final Coupon coupon;
  final Function(Coupon) onEditCoupon;

  const CouponItem({
    super.key,
    required this.index,
    required this.coupon,
    required this.onEditCoupon,
  });

  bool get offerDiscount => coupon.offerDiscount.status;
  bool get offerFreeDelivery => coupon.offerFreeDelivery.status;
  bool get hasDescription => coupon.description != null && coupon.description!.isNotEmpty;
  String get discountLabel => 'Discount ${coupon.discountType.name.toLowerCase() == 'fixed' ? coupon.discountFixedRate.amountWithCurrency : coupon.discountPercentageRate.valueSymbol }';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      onTap: () => onEditCoupon(coupon), 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          /// Name
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                /// Name
                CustomTitleSmallText(coupon.name),

                if(hasDescription) ...[

                  /// Spacer
                  const SizedBox(height: 4),

                  /// Description
                  CustomBodyText(coupon.description),

                ],

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    /// Spacer
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        
                        /// Offer Discount
                        if(offerDiscount) CustomTag(
                          discountLabel,
                          showCancelIcon: false,
                          customTagType: CustomTagType.outline,
                        ),
                    
                        /// Spacer
                        if(offerDiscount && offerFreeDelivery) const SizedBox(width: 4),
                        
                        /// Offer Free Delivery
                        if(offerFreeDelivery) const CustomTag(
                          'Free Delivery',
                          showCancelIcon: false,
                          customTagType: CustomTagType.outline,
                        ),
                      
                      ],
                    ),
                  ],
                )
                
              ],
            )
          ),
      
          /// Spacer
          const SizedBox(width: 8),
      
          /// Edit
          const Icon(Icons.mode_edit_outline_outlined),

        ],
      )
      
    );
  }
}