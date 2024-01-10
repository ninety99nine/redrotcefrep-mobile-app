import 'package:bonako_demo/core/shared_models/money.dart';

class OrderPaymentRequestNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;
  late CustomerProperties customerProperties;
  late TransactionProperties transactionProperties;
  late PaymentMethodProperties paymentMethodProperties;
  late RequestedByUserProperties requestedByUserProperties;

  OrderPaymentRequestNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    orderProperties = OrderProperties.fromJson(json['order']);
    customerProperties = CustomerProperties.fromJson(json['customer']);
    transactionProperties = TransactionProperties.fromJson(json['transaction']);
    paymentMethodProperties = PaymentMethodProperties.fromJson(json['paymentMethod']);
    requestedByUserProperties = RequestedByUserProperties.fromJson(json['requestedByUser']);
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
  late bool isAssociatedAsFriend;
  late bool isAssociatedAsCustomer;
  
  OrderProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    summary = json['summary'];
  }
}

class CustomerProperties {
  late int id;
  late String name;
  late String firstName;

  CustomerProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}

class RequestedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  RequestedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
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
  late int percentage;
  late String? dpoPaymentUrl;

  TransactionProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    percentage = json['percentage'];
    dpoPaymentUrl = json['dpoPaymentUrl'];
    amount = Money.fromJson(json['amount']);
  }
}