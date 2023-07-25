class FriendGroupUserAddedNotification {
  late AddedUserProperties addedUserProperties;
  late AddedByUserProperties addedByUserProperties;
  late FriendGroupProperties friendGroupProperties;

  FriendGroupUserAddedNotification.fromJson(Map<String, dynamic> json) {
    addedUserProperties = AddedUserProperties.fromJson(json['user']);
    addedByUserProperties = AddedByUserProperties.fromJson(json['user']);
    friendGroupProperties = FriendGroupProperties.fromJson(json['friendGroup']);
  }
}

class AddedUserProperties {
  late int id;
  late String name;

  AddedUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class AddedByUserProperties {
  late int id;
  late String name;

  AddedByUserProperties.fromJson(Map<String, dynamic> json) {
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