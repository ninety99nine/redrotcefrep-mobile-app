class RemoveStoreTeamMemberNotification {
  late StoreProperties storeProperties;
  late RemovedUserProperties removedUserProperties;
  late RemovedByUserProperties removedByUserProperties;

  RemoveStoreTeamMemberNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    removedUserProperties = RemovedUserProperties.fromJson(json['removedUser']);
    removedByUserProperties = RemovedByUserProperties.fromJson(json['removedByUser']);
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

class RemovedUserProperties {
  late int id;
  late String name;
  late String firstName;

  RemovedUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}

class RemovedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  RemovedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}