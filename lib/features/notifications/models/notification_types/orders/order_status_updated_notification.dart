class OrderStatusUpdatedNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;
  late CustomerProperties customerProperties;
  late UpdatedByUserProperties updatedByUserProperties;

  OrderStatusUpdatedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    orderProperties = OrderProperties.fromJson(json['order']);
    customerProperties = CustomerProperties.fromJson(json['customer']);
    updatedByUserProperties = UpdatedByUserProperties.fromJson(json['updatedByUser']);
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
  late String status;
  late String number;
  late String summary;
  late bool isAssociatedAsFriend;
  late bool isAssociatedAsCustomer;
  
  OrderProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status =json['status'];
    number = json['number'];
    summary = json['summary'];
    isAssociatedAsFriend = json['isAssociatedAsFriend'];
    isAssociatedAsCustomer = json['isAssociatedAsCustomer'];
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