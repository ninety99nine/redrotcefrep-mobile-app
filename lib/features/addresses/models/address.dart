import 'package:bonako_demo/features/addresses/enums/address_enums.dart';

import './../../../core/shared_models/mobile_number.dart';
import './../../../core/shared_models/link.dart';

class Address {
  late int id;
  late Links links;
  late AddressType type;
  late String addressLine;
  late DateTime createdAt;
  late DateTime updatedAt;
  late Metadata? metadata;

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressLine = json['addressLine'];
    links = Links.fromJson(json['links']);
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    metadata = json['metadata'] == null ? null : Metadata.fromJson(json['metadata']);
    type = AddressType.values.firstWhere((addressType) => addressType.toString() == 'AddressType.${json['type'].toLowerCase()}');
  }
}

class Metadata {
  late String name;
  late MobileNumber? mobileNumber;

  Metadata.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mobileNumber = json['mobileNumber'] == null ? null : MobileNumber.fromJson(json['mobileNumber']);
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