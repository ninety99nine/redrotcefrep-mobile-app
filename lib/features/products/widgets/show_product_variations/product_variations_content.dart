import 'package:bonako_demo/core/shared_widgets/progress_bar/progress_bar.dart';
import '../create_or_update_product_form/create_or_update_product_form.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'product_variations_in_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'product_variations_page/product_variations_page.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../enums/product_enums.dart';
import 'package:provider/provider.dart';
import 'product_variation_filters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductVariationsContent extends StatefulWidget {
  
  final Product product;
  final ShoppableStore store;
  final bool showingFullPage;

  const ProductVariationsContent({
    super.key,
    required this.store,
    required this.product,
    this.showingFullPage = false,
  });

  @override
  State<ProductVariationsContent> createState() => _ProductsContentState();
}

class _ProductsContentState extends State<ProductVariationsContent> {

  late Product product;
  bool isDeleting = false;
  bool isSubmitting = false;
  String productVariationFilter = 'All';
  int onSendProgressPercentage = 0;
  bool disableFloatingActionButton = false;
  ProductVariationsContentView productVariationContentView = ProductVariationsContentView.viewingProductVariations;

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<ProductVariationFiltersState> productVariationFiltersState = GlobalKey<ProductVariationFiltersState>();

  /// This allows us to access the state of CreateOrUpdateProductForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  ///final GlobalKey<CreateOrUpdateProductFormState> _createProductVariationFormState = GlobalKey<CreateOrUpdateProductFormState>();

  ShoppableStore get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get canShowProgressBar => isCreatingProductVariations && isSubmitting && onSendProgressPercentage > 0;
  bool get isViewingProductVariations => productVariationContentView == ProductVariationsContentView.viewingProductVariations;
  bool get isCreatingProductVariations => productVariationContentView == ProductVariationsContentView.creatingProductVariation;
  String get subtitle {

    if(isViewingProductVariations) {

      final bool showingAllProductVariations = productVariationFilter.toLowerCase() == 'all';
      final bool showingHiddenProductVariations = productVariationFilter.toLowerCase() == 'hidden';
      final bool showingVisibleProductVariations = productVariationFilter.toLowerCase() == 'visible';
      
      if(showingAllProductVariations) {
        return 'Showing all product variations';
      }else if(showingHiddenProductVariations) {
        return 'Showing hidden product variations';
      }else if(showingVisibleProductVariations) {
        return 'Showing visible product variations';
      }

    }else if(isCreatingProductVariations) {
      return 'Create a new product variation';
    }

    return '';

  }

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the product variations content
    if(isViewingProductVariations) {

      /// Show products view
      return ProductVariationsInVerticalListViewInfiniteScroll(
        store: store,
        product: product,
        onEditProduct: onEditProduct,
        productVariationFilter: productVariationFilter,
        productVariationFiltersState: productVariationFiltersState
      );

    /// If we want to view the create product content
    }else {
      
      /*
      return CreateProductVariationForm(
        store: store,
        product: product,
        onSubmitting: onSubmitting,
        key: _createProductVariationFormState,
        onSendProgress: onSendProgress,
        onCreatedProductVariation: onCreatedProductVariation
      );
      */
      return Text('Add A New Product Variation');

    }
    
  }

  void onSubmitting(status) {
    setState(() {
      isSubmitting = status;
      disableFloatingActionButton = status;
    });
  }

  void onSendProgress(int sent, int total) {
    setState(() {
      if (total != 0 && isSubmitting) {
        double percentage = sent / total * 100;
        onSendProgressPercentage = percentage.round();
      }
    });
  }

  void onCreatedProductVariation(Product product){
    print('onCreatedProductVariation before refreshProducts');
    StoreServices.refreshProducts(store, storeProvider);
    print('onCreatedProductVariation after refreshProducts');
    changeProductVariationContentView(ProductVariationsContentView.viewingProductVariations);
  }

  void onGoBack() {
    changeProductVariationContentView(ProductVariationsContentView.viewingProductVariations);
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return Row(
      children: [

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

        const SizedBox(width: 8),

        /// Add Variation button
        CustomElevatedButton(
          width: 120,
          'Add Variation',
          isLoading: isSubmitting,
          color: isDeleting ? Colors.grey : null,
          onPressed: floatingActionButtonOnPressed,
          prefixIcon: isViewingProductVariations ? Icons.add : null,
        ),

      ],
    );

  }

  /// Action to be called when the floating action button is pressed
  void floatingActionButtonOnPressed() {

    /// If we have disabled the floating action button, then do nothing
    if(disableFloatingActionButton) return;

    /// If we are viewing the product variations content
    if(isViewingProductVariations) {

      /// Change to the create product variation view
      changeProductVariationContentView(ProductVariationsContentView.creatingProductVariation);

    /// If we are viewing the create product variation content
    }else{

      /// If we are creating a new product variation
      /// _createProductVariationFormState.currentState!.requestCreateProduct();

    }

  }

  /// Called when the user wants to edit a product variation
  void onEditProduct(Product productVariation) {
    /// Add logic here
  }

  /// Called when the product variation filter has been changed,
  /// such as changing from "Joined" to "Left"
  void onSelectedProductVariationFilter(String productVariationFilter) {
    setState(() => this.productVariationFilter = productVariationFilter);
  }

  /// Called to change the view to the specified view
  void changeProductVariationContentView(ProductVariationsContentView productVariationContentView) {
    setState(() => this.productVariationContentView = productVariationContentView);
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
              key: ValueKey(productVariationContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32, right: 16, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      /// Title
                      CustomTitleMediumText(product.name, padding: const EdgeInsets.only(bottom: 8),),
                      
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
                      if(isViewingProductVariations) ProductVariationFilters(
                        store: store,
                        key: productVariationFiltersState,
                        productVariationFilter: productVariationFilter,
                        onSelectedProductVariationFilter: onSelectedProductVariationFilter,
                      ),

                      /// Progress Bar
                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        child: AnimatedSwitcher(
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          duration: const Duration(milliseconds: 500),
                          child: canShowProgressBar 
                            ? Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: CustomProgressBar(percentage: onSendProgressPercentage)
                              )
                            : null
                        ),
                      )
                      
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
                Get.toNamed(ProductsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button (show if provided)
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingProductVariations ? 112 : 56) + topPadding + (canShowProgressBar ? 28 : 0),
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}