import 'package:bonako_demo/core/shared_models/store_payment_method_association.dart';
import './../../../core/shared_models/link.dart';

class PaymentMethod {
  late int id;
  late String name;
  late bool active;
  late bool activeOnUssd;
  late String description;
  late bool activeOnStores;
  late Attributes attributes;

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    active = json['active'];
    description = json['description'];
    activeOnUssd = json['activeOnUssd'];
    activeOnStores = json['activeOnStores'];
    attributes = Attributes.fromJson(json['attributes'].runtimeType == List ? {} : json['attributes']);
  }
}


class Attributes {
  late StorePaymentMethodAssociation? storePaymentMethodAssociation;

  Attributes.fromJson(Map<String, dynamic> json) {
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