import 'package:bonako_demo/features/addresses/enums/address_enums.dart';
import './../../../core/shared_models/mobile_number.dart';

class DeliveryAddress {
  late int id;
  late AddressType type;
  late String addressLine;
  late DateTime createdAt;
  late DateTime updatedAt;
  late Metadata? metadata;

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressLine = json['addressLine'];
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