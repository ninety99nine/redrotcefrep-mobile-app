import 'package:bonako_demo/core/shared_models/money.dart';

class OrderUpdatedNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;
  late OcassionProperties? ocassionProperties;

  OrderUpdatedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    orderProperties = OrderProperties.fromJson(json['order']);
    ocassionProperties = json['occasion'] == null ? null : OcassionProperties.fromJson(json['occasion']);
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
  late bool isAssociatedAsCustomer;
  late CustomerProperties customerProperties;
  late UpdatedByUserProperties updatedByUserProperties;

  OrderProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    summary = json['summary'];
    orderFor = json['orderFor'];
    amount = Money.fromJson(json['amount']);
    orderForTotalUsers = json['orderForTotalUsers'];
    orderForTotalFriends = json['orderForTotalFriends'];
    isAssociatedAsFriend = json['isAssociatedAsFriend'];
    isAssociatedAsCustomer = json['isAssociatedAsCustomer'];
    customerProperties = CustomerProperties.fromJson(json['customer']);
    updatedByUserProperties = UpdatedByUserProperties.fromJson(json['updatedByUser']);
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

class UpdatedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  UpdatedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}

class OcassionProperties {
  late String name;

  OcassionProperties.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
}