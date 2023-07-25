import 'package:bonako_demo/core/shared_models/money.dart';

class OrderStatusUpdatedNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;

  OrderStatusUpdatedNotification.fromJson(Map<String, dynamic> json) {
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
  late String status;
  late String number;
  late String summary;
  late String orderFor;
  late int orderForTotalUsers;
  late int orderForTotalFriends;
  late bool isAssociatedAsFriend;
  late CustomerProperties customerProperties;
  late ChangedByUserProperties changedByUserProperties;
  
  OrderProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status =json['status'];
    number = json['number'];
    summary = json['summary'];
    orderFor = json['orderFor'];
    amount = Money.fromJson(json['amount']);
    orderForTotalUsers = json['orderForTotalUsers'];
    orderForTotalFriends = json['orderForTotalFriends'];
    isAssociatedAsFriend = json['isAssociatedAsFriend'];
    customerProperties = CustomerProperties.fromJson(json['customer']);
    changedByUserProperties = ChangedByUserProperties.fromJson(json['changedByUser']);
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

class ChangedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  ChangedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}