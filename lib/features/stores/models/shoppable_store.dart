import '../../../../core/shared_models/product_line.dart';
import '../../../core/shared_models/cart.dart';
import '../../products/models/product.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'store.dart';

enum ShoppingCartCurrentView {
  storeCard,
  storePage,
}

/// The Shoppable Store Model is an extension of the Store Model
/// with the ability to support shopping activity while 
/// notifying listeners
class ShoppableStore extends Store with ChangeNotifier {
  
  Cart? shoppingCart;
  bool isLoading = false;
  List<Product> selectedProducts = [];
  List<ProductLine> productLinesNotFound = [];
  bool get hasShoppingCart => shoppingCart != null;
  bool get hasSelectedProducts => selectedProducts.isNotEmpty;

  /// The current view is the current view of the shopping cart
  /// that is consuming this ShoppableStore. We use this to
  /// determine whether to execute actions such as running 
  /// Rest API calls and updating the shopping cart UI 
  /// depending on whether that shopping cart view
  /// is on display or not. This saves us from
  /// making unnecessary Rest API calls and
  /// unnecessary UI updates
  ShoppingCartCurrentView? shoppingCartCurrentView;
  
  ShoppableStore.fromJson(super.json) : super.fromJson();

  /// Change the shopping cart current view
  changeShoppingCartCurrentView(ShoppingCartCurrentView shoppingCartCurrentView, { canNotifyListeners = true }) {
    this.shoppingCartCurrentView = shoppingCartCurrentView;
    if(canNotifyListeners) notifyListeners();
  }

  /// Start loader
  resetShoppingCart({ canNotifyListeners = true }) {
    isLoading = false;
    shoppingCart = null;
    selectedProducts = [];
    productLinesNotFound = [];
    if(canNotifyListeners) notifyListeners();
  }

  /// Start loader
  startLoader({ canNotifyListeners = true }) {
    isLoading = true;
    if(canNotifyListeners) notifyListeners();
  }

  /// Stop loader
  stopLoader({ canNotifyListeners = true }) {
    isLoading = false;
    if(canNotifyListeners) notifyListeners();
  }

  /// Set the shopping cart
  setShoppingCart(Cart? shoppingCart, { canNotifyListeners = true }) {
    this.shoppingCart = shoppingCart;
    if(canNotifyListeners) notifyListeners();
  }

  /// Update the selected product quantity by referencing using the product id
  void updateSelectedProductQuantity(Product selectedProduct, int quantity) {
    final index = selectedProducts.indexWhere((currSelectedProduct) => currSelectedProduct.id == selectedProduct.id);
    selectedProducts[index].quantity = quantity;
    notifyListeners();
  }

  /// Remove the selected product
  void addOrRemoveSelectedProduct(Product selectedProduct) {
    final bool doesNotExist = selectedProducts.where((currSelectedProduct) => currSelectedProduct.id == selectedProduct.id).isEmpty;
    doesNotExist ? selectedProducts.add(selectedProduct) : selectedProducts.removeWhere((currSelectedProduct) => currSelectedProduct.id == selectedProduct.id);
    if(selectedProducts.isEmpty) resetShoppingCart(canNotifyListeners: false);
    notifyListeners();
  }

  /// Select this product available on the store
  void selectProduct(Product selectedProduct, { canNotifyListeners = true }) {
    selectedProducts.add(selectedProduct);
    if(canNotifyListeners) notifyListeners();
  }

  /// Select these products available on the store
  void selectProducts(List<Product> selectedProducts, { canNotifyListeners = true }) {
    this.selectedProducts = selectedProducts;
    if(canNotifyListeners) notifyListeners();
  }

  /// Select these products from the provided product lines
  void selectProductsFromProductLines(List<ProductLine> productLines) {
    
    /// Compare the similarity of the product and the product line
    bool searchCriteria(Product product, ProductLine productLine) {
      return productLine.productId == product.id && productLine.name == product.name;
    }
    
    /// Get the products that match the product line by id and name
    selectedProducts = List<Product>.from(relationships.products.map((product) {
      
      ProductLine? currentProductLine = productLines.firstWhereOrNull((productLine) => searchCriteria(product, productLine));

      /// If the product does not exist, return null
      if( currentProductLine == null ) return null;

      /// Otherwise, update the product quantity as specified by the product line qunatity
      product.quantity = currentProductLine.quantity;

      /// Return the product that has been found
      return product;

    /// Filter out products that are null
    }).where((product) => product != null).toList());

    /// Get the product lines that do not match the product by id and name
    productLinesNotFound = productLines.where((productLine) {
      
      return relationships.products.where((product) => searchCriteria(product, productLine)).isEmpty;

    }).toList();

    notifyListeners();

  }

}