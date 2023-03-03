import '../../../../core/shared_models/product_line.dart';
import '../../../../core/shared_models/coupon_line.dart';
import '../../../../core/shared_models/currency.dart';
import '../../../../core/shared_models/status.dart';
import '../../../../core/shared_models/money.dart';

class Cart {

  late int? id;
  late int storeId;
  late Money subTotal;
  late Money grandTotal;
  late int totalCoupons;
  late Money deliveryFee;
  late int totalProducts;
  late Currency currency;
  late int? instantCartId;
  late Status hasDeliveryFee;
  late Money saleDiscountTotal;
  late Status allowFreeDelivery;
  late Money couponDiscountTotal;
  late int totalCancelledCoupons;
  late int totalProductQuantities;
  late int totalCancelledProducts;
  late Relationships relationships;
  late int totalUncancelledCoupons;
  late int totalUncancelledProducts;
  late Money couponAndSaleDiscountTotal;
  late int totalCancelledProductQuantities;
  late int totalUncancelledProductQuantities;
  late List<DetectedChange> detectedChanges;

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['storeId'];
    totalCoupons = json['totalCoupons'];
    totalProducts = json['totalProducts'];
    instantCartId = json['instantCartId'];
    subTotal = Money.fromJson(json['subTotal']);
    currency = Currency.fromJson(json['currency']);
    grandTotal = Money.fromJson(json['grandTotal']);
    deliveryFee = Money.fromJson(json['deliveryFee']);
    totalCancelledCoupons = json['totalCancelledCoupons'];
    totalProductQuantities = json['totalProductQuantities'];
    totalCancelledProducts = json['totalCancelledProducts'];
    hasDeliveryFee = Status.fromJson(json['hasDeliveryFee']);
    totalUncancelledCoupons = json['totalUncancelledCoupons'];
    totalUncancelledProducts = json['totalUncancelledProducts'];
    relationships = Relationships.fromJson(json['relationships']);
    saleDiscountTotal = Money.fromJson(json['saleDiscountTotal']);
    allowFreeDelivery = Status.fromJson(json['allowFreeDelivery']);
    couponDiscountTotal = Money.fromJson(json['couponDiscountTotal']);
    detectedChanges = json['detectedChanges'] == null ? [] : (json['detectedChanges'] as List).map((detectedChange) {
      return DetectedChange.fromJson(detectedChange);
    }).toList();
    totalCancelledProductQuantities = json['totalCancelledProductQuantities'];
    totalUncancelledProductQuantities = json['totalUncancelledProductQuantities'];
    couponAndSaleDiscountTotal = Money.fromJson(json['couponAndSaleDiscountTotal']);
  }
}

class DetectedChange {
  late String type;
  late DateTime date;
  late String message;
  late bool notifiedUser;

  DetectedChange.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    message = json['message'];
    notifiedUser = json['notifiedUser'];
    date = DateTime.parse(json['date']);
  }
}

class Relationships {
  late List<CouponLine> couponLines;
  late List<ProductLine> productLines;

  Relationships.fromJson(Map<String, dynamic> json) {
    couponLines = (json['couponLines'] as List).map((product) => CouponLine.fromJson(product)).toList();
    productLines = (json['productLines'] as List).map((product) => ProductLine.fromJson(product)).toList();
  }
}