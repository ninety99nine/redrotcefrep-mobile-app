import 'package:perfect_order/core/shared_widgets/progress_bar/progress_bar.dart';
import '../create_or_update_product_form/create_or_update_product_form.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:perfect_order/features/stores/services/store_services.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'products_in_vertical_list_view_infinite_scroll.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'products_page/products_page.dart';
import '../../enums/product_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_filters.dart';

class ProductsContent extends StatefulWidget {
  
  final Product? product;
  final ShoppableStore store;
  final bool showingFullPage;
  final Function(Product)? onUpdatedProduct;
  final Function(Product)? onCreatedProduct;
  final ProductContentView? productContentView;

  const ProductsContent({
    super.key,
    this.product,
    required this.store,
    this.onUpdatedProduct,
    this.onCreatedProduct,
    this.productContentView,
    this.showingFullPage = false,
  });

  @override
  State<ProductsContent> createState() => _ProductsContentState();
}

class _ProductsContentState extends State<ProductsContent> {

  Product? product;
  bool isDeleting = false;
  bool isSubmitting = false;
  String productFilter = 'All';
  int onSendProgressPercentage = 0;
  bool disableFloatingActionButton = false;
  bool get isVariation => product?.attributes.isVariation ?? false;
  ProductContentView productContentView = ProductContentView.viewingProducts;

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<ProductFiltersState> productFiltersState = GlobalKey<ProductFiltersState>();

  /// This allows us to access the state of CreateOrUpdateProductForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CreateOrUpdateProductFormState> _createProductFormState = GlobalKey<CreateOrUpdateProductFormState>();

  ShoppableStore get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  Function(Product)? get onUpdatedProduct => widget.onUpdatedProduct;
  Function(Product)? get onCreatedProduct => widget.onCreatedProduct;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isViewingProducts => productContentView == ProductContentView.viewingProducts;
  bool get isCreatingProduct => productContentView == ProductContentView.creatingProduct;
  bool get isEditingProduct => productContentView == ProductContentView.editingProduct;
  bool get canShowProgressBar => (isCreatingProduct || isEditingProduct) && isSubmitting && onSendProgressPercentage > 0;
  
  String get title {
    if(isViewingProducts) {
        return 'Products';
    }else if(isCreatingProduct) {
      return 'Create Product';
    }else{
      return product!.name;
    }

  }

  String get subtitle {

    if(isViewingProducts) {

      final bool showingAllProducts = productFilter.toLowerCase() == 'all';
      final bool showingHiddenProducts = productFilter.toLowerCase() == 'hidden';
      final bool showingVisibleProducts = productFilter.toLowerCase() == 'visible';
      
      if(showingAllProducts) {
        return 'Showing all products';
      }else if(showingHiddenProducts) {
        return 'Showing hidden products';
      }else if(showingVisibleProducts) {
        return 'Showing visible products';
      }

    }else if(isCreatingProduct) {
      return 'Create a new product';
    }else{
      return 'Edit product';
    }

    return '';

  }

  @override
  void initState() {
    super.initState();
    product = widget.product;
    if(product != null) productContentView = ProductContentView.editingProduct;
    if(widget.productContentView != null) productContentView = widget.productContentView!;
  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the products content
    if(isViewingProducts) {
    
      print('show ProductsInVerticalListViewInfiniteScroll()');

      /// Show products view
      return ProductsInVerticalListViewInfiniteScroll(
        store: store,
        productFilter: productFilter,
        onEditProduct: onEditProduct,
        productFiltersState: productFiltersState
      );

    /// If we want to view the create product content
    }else {
      
      print('show CreateOrUpdateProductForm()');

      return CreateOrUpdateProductForm(
        store: store,
        product: product,
        onLoading: (_)=>{},
        onDeleting: onDeleting,
        onSubmitting: onSubmitting,
        key: _createProductFormState,
        onSendProgress: onSendProgress,
        onDeletedProduct: onDeletedProduct,
        onCreatedProduct: _onCreatedProduct,
        onUpdatedProduct: _onUpdatedProduct,
        onRefreshedProduct: onRefreshedProduct
      );

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

  void onDeleting(status) {
    setState(() {
      isDeleting = status;
      disableFloatingActionButton = status;
    });
  }

  void _onCreatedProduct(Product product){
    if(onCreatedProduct != null) onCreatedProduct!(product);

    StoreServices.refreshProducts(store, storeProvider);
    changeProductContentView(ProductContentView.viewingProducts);
  }

  void onRefreshedProduct(Product product){
    setState(() => this.product = product);
  }

  void _onUpdatedProduct(Product product) {

    if(onUpdatedProduct != null) onUpdatedProduct!(product);

    /// Check if this product is a variation product
    if(isVariation) {

      /// Simply close the dialog
      Get.back();
      
    /// If this product is not a variation product
    }else{

      this.product = null;
      StoreServices.refreshProducts(store, storeProvider);
      changeProductContentView(ProductContentView.viewingProducts);

    }

  }

  void onDeletedProduct(Product product){
    this.product = null;
    StoreServices.refreshProducts(store, storeProvider);
    changeProductContentView(ProductContentView.viewingProducts);
  }

  void onGoBack(){
    product = null;
    changeProductContentView(ProductContentView.viewingProducts);
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    String title;

    if(isCreatingProduct) {
      title = 'Create';
    }else if(isViewingProducts) {
      title = 'Add Product';
    }else {
      title = 'Save Changes';
    }

    return Row(
      children: [

        if( productContentView != ProductContentView.viewingProducts && !isVariation ) ...[

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

        /// Add Product, Create or Save Changes button
        CustomElevatedButton(
          title,
          width: 120,
          isLoading: isSubmitting,
          color: isDeleting ? Colors.grey : null,
          onPressed: floatingActionButtonOnPressed,
          prefixIcon: isViewingProducts ? Icons.add : null,
        ),

      ],
    );

  }

  /// Action to be called when the floating action button is pressed
  void floatingActionButtonOnPressed() {

    /// If we have disabled the floating action button, then do nothing
    if(disableFloatingActionButton) return;

    /// If we are viewing the products content
    if(isViewingProducts) {

      /// Change to the invite product view
      changeProductContentView(ProductContentView.creatingProduct);

    /// If we are viewing the create or edit product content
    }else{

      /// If we are creating a new product
      if(isCreatingProduct) {

        if(_createProductFormState.currentState != null) {
          _createProductFormState.currentState!.requestCreateProduct();
        }
      
      /// If we are updating a product
      }else{

        if(_createProductFormState.currentState != null) {
          _createProductFormState.currentState!.requestUpdateProduct();
        }
      
      }

    }

  }

  /// Called when the user wants to edit a product
  void onEditProduct(Product product) {
    this.product = product;
    changeProductContentView(ProductContentView.editingProduct);
  }

  /// Called when the order filter has been changed,
  /// such as changing from "Joined" to "Left"
  void onSelectedProductFilter(String productFilter) {
    setState(() => this.productFilter = productFilter);
  }

  /// Called to change the view to the specified view
  void changeProductContentView(ProductContentView productContentView) {
    setState(() => this.productContentView = productContentView);
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
              key: ValueKey(productContentView.name),
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
                      CustomTitleMediumText(title, overflow: TextOverflow.ellipsis, maxLines: 1, padding: const EdgeInsets.only(bottom: 8),),
                      
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
                      if(isViewingProducts) ProductFilters(
                        store: store,
                        key: productFiltersState,
                        productFilter: productFilter,
                        onSelectedProductFilter: onSelectedProductFilter,
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
            top: (isViewingProducts ? 112 : 56) + topPadding + (canShowProgressBar ? 28 : 0),
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}