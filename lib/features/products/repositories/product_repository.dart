import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import '../../products/models/product.dart';
import 'package:dio/dio.dart' as dio;

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
  Future<dio.Response> updateProduct({ 
    bool? visible, String? name, bool? showDescription, String? description,
    String? unitRegularPrice, String? unitSalePrice, String? unitCostPrice,
    String? sku, String? barcode, bool? isFree, bool? allowVariations,
    String? allowedQuantityPerOrder, String? maximumAllowedQuantityPerOrder, 
    String? stockQuantity, String? stockQuantityType, 
  }) {

    if(product == null) throw Exception('The product must be set to update');

    String url = product!.links.updateProduct.href;
    
    Map<String, dynamic> body = {};

    if(visible != null) body['visible'] = visible;
    if(name != null && name.isNotEmpty) body['name'] = name;
    if(showDescription != null) body['showDescription'] = showDescription;
    if(description != null && description.isNotEmpty) body['description'] = description;
    if(unitRegularPrice != null && unitRegularPrice.isNotEmpty) body['unitRegularPrice'] = unitRegularPrice;
    if(unitSalePrice != null && unitSalePrice.isNotEmpty) body['unitSalePrice'] = unitSalePrice;
    if(unitCostPrice != null && unitCostPrice.isNotEmpty) body['unitCostPrice'] = unitCostPrice;
    if(sku != null && sku.isNotEmpty) body['sku'] = sku;
    if(barcode != null && barcode.isNotEmpty) body['barcode'] = barcode;
    if(isFree != null) body['isFree'] = isFree;
    if(allowVariations != null) body['allowVariations'] = allowVariations;
    if(allowedQuantityPerOrder != null && allowedQuantityPerOrder.isNotEmpty) body['allowedQuantityPerOrder'] = allowedQuantityPerOrder;
    if(maximumAllowedQuantityPerOrder != null && maximumAllowedQuantityPerOrder.isNotEmpty) body['maximumAllowedQuantityPerOrder'] = maximumAllowedQuantityPerOrder;
    if(stockQuantityType != null && stockQuantityType.isNotEmpty) {
      if(stockQuantity != null && stockQuantityType.toLowerCase() == 'limited') body['stockQuantity'] = stockQuantity;
      body['stockQuantityType'] = stockQuantityType;
    }
    return apiRepository.put(url: url, body: body);
    
  }

  /// Delete the specified product
  Future<dio.Response> deleteProduct() {

    if(product == null) throw Exception('The product must be set to delete');
    String url = product!.links.deleteProduct.href;
    return apiRepository.delete(url: url);
    
  }

}