class ResourceTotals {
  late int totalGroups;
  late int totalStoresJoined;
  late int totalNotifications;
  late int totalStoresFollowing;
  late int totalStoresJoinedAsCreator;
  late int totalStoresJoinedAsNonCreator;

  ResourceTotals.fromJson(Map<String, dynamic> json) {
    totalGroups = json['totalGroups'];
    totalStoresJoined = json['totalStoresJoined'];
    totalNotifications = json['totalNotifications'];
    totalStoresFollowing = json['totalStoresFollowing'];
    totalStoresJoinedAsCreator = json['totalStoresJoinedAsCreator'];
    totalStoresJoinedAsNonCreator = json['totalStoresJoinedAsNonCreator'];
  }
}