import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import '../../products/models/product.dart';
import 'package:http/http.dart' as http;

class ProductRepository {

  /// The product does not exist until it is set.
  final Product? product;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  ProductRepository({ this.product, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Update the specified product
  Future<http.Response> updateProduct({ 
    required String name, required String? description, required bool showDescription, required bool visible,
    required String unitRegularPrice, required String unitSalePrice, required String unitCostPrice,
    required String? sku, required String? barcode, required bool isFree, required bool allowVariations,
    required String allowedQuantityPerOrder, required String maximumAllowedQuantityPerOrder, 
    required String stockQuantity, required String stockQuantityType, 
  }) {

    if(product == null) throw Exception('The product must be set to update');

    String url = product!.links.updateProduct.href;
    
    Map body = {
      'name': name,
      'is_free': isFree,
      'visible': visible,
      'unit_cost_price': unitCostPrice,
      'unit_sale_price': unitSalePrice,
      'allow_variations': allowVariations,
      'show_description': showDescription,
      'unit_regular_price': unitRegularPrice,
      'stock_quantity_type': stockQuantityType,
      'allowed_quantity_per_order': allowedQuantityPerOrder,
    };

    if(sku != null && sku.isNotEmpty) body['sku'] = sku;
    if(barcode != null && barcode.isNotEmpty) body['barcode'] = barcode;
    if(stockQuantityType == 'limited') body['stock_quantity'] = stockQuantity;
    if(description != null && description.isNotEmpty) body['description'] = description;
    if(allowedQuantityPerOrder == 'limited') body['maximum_allowed_quantity_per_order'] = maximumAllowedQuantityPerOrder;
    
    return apiRepository.put(url: url, body: body);
    
  }

  /// Delete the specified product
  Future<http.Response> deleteProduct() {

    if(product == null) throw Exception('The product must be set to delete');
    String url = product!.links.deleteProduct.href;
    return apiRepository.delete(url: url);
    
  }

}