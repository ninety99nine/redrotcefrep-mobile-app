import 'package:bonako_demo/core/shared_models/money.dart';

class OrderPaidNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;
  late TransactionProperties transactionProperties;

  OrderPaidNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    orderProperties = OrderProperties.fromJson(json['order']);
    transactionProperties = TransactionProperties.fromJson(json['transaction']);
  }
}

class StoreProperties {
  late int id;
  late String name;

  StoreProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class OrderProperties {
  late int id;
  late String number;
  late String summary;
  late bool orderedByYou;
  late bool isAssociatedAsFriend;
  late CustomerProperties customerProperties;
  
  OrderProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    summary = json['summary'];
    orderedByYou = json['orderedByYou'];
    isAssociatedAsFriend = json['isAssociatedAsFriend'];
    customerProperties = CustomerProperties.fromJson(json['customer']);
  }
}

class CustomerProperties {
  late int id;
  late String name;
  late String lastName;
  late String firstName;

  CustomerProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lastName = json['lastName'];
    firstName = json['firstName'];
  }
}

class TransactionProperties {
  late int id;
  late Money amount;
  late String payerName;
  late String payerPhone;
  late bool orderedAndPaidByYou;
  late bool orderedAndPaidBySamePerson;

  TransactionProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    payerName = json['payerName'];
    payerPhone = json['payerPhone'];
    amount = Money.fromJson(json['amount']);
    orderedAndPaidByYou = json['orderedAndPaidByYou'];
    orderedAndPaidBySamePerson = json['orderedAndPaidBySamePerson'];
  }
}