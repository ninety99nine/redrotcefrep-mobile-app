class FriendGroupUserRemovedNotification {
  late RemovedUserProperties removedUserProperties;
  late RemovedByUserProperties removedByUserProperties;
  late FriendGroupProperties friendGroupProperties;

  FriendGroupUserRemovedNotification.fromJson(Map<String, dynamic> json) {
    removedUserProperties = RemovedUserProperties.fromJson(json['user']);
    removedByUserProperties = RemovedByUserProperties.fromJson(json['user']);
    friendGroupProperties = FriendGroupProperties.fromJson(json['friendGroup']);
  }
}

class RemovedUserProperties {
  late int id;
  late String name;

  RemovedUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class RemovedByUserProperties {
  late int id;
  late String name;

  RemovedByUserProperties.fromJson(Map<String, dynamic> json) {
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