class FollowingStoreNotification {
  late StoreProperties storeProperties;
  late FollowedByUserProperties followedByUserProperties;

  FollowingStoreNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    followedByUserProperties = FollowedByUserProperties.fromJson(json['followedByUser']);
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

class FollowedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  FollowedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}