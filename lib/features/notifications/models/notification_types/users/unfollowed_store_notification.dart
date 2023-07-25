class UnfollowedStoreNotification {
  late StoreProperties storeProperties;
  late UnfollowedByUserProperties unfollowedByUserProperties;

  UnfollowedStoreNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    unfollowedByUserProperties = UnfollowedByUserProperties.fromJson(json['unfollowedByUser']);
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

class UnfollowedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  UnfollowedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}