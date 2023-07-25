class FriendGroupStoreRemovedNotification {
  late StoreProperties storeProperties;
  late FriendGroupProperties friendGroupProperties;
  late RemovedByUserProperties removedByUserProperties;

  FriendGroupStoreRemovedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    friendGroupProperties = FriendGroupProperties.fromJson(json['friendGroup']);
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

class FriendGroupProperties {
  late int id;
  late String name;

  FriendGroupProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
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