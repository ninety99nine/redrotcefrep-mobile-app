import 'package:bonako_demo/core/shared_models/money.dart';

class OrderCreatedNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;

  OrderCreatedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    orderProperties = OrderProperties.fromJson(json['order']);
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
  late Money amount;
  late String number;
  late String summary;
  late String orderFor;
  late int orderForTotalUsers;
  late int orderForTotalFriends;
  late bool isAssociatedAsFriend;
  late CustomerProperties customerProperties;

  OrderProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    summary = json['summary'];
    orderFor = json['orderFor'];
    amount = Money.fromJson(json['amount']);
    orderForTotalUsers = json['orderForTotalUsers'];
    orderForTotalFriends = json['orderForTotalFriends'];
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