import './../../../core/shared_models/link.dart';

class Address {
  late int id;
  late String name;
  late Links? links;
  late bool shareAddress;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String? addressLine;

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    addressLine = json['addressLine'];
    shareAddress = json['shareAddress'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    links = json['links'] == null ? null : Links.fromJson(json['links']);
  }
}

class Links {
  late Link self;
  late Link updateAddress;
  late Link deleteAddress;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    updateAddress = Link.fromJson(json['updateAddress']);
    deleteAddress = Link.fromJson(json['deleteAddress']);
  }
}