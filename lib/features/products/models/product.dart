import '../../../../core/shared_models/value_and_description.dart';
import '../../../core/shared_models/variant_attribute.dart';
import 'package:bonako_demo/core/shared_models/link.dart';
import '../../../../core/shared_models/currency.dart';
import '../../../../core/shared_models/status.dart';
import '../../../../core/shared_models/money.dart';

class ShoppableProduct {
  int quantity = 1;
  List<Product> variationAncestors = [];
  Map<int, Map<String, String>> selectedVariantAttributes = {};
}

class Product extends ShoppableProduct {
  late int id;
  late Links links;
  late String? sku;
  late String name;
  late String? photo;
  late Status isFree;
  late Status visible;
  late String? barcode;
  late Money unitPrice;
  late int? arrangement;
  late Currency currency;
  late String? description;
  late Money unitSalePrice;
  late Money unitCostPrice;
  late int? totalVariations;
  late Attributes attributes;
  late Status showDescription;
  late Status allowVariations;
  late Money unitRegularPrice;
  late int? totalVisibleVariations;
  late Relationships relationships;
  late ValueAndDescription stockQuantity;
  late ValueAndDescription stockQuantityType;
  late List<VariantAttribute> variantAttributes;
  late ValueAndDescription allowedQuantityPerOrder;
  late ValueAndDescription maximumAllowedQuantityPerOrder;

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sku = json['sku'];
    name = json['name'];
    photo = json['photo'];
    barcode = json['barcode'];
    arrangement = json['arrangement'];
    description = json['description'];
    links = Links.fromJson(json['links']);
    isFree = Status.fromJson(json['isFree']);
    totalVariations = json['totalVariations'];
    visible = Status.fromJson(json['visible']);
    unitPrice = Money.fromJson(json['unitPrice']);
    currency = Currency.fromJson(json['currency']);
    unitCostPrice = Money.fromJson(json['unitCostPrice']);
    unitSalePrice = Money.fromJson(json['unitSalePrice']);
    totalVisibleVariations = json['totalVisibleVariations'];
    allowVariations = Status.fromJson(json['allowVariations']);
    showDescription = Status.fromJson(json['showDescription']);
    unitRegularPrice = Money.fromJson(json['unitRegularPrice']);
    stockQuantity = ValueAndDescription.fromJson(json['stockQuantity']);
    stockQuantityType = ValueAndDescription.fromJson(json['stockQuantityType']);
    allowedQuantityPerOrder = ValueAndDescription.fromJson(json['allowedQuantityPerOrder']);
    attributes = Attributes.fromJson(json['attributes'].runtimeType == List ? {} : json['attributes']);
    maximumAllowedQuantityPerOrder = ValueAndDescription.fromJson(json['maximumAllowedQuantityPerOrder']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
    variantAttributes = (json['variantAttributes'] as List).map((variantAttribute) => VariantAttribute.fromJson(variantAttribute)).toList();
  }
}

class Attributes {
  late bool isVariation;

  Attributes.fromJson(Map<String, dynamic> json) {
    isVariation = json['isVariation'];
  }
}

class Relationships {
  late List<Variable>? variables;
  late List<Product>? variations;

  Relationships.fromJson(Map<String, dynamic> json) {
    variables = json['variables'] == null ? null : (json['variables'] as List).map((variable) => Variable.fromJson(variable)).toList();
    variations = json['variations'] == null ? null : (json['variations'] as List).map((product) => Product.fromJson(product)).toList();
  }
}

class Variable {
  late int id;
  late String name;
  late String value;
  late int productId;

  Variable.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    value = json['value'];
    productId = json['productId'];
  }
}

class Links {
  late Link self;
  late Link showPhoto;
  late Link updatePhoto;
  late Link deletePhoto;
  late Link updateProduct;
  late Link deleteProduct;
  late Link showVariations;
  late Link createVariations;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    showPhoto = Link.fromJson(json['showPhoto']);
    updatePhoto = Link.fromJson(json['updatePhoto']);
    deletePhoto = Link.fromJson(json['deletePhoto']);
    updateProduct = Link.fromJson(json['updateProduct']);
    deleteProduct = Link.fromJson(json['deleteProduct']);
    showVariations = Link.fromJson(json['showVariations']);
    createVariations = Link.fromJson(json['createVariations']);
  }

}