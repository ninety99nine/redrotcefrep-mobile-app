import '../../../core/shared_models/mobile_number.dart';

class AccountExistence {
  late bool exists;
  late AccountSummary existingAccount;

  AccountExistence.fromJson(Map<String, dynamic> json) {
    exists = json['exists'];
    existingAccount = AccountSummary.fromJson(json['accountSummary']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exists'] = exists;
    data['existingAccount'] = existingAccount.toJson();
    return data;
  }
}

class AccountSummary {
  late bool requiresPassword;
  late MobileNumber mobileNumber;

  AccountSummary.fromJson(Map<String, dynamic> json) {
    requiresPassword = json['requiresPassword'];
    mobileNumber = MobileNumber.fromJson(json['mobileNumber']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requiresPassword'] = requiresPassword;
    data['mobileNumber'] = mobileNumber.toJson();
    return data;
  }
}