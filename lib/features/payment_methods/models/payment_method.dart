import 'package:perfect_order/core/shared_models/store_payment_method_association.dart';
import './../../../core/shared_models/link.dart';

class PaymentMethod {
  late int id;
  late String name;
  late bool active;
  late String method;
  late String category;
  late String description;
  late bool availableOnUssd;
  late Attributes attributes;
  late bool AvailableInStores;
  late bool availableOnPerfectPay;

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    method = json['method'];
    active = json['active'];
    category = json['category'];
    description = json['description'];
    availableOnUssd = json['availableOnUssd'];
    AvailableInStores = json['AvailableInStores'];
    availableOnPerfectPay = json['availableOnPerfectPay'];
    attributes = Attributes.fromJson(json['attributes'].runtimeType == List ? {} : json['attributes']);
  }
}


class Attributes {
  late bool isDpoCard;
  late bool isOrangeMoney;
  late StorePaymentMethodAssociation? storePaymentMethodAssociation;

  Attributes.fromJson(Map<String, dynamic> json) {
    isDpoCard = json['isDpoCard'];
    isOrangeMoney = json['isOrangeMoney'];
    storePaymentMethodAssociation = json['storePaymentMethodAssociation'] == null ? null : StorePaymentMethodAssociation.fromJson(json['storePaymentMethodAssociation']);
  }
}

class Links {
  late Link self;
  late Link updateAddress;
  late Link deleteAddress;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
  }
}