import '../../../core/shared_models/mobile_number.dart';

class AccountExistenceUser {
  late Attributes attributes;
  late MobileNumber mobileNumber;

  AccountExistenceUser.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    mobileNumber = MobileNumber.fromJson(json['mobileNumber']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['mobileNumber'] = mobileNumber.toJson();
    return data;
  }
}

class Attributes {
  late bool requiresPassword;

  Attributes.fromJson(Map<String, dynamic> json) {
    requiresPassword = json['requiresPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requiresPassword'] = requiresPassword;
    return data;
  }
}