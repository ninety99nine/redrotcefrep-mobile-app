import 'package:perfect_order/core/shared_models/money.dart';

class OrderPaidUsingDpoNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;
  late TransactionProperties transactionProperties;
  late PaymentMethodProperties paymentMethodProperties;

  OrderPaidUsingDpoNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    orderProperties = OrderProperties.fromJson(json['order']);
    transactionProperties = TransactionProperties.fromJson(json['transaction']);
    paymentMethodProperties = PaymentMethodProperties.fromJson(json['paymentMethod']);
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
  late bool isAssociatedAsFriend;
  late bool isAssociatedAsCustomer;
  
  OrderProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    isAssociatedAsFriend = json['isAssociatedAsFriend'];
    isAssociatedAsCustomer = json['isAssociatedAsCustomer'];
  }
}

class PaymentMethodProperties {
  late int id;
  late String name;

  PaymentMethodProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class TransactionProperties {
  late int id;
  late Money amount;
  late bool paidByYou;
  late int percentage;
  late String dpoCustomerName;

  TransactionProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paidByYou = json['paidByYou'];
    percentage = json['percentage'];
    amount = Money.fromJson(json['amount']);
    dpoCustomerName = json['dpoCustomerName'];
  }
}