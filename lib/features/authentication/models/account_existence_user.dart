import '../../../core/shared_models/mobile_number.dart';

class AccountExistenceUser {
  late String firstName;
  late String lastName;
  late Attributes attributes;
  late MobileNumber mobileNumber;

  AccountExistenceUser.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    attributes = Attributes.fromJson(json['attributes']);
    mobileNumber = MobileNumber.fromJson(json['mobileNumber']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastName'] = lastName;
    data['firstName'] = firstName;
    data['attributes'] = attributes.toJson();
    data['mobileNumber'] = mobileNumber.toJson();
    return data;
  }
}

class Attributes {
  late String name;
  late bool requiresPassword;

  Attributes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    requiresPassword = json['requiresPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['requiresPassword'] = requiresPassword;
    return data;
  }
}