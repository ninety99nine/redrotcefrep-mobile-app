class OrderSeenNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;
  late CustomerProperties customerProperties;
  late SeenByUserProperties seenByUserProperties;

  OrderSeenNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    orderProperties = OrderProperties.fromJson(json['order']);
    customerProperties = CustomerProperties.fromJson(json['customer']);
    seenByUserProperties = SeenByUserProperties.fromJson(json['seenByUser']);
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
    isAssociatedAsFriend = json['isAssociatedAsFriend'];
    isAssociatedAsCustomer = json['isAssociatedAsCustomer'];
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

class SeenByUserProperties {
  late int id;
  late String name;
  late String firstName;

  SeenByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}