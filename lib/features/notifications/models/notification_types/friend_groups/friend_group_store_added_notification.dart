class FriendGroupStoreAddedNotification {
  late StoreProperties storeProperties;
  late AddedByUserProperties addedByUserProperties;
  late FriendGroupProperties friendGroupProperties;

  FriendGroupStoreAddedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    addedByUserProperties = AddedByUserProperties.fromJson(json['addedByUser']);
    friendGroupProperties = FriendGroupProperties.fromJson(json['friendGroup']);
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

class AddedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  AddedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}