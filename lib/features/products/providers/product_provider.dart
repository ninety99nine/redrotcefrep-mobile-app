import '../repositories/product_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

/// The ProductProvider is strictly responsible for maintaining the state 
/// of the product. This state can then be shared with the rest of the 
/// application. Product related requests are managed by the 
/// ProductRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class ProductProvider with ChangeNotifier {
  
  Product? _product;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  ProductProvider({ required this.apiProvider });

  /// Return the product
  Product? get product => _product;

  /// Return the Product Repository
  ProductRepository get productRepository => ProductRepository(product: product, apiProvider: apiProvider);

  /// Set the specified product
  ProductProvider setProduct(Product product) {
    _product = product;
    return this;
  }
}