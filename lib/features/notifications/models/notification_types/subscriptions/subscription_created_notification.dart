import 'package:perfect_order/core/shared_models/mobile_number.dart';

class SubscriptionCreatedNotification {
  late TransactionProperties transactionProperties;
  late SubscriptionProperties subscriptionProperties;
  late SubscriptionForProperties subscriptionForProperties;
  late SubscriptionByUserProperties subscriptionByUserProperties;
  late SubscriptionForUserProperties subscriptionForUserProperties;

  SubscriptionCreatedNotification.fromJson(Map<String, dynamic> json) {
    transactionProperties = TransactionProperties.fromJson(json['transaction']);
    subscriptionProperties = SubscriptionProperties.fromJson(json['subscription']);
    subscriptionForProperties = SubscriptionForProperties.fromJson(json['subscriptionFor']);
    subscriptionByUserProperties = SubscriptionByUserProperties.fromJson(json['subscriptionByUser']);
    subscriptionForUserProperties = SubscriptionForUserProperties.fromJson(json['subscriptionForUser']);
  }
}

class SubscriptionForProperties {
  late int id;
  late String name;
  late String type;

  SubscriptionForProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
  }
}

class SubscriptionProperties {
  late int id;
  late DateTime endAt;
  late DateTime startAt;

  SubscriptionProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    endAt = DateTime.parse(json['endAt']);
    startAt = DateTime.parse(json['startAt']);
  }
}

class TransactionProperties {
  late int id;
  late String description;

  TransactionProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
  }
}

class SubscriptionByUserProperties {
  late int id;
  late String name;
  late String firstName;

  SubscriptionByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}

class SubscriptionForUserProperties {
  late int id;
  late String name;
  late String firstName;

  SubscriptionForUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}