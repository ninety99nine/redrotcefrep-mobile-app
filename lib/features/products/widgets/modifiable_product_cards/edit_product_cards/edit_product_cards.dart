import 'package:bonako_demo/features/products/widgets/create_product/create_product_modal_bottom_sheet/create_product_modal_bottom_sheet.dart';
import '../../../../../../../core/shared_widgets/buttons/show_more_or_less_button.dart';
import '../../../../../../../core/constants/constants.dart' as constants;
import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../models/product.dart';
import 'edit_product_card.dart';

class EditProductCards extends StatefulWidget {

  final ShoppingCartCurrentView shoppingCartCurrentView;

  const EditProductCards({
    super.key,
    required this.shoppingCartCurrentView,
  });

  @override
  State<EditProductCards> createState() => _EditProductCardsState();
}

class _EditProductCardsState extends State<EditProductCards> {
  
  ShoppableStore? store;
  bool showAllProducts = false;

  List<Product> get products => store == null ? [] : store!.relationships.products;
  ShoppingCartCurrentView get shoppingCartCurrentView => widget.shoppingCartCurrentView;
  bool get hasReachedMaximumProductsPerStore => products.length == constants.maximumProductsPerStore;
  bool get isShowingStorePage => Provider.of<StoreProvider>(context, listen: true).isShowingStorePage;
  bool get canShowMoreOrLessButton => isShoppingOnStoreCard && hasMoreProductsThanMinimumProductsToShow;
  bool get hasReachedMinimumProductsPerStoreOnPreview => products.length >= constants.minimumProductsPerStoreOnPreview;
  bool get isShoppingOnStorePage => (shoppingCartCurrentView == ShoppingCartCurrentView.storePage && isShowingStorePage);
  bool get isShoppingOnStoreCard => (shoppingCartCurrentView == ShoppingCartCurrentView.storeCard && !isShowingStorePage);
  List<Product> get filteredProducts => showAllProducts ? products : products.take(constants.minimumProductsPerStoreOnPreview).toList();
  bool get hasMoreProductsThanMinimumProductsToShow => (hasReachedMaximumProductsPerStore ? products.length : products.length + 1) > constants.minimumProductsPerStoreOnPreview;
  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /**
     *  When selecting a product, changing quantity, e.t.c, the Shoppable
     *  Store Model will be updated, which will then notify listeners, 
     *  and since we are listening for changes on this Store Model
     *  because of the property set on the build() method:
     * 
     *  Provider.of<ShoppableStore>(context, listen: true);
     * 
     *  This build() method will therefore be triggered to rebuild, thereby 
     *  causing the didChangeDependencies() to run as well. Once this
     *  happens we can execute the following updates:
     * 
     *  1) autoToggleShowAllProducts(): Automatically show all products if 
     *     we selected one of the products while other products where 
     *     hidden. This will allow the hidden products to be displayed
     */
    if(isShoppingOnStoreCard || isShoppingOnStorePage) {

      setState(() {
        autoToggleShowAllProducts();
      });

    }
    
  }

  void autoToggleShowAllProducts() {
    showAllProducts = isShoppingOnStorePage;
  }
  
  void toggleShowAllProducts() => setState(() {   
    showAllProducts = !showAllProducts;
  });

  void onUpdatedProduct(Product updatedProduct, int index) {
    setState(() => store!.relationships.products[index] = updatedProduct);
  }

  void onCreatedProduct(Product createdProduct) {
    store!.addProductRelationship(createdProduct);
  }

  void onDeletedProduct(Product deletedProduct) {
    store!.removeProductRelationship(deletedProduct);
  }

  Widget content() {
    return Column(
      key: ValueKey('$showAllProducts'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //  Product Cards
        ...filteredProducts.mapIndexed((index, product) {
          
          return EditProductCard(
            store: store!,
            product: product,
            onDeletedProduct: onDeletedProduct,
            onUpdatedProduct: (updatedProduct) => onUpdatedProduct(updatedProduct, index),
            margin: EdgeInsets.only(bottom: (index == filteredProducts.length - 1) ? 0 : 5)
          );
          
        }).toList(),

        if((showAllProducts || !hasReachedMinimumProductsPerStoreOnPreview) && !hasReachedMaximumProductsPerStore) CreateProductModalBottomSheet(
          store: store!,
          onCreatedProduct: onCreatedProduct,
        ),

        //  Spacer
        if(canShowMoreOrLessButton) const SizedBox(height: 8),

        /// Show More Or Less Button
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: canShowMoreOrLessButton ? ShowMoreOrLessButton(
                showAll: showAllProducts,
                toggleShowAll: toggleShowAllProducts
              ) : null
            ),
          ),
        ),

      ]
    );
  }

  @override
  Widget build(BuildContext context) {

    /**
     *  AnimatedSize helps to animate the sizing from a bigger height
     *  to a smaller height. When changing the content height, the 
     *  transition will be jumpy since the height is not the same.
     *  This helps animate those height differences.
     * 
     *  AnimatedSwitcher helps to animate the change of widgets
     *  by using an smooth opacity transition.
     */
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: content()
            )
          ),
        ],
      ),
    );
  }
}