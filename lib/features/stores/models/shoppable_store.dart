import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/features/addresses/models/address.dart';
import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';

import '../../../../core/shared_models/product_line.dart';
import '../../occasions/models/occasion.dart';
import '../../../core/shared_models/cart.dart';
import '../../products/models/product.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'store.dart';

enum ShoppingCartCurrentView {
  storeCard,
  storePage,
  storeOrdersModalBottomSheet,
}

/// The Shoppable Store Model is an extension of the Store Model
/// with the ability to support shopping activity while 
/// notifying listeners
class ShoppableStore extends Store with ChangeNotifier {
  
  Cart? shoppingCart;
  bool isLoading = false;
  List<Product> selectedProducts = [];
  List<ProductLine> productLinesNotFound = [];
  bool teamMemberWantsToViewAsCustomer = false;

  bool get hasShoppingCart => shoppingCart != null;
  int get totalSelectedProducts => selectedProducts.length;
  bool get hasSelectedProducts => selectedProducts.isNotEmpty;

  bool get hasCoverPhoto => coverPhoto != null;
  bool get doesNotHaveCoverPhoto => coverPhoto == null;

  int get totalProductPhotos => productPhotos.length;
  bool get hasProductPhotos => productPhotos.isNotEmpty;
  bool get doesNotHaveProductPhotos => productPhotos.isEmpty;
  List<String> get productPhotos => productsWithPhotos.map((product) => product.photo!).toList();
  List<Product> get productsWithPhotos => relationships.products.where((product) => product.photo != null).toList();
  
  int? totalPeople;
  String orderFor = 'Me';
  List<User> friends = [];
  List<FriendGroup> friendGroups = [];
  bool get isOrderingForMe => orderFor == 'Me';
  bool get hasSelectedFriends => friends.isNotEmpty;
  bool get hasSelectedFriendGroups => friendGroups.isNotEmpty;
  bool get isOrderingForFriendsOnly => orderFor == 'Friends Only';
  bool get isOrderingForMeAndFriends => orderFor == 'Me And Friends';

  Address? addressForDelivery;
  CollectionType? collectionType;
  PickupDestination? pickupDestination;
  DeliveryDestination? deliveryDestination;

  PaymentMethod? paymentMethod;

  Occasion? occasion;

  String? specialNote;

  /// Callbacks
  List<Function(Order)> onCreatedOrderCallbacks = [];
  List<Function(Product)> onSelectedProductCallbacks = [];
  List<Function(Product)> onChangedProductQuantityCallbacks = [];
  List<Function(Product)> addOrRemoveSelectedProductCallbacks = [];
  
  ShoppableStore.fromJson(super.json) : super.fromJson();

  /// Start loader
  resetShoppingCart({ canNotifyListeners = true }) {
    friends = [];
    occasion = null;
    orderFor = 'Me';
    isLoading = false;
    friendGroups = [];
    specialNote = null;
    totalPeople = null;
    shoppingCart = null;
    paymentMethod = null;
    selectedProducts = [];
    collectionType = null;
    pickupDestination = null;
    productLinesNotFound = [];
    addressForDelivery = null;
    deliveryDestination = null;

    for (var i = 0; i < relationships.products.length; i++) {
      
      /// Reset the selected quantity on each product
      relationships.products[i].quantity = 1;

    }

    if(canNotifyListeners) notifyListeners();
  }

  setProducts(List<Product> products) {
    relationships.products = products;
    notifyListeners();
  }

  updatePaymentMethod(PaymentMethod paymentMethod) {
    this.paymentMethod = paymentMethod;
    notifyListeners();
  }

  updateOccasion(Occasion? occasion) {
    this.occasion = occasion;
    notifyListeners();
  }

  updateCollectionType(CollectionType collectionType) {
    this.collectionType = collectionType;
    notifyListeners();
  }

  updateSpecialNote(String? specialNote) {
    this.specialNote = specialNote;
    notifyListeners();
  }

  updateTeamMemberWantsToViewAsCustomer(bool status) {
    teamMemberWantsToViewAsCustomer = status;
    notifyListeners();
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

  /// Get the selected variations products matching the given parent product
  List<Product> getSelectedVariationProducts(Product product) {
    return selectedProducts.where((currProduct) => currProduct.variationAncestors.map((variationAncestor) => variationAncestor.id).contains(product.id)).toList();
  }

  /// Set the shopping cart
  setTotalPeople(int totalPeople, { canNotifyListeners = true }) {
    this.totalPeople = totalPeople;
    if(canNotifyListeners) notifyListeners();
  }

  /// Set the shopping cart
  setShoppingCart(Cart? shoppingCart, { canNotifyListeners = true }) {
    this.shoppingCart = shoppingCart;
    if(canNotifyListeners) notifyListeners();
  }

  /// Update the selected product quantity by referencing using the product id
  void updateSelectedProductQuantity(Product selectedProduct, int quantity) {
    selectedProduct.quantity = quantity;

    /// Call all callbacks registered on this shoppable store for whenever we change the product quantity
    for (var onChangedProductQuantityCallback in onChangedProductQuantityCallbacks) {
      onChangedProductQuantityCallback(selectedProduct);
    }

    notifyListeners();
  }

  bool checkIfSelectedProductExists(Product selectedProduct) {
    return selectedProducts.where((currSelectedProduct) => currSelectedProduct.id == selectedProduct.id).isNotEmpty;
  }

  /// Add the selected product
  void addSelectedProduct(Product selectedProduct) {
    final bool selectedProductAlreadyExists = checkIfSelectedProductExists(selectedProduct);

    if(selectedProductAlreadyExists) {
      int index = selectedProducts.indexWhere((currSelectedProduct) => currSelectedProduct.id == selectedProduct.id);
      selectedProducts[index] = selectedProduct;
    }else{
      selectedProducts.add(selectedProduct);
    }
    
    notifyListeners();
  }

  /// Remove the selected product
  void removeSelectedProduct(Product selectedProduct) {
    selectedProducts.removeWhere((currSelectedProduct) => currSelectedProduct.id == selectedProduct.id);
    notifyListeners();
  }

  /// Remove the selected product
  void addOrRemoveSelectedProduct(Product selectedProduct) {
    final bool selectedProductAlreadyExists = checkIfSelectedProductExists(selectedProduct);
    
    selectedProductAlreadyExists
      ? selectedProducts.removeWhere((currSelectedProduct) => currSelectedProduct.id == selectedProduct.id) 
      : selectedProducts.add(selectedProduct);

    if(selectedProducts.isEmpty) resetShoppingCart(canNotifyListeners: false);

    /// Call all callbacks registered on this shoppable store for whenever we add or remove a product
    for (var addOrRemoveSelectedProductCallback in addOrRemoveSelectedProductCallbacks) {
      addOrRemoveSelectedProductCallback(selectedProduct);
    }
    
    notifyListeners();
  }

  /// Select this product available on the store
  void selectProduct(Product selectedProduct, { canNotifyListeners = true }) {
    selectedProducts.add(selectedProduct);

    /// Call all callbacks registered on this shoppable store for whenever we select a product
    for (var onSelectedProductCallback in onSelectedProductCallbacks) {
      onSelectedProductCallback(selectedProduct);
    }

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

  /// Add a product to the store product relationship
  void addProductRelationship(Product product, { canNotifyListeners = true }) {
    relationships.products.add(product);
    if(canNotifyListeners) notifyListeners();
  }

  /// Remove a product from the store product relationship
  void removeProductRelationship(Product product, { canNotifyListeners = true }) {
    relationships.products.removeWhere((currProduct) => currProduct.id == product.id);
    if(canNotifyListeners) notifyListeners();
  }

  /// Call all the registered listeners.
  void runNotifyListeners() {
    notifyListeners();
  }

}