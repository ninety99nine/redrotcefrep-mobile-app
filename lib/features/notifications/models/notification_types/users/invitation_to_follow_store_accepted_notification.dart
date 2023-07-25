class InvitationToFollowStoreAcceptedNotification {
  late StoreProperties storeProperties;
  late AcceptedByUserProperties acceptedByUserProperties;

  InvitationToFollowStoreAcceptedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    acceptedByUserProperties = AcceptedByUserProperties.fromJson(json['acceptedByUser']);
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

class AcceptedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  AcceptedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}