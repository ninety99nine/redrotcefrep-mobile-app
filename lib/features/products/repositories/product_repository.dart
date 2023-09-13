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

  /// Show the specified product
  Future<dio.Response> showProduct({ bool withVariables = false }) {

    if(product == null) throw Exception('The product must be set to show');

    String url = product!.links.self.href;

    Map<String, String> queryParams = {};
    if(withVariables) queryParams.addAll({'withVariables': '1'});
    
    return apiRepository.get(url: url);
    
  }

  /// Update the specified product
  Future<dio.Response> updateProduct({ 
    bool? visible, String? name, bool? showDescription, String? description,
    String? unitRegularPrice, String? unitSalePrice, String? unitCostPrice,
    String? sku, String? barcode, bool? isFree, bool? allowVariations,
    String? allowedQuantityPerOrder, String? maximumAllowedQuantityPerOrder, 
    String? stockQuantity, String? stockQuantityType, bool withVariables = false
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

    Map<String, String> queryParams = {};
    if(withVariables) queryParams.addAll({'withVariables': '1'});

    return apiRepository.put(url: url, queryParams: queryParams, body: body);
    
  }

  /// Show the specified product variations
  Future<dio.Response> showProductVariations({ String? variantAttributeChoices, String? filter, String searchWord = '', int page = 1 }) {

    if(product == null) throw Exception('The product must be set to show variations');

    String url = product!.links.showVariations.href;

    Map<String, String> queryParams = {};

    if(variantAttributeChoices != null) queryParams.addAll({ 'variantAttributeChoices': variantAttributeChoices });
      
    /// Filter coupons by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Create the specified product variations
  Future<dio.Response> createVariations({ required List<Map<String, dynamic>> variantAttributes, void Function(int, int)? onSendProgress }) {

    if(product == null) throw Exception('The product must be set to create variations');

    String url = product!.links.createVariations.href;
    
    Map<String, dynamic> body = {
      'variantAttributes': variantAttributes
    };

    return apiRepository.post(url: url, body: body, onSendProgress: onSendProgress);
    
  }

  /// Delete the specified product
  Future<dio.Response> deleteProduct() {

    if(product == null) throw Exception('The product must be set to delete');
    String url = product!.links.deleteProduct.href;
    return apiRepository.delete(url: url);
    
  }

}