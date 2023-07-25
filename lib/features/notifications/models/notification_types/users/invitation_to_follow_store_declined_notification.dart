class InvitationToFollowStoreDeclinedNotification {
  late StoreProperties storeProperties;
  late DeclinedByUserProperties declinedByUserProperties;

  InvitationToFollowStoreDeclinedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    declinedByUserProperties = DeclinedByUserProperties.fromJson(json['declinedByUser']);
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

class DeclinedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  DeclinedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}