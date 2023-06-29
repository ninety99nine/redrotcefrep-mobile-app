import './../../../core/shared_models/mobile_number.dart';

class DeliveryAddress {
  late int id;
  late String name;
  late bool shareAddress;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String? addressLine;

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    addressLine = json['addressLine'];
    shareAddress = json['shareAddress'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
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