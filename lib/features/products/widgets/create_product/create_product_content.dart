import 'package:bonako_demo/features/products/widgets/create_product/create_product_form/create_product_form.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateProductContent extends StatefulWidget {
  
  final Product? product;
  final ShoppableStore store;
  final bool showingFullPage;
  final Function(Product)? onDeletedProduct;
  final Function(Product)? onUpdatedProduct;
  final Function(Product)? onCreatedProduct;

  const CreateProductContent({
    super.key,
    required this.store,
    required this.product,
    this.onDeletedProduct,
    this.onUpdatedProduct,
    this.onCreatedProduct,
    this.showingFullPage = false
  });

  @override
  State<CreateProductContent> createState() => _CreateProductContentState();
}

class _CreateProductContentState extends State<CreateProductContent> {

  bool isDeleting = false;
  bool isSubmitting = false;
  bool get isCreating => product == null;
  Product? get product => widget.product;
  bool disableFloatingActionButton = false;
  ShoppableStore get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  String get title => isCreating ? 'Add Product' : 'Edit Product';
  Function(Product)? get onDeletedProduct => widget.onDeletedProduct;
  Function(Product)? get onUpdatedProduct => widget.onUpdatedProduct;
  Function(Product)? get onCreatedProduct => widget.onCreatedProduct;
  String get subtitle => isCreating ? 'What are you selling?' : 'Want to make changes?';
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// This allows us to access the state of CreateProductForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CreateProductFormState> _createProductFormState = GlobalKey<CreateProductFormState>();

  /// Content to show based on the specified view
  Widget get content {
    
    return CreateProductForm(
      store: store,
      product: product,
      onDeleting: onDeleting,
      onSubmitting: onSubmitting,
      key: _createProductFormState,
      onDeletedProduct: _onDeletedProduct,
      onCreatedProduct: _onCreatedProduct,
      onUpdatedProduct: _onUpdatedProduct,
    );

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

  void _onCreatedProduct(Product product){
    
    /// Close the bottom modal sheet
    Get.back();

    if(onCreatedProduct != null) onCreatedProduct!(product);

  }

  void _onUpdatedProduct(Product product){
    
    /// Close the bottom modal sheet
    Get.back();

    if(onUpdatedProduct != null) onUpdatedProduct!(product);

  }

  void _onDeletedProduct(Product product){
    
    /// Close the bottom modal sheet
    Get.back();

    if(onDeletedProduct != null) onDeletedProduct!(product);
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      width: 120,
      isLoading: isSubmitting,
      isCreating ? 'Create' : 'Save Changes',
      onPressed: floatingActionButtonOnPressed,
      prefixIcon: isCreating ? Icons.add : null,
      color: isDeleting ? Colors.grey : Colors.green,
    );

  }

  /// Action to be called when the floating action button is pressed 
  void floatingActionButtonOnPressed() {

    /// If we should disable the floating action button, then do nothing
    if(disableFloatingActionButton) return;

    /// If we are viewing the reviews content
    if(isCreating) {

      if(_createProductFormState.currentState != null) {
        _createProductFormState.currentState!.requestCreateProduct();
      }
    
    }else{

      if(_createProductFormState.currentState != null) {
        _createProductFormState.currentState!.requestUpdateProduct();
      }
      
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          Column(
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
                    CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBodyText(subtitle),
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
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Navigator.of(context).pop();

                /// Set the store
                storeProvider.setStore(store);
                
                /// Navigate to the page
                //Navigator.of(context).pushNamed(ReviewsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
  
          /// Floating Button
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: 56 + topPadding,
            child: floatingActionButton
          )
        ],
      ),
    );
  }
}