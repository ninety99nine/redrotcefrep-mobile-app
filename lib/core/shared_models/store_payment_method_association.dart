class StorePaymentMethodAssociation {
  late int id;
  late bool active;
  late int storeId;
  late int totalEnabled;
  late int totalDisabled;
  late DateTime createdAt;
  late DateTime updatedAt;
  late int paymentMethodId;
  late String? instruction;

  StorePaymentMethodAssociation.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    active = json['active'];
    storeId = json['storeId'];
    instruction = json['instruction'];
    totalEnabled = json['totalEnabled'];
    totalDisabled = json['totalDisabled'];
    paymentMethodId = json['paymentMethodId'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }
}