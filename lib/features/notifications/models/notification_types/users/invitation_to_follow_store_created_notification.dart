class InvitationToFollowStoreCreatedNotification {
  late StoreProperties storeProperties;
  late InvitedByUserProperties invitedByUserProperties;

  InvitationToFollowStoreCreatedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    invitedByUserProperties = InvitedByUserProperties.fromJson(json['invitedByUser']);
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

class InvitedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  InvitedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}