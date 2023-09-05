import 'package:bonako_demo/features/coupons/models/coupon.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../create_or_update_coupon_form/create_or_update_coupon_form.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'coupons_in_vertical_list_view_infinite_scroll.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'coupons_page/coupons_page.dart';
import '../../enums/coupon_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'coupon_filters.dart';

class CouponsContent extends StatefulWidget {
  
  final Coupon? coupon;
  final ShoppableStore store;
  final bool showingFullPage;
  final CouponContentView? couponContentView;

  const CouponsContent({
    super.key,
    this.coupon,
    required this.store,
    this.couponContentView,
    this.showingFullPage = false,
  });

  @override
  State<CouponsContent> createState() => _CouponsContentState();
}

class _CouponsContentState extends State<CouponsContent> {

  Coupon? coupon;
  bool isDeleting = false;
  bool isSubmitting = false;
  String couponFilter = 'All';
  bool disableFloatingActionButton = false;
  CouponContentView couponContentView = CouponContentView.viewingCoupons;

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CouponFiltersState> couponFiltersState = GlobalKey<CouponFiltersState>();

  /// This allows us to access the state of CreateOrUpdateCouponForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CreateOrUpdateCouponFormState> _createCouponFormState = GlobalKey<CreateOrUpdateCouponFormState>();

  ShoppableStore get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isViewingCoupons => couponContentView == CouponContentView.viewingCoupons;
  bool get isCreatingCoupon => couponContentView == CouponContentView.creatingCoupon;
  bool get isEditingCoupon => couponContentView == CouponContentView.editingCoupon;
  String get subtitle {

    if(isViewingCoupons) {

      final bool showingAllCoupons = couponFilter.toLowerCase() == 'all';
      final bool showingHiddenCoupons = couponFilter.toLowerCase() == 'hidden';
      final bool showingVisibleCoupons = couponFilter.toLowerCase() == 'visible';
      
      if(showingAllCoupons) {
        return 'Showing all coupons';
      }else if(showingHiddenCoupons) {
        return 'Showing hidden coupons';
      }else if(showingVisibleCoupons) {
        return 'Showing visible coupons';
      }

    }else if(isCreatingCoupon) {
      return 'Create a new coupon';
    }else{
      return 'Edit coupon';
    }

    return '';

  }

  @override
  void initState() {
    super.initState();
    coupon = widget.coupon;
    if(coupon != null) couponContentView = CouponContentView.editingCoupon;
    if(widget.couponContentView != null) couponContentView = widget.couponContentView!;
  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the coupons content
    if(isViewingCoupons) {

      /// Show coupons view
      return CouponsInVerticalListViewInfiniteScroll(
        store: store,
        couponFilter: couponFilter,
        onEditCoupon: onEditCoupon,
        couponFiltersState: couponFiltersState
      );

    /// If we want to view the create coupon content
    }else {
      
      return CreateOrUpdateCouponForm(
        store: store,
        coupon: coupon,
        onDeleting: onDeleting,
        onSubmitting: onSubmitting,
        key: _createCouponFormState,
        onDeletedCoupon: onDeletedCoupon,
        onCreatedCoupon: onCreatedCoupon,
        onUpdatedCoupon: onUpdatedCoupon,
      );

    }
    
  }

  void onSubmitting(status) {
    setState(() {
      isSubmitting = status;
      disableFloatingActionButton = status;
    });
  }

  void onDeleting(status) {
    setState(() {
      isDeleting = status;
      disableFloatingActionButton = status;
    });
  }

  void onCreatedCoupon(Coupon coupon){
    changeCouponContentView(CouponContentView.viewingCoupons);
  }

  void onUpdatedCoupon(Coupon coupon){
    this.coupon = null;
    changeCouponContentView(CouponContentView.viewingCoupons);
  }

  void onDeletedCoupon(Coupon coupon){
    this.coupon = null;
    changeCouponContentView(CouponContentView.viewingCoupons);
  }

  void onGoBack(){
    coupon = null;
    changeCouponContentView(CouponContentView.viewingCoupons);
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    String title;

    if(isCreatingCoupon) {
      title = 'Create';
    }else if(isViewingCoupons) {
      title = 'Add Coupon';
    }else {
      title = 'Save Changes';
    }

    return Row(
      children: [

        if( couponContentView != CouponContentView.viewingCoupons ) ...[

          /// Back button
          SizedBox(
            width: 48,
            child: CustomElevatedButton(
              '',
              color: Colors.grey,
              onPressed: () => onGoBack(),
              prefixIcon: Icons.keyboard_double_arrow_left,
            ),
          ),

          const SizedBox(width: 8)

        ],

        /// Add Coupon, Create or Save Changes button
        CustomElevatedButton(
          title,
          width: 120,
          isLoading: isSubmitting,
          color: isDeleting ? Colors.grey : null,
          onPressed: floatingActionButtonOnPressed,
          prefixIcon: isViewingCoupons ? Icons.add : null,
        ),

      ],
    );

  }

  /// Action to be called when the floating action button is pressed
  void floatingActionButtonOnPressed() {

    /// If we have disabled the floating action button, then do nothing
    if(disableFloatingActionButton) return;

    /// If we are viewing the coupons content
    if(isViewingCoupons) {

      /// Change to the invite coupon view
      changeCouponContentView(CouponContentView.creatingCoupon);

    /// If we are viewing the create or edit coupon content
    }else{

      /// If we are creating a new coupon
      if(isCreatingCoupon) {

        if(_createCouponFormState.currentState != null) {
          _createCouponFormState.currentState!.requestCreateCoupon();
        }
      
      /// If we are updating a coupon
      }else{

        if(_createCouponFormState.currentState != null) {
          _createCouponFormState.currentState!.requestUpdateCoupon();
        }
      
      }

    }

  }

  /// Called when the user wants to edit a coupon
  void onEditCoupon(Coupon coupon) {
    this.coupon = coupon;
    changeCouponContentView(CouponContentView.editingCoupon);
  }

  /// Called when the order filter has been changed,
  /// such as changing from "Joined" to "Left"
  void onSelectedCouponFilter(String couponFilter) {
    setState(() => this.couponFilter = couponFilter);
  }

  /// Called to change the view to the specified view
  void changeCouponContentView(CouponContentView couponContentView) {
    setState(() => this.couponContentView = couponContentView);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(couponContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      /// Title
                      const CustomTitleMediumText('Coupons', padding: EdgeInsets.only(bottom: 8),),
                      
                      /// Subtitle
                      AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: Align(
                          key: ValueKey(subtitle),
                          alignment: Alignment.centerLeft,
                          child: CustomBodyText(subtitle),
                        )
                      ),
                  
                      //  Filter
                      if(isViewingCoupons) CouponFilters(
                        store: store,
                        key: couponFiltersState,
                        couponFilter: couponFilter,
                        onSelectedCouponFilter: onSelectedCouponFilter,
                      ),
                      
                    ],
                  ),
                ),
          
                /// Content
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    color: Colors.white,
                    child: content,
                  ),
                )
            
              ],
            ),
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();

                /// Set the store
                storeProvider.setStore(store);
                
                /// Navigate to the page
                Get.toNamed(CouponsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back(),
            ),
          ),
  
          /// Floating Button (show if provided)
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingCoupons ? 112 : 56) + topPadding,
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}