class ResourceTotals {
  late int totalOrders;
  late int totalReviews;
  late int totalGroupsJoined;
  late int totalNotifications;
  late int totalSmsAlertCredits;
  late int totalStoresAsFollower;
  late int totalStoresAsCustomer;
  late int totalGroupsJoinedAsCreator;
  late int totalStoresJoinedAsCreator;
  late int totalStoresAsRecentVisitor;
  late int totalGroupsJoinedAsNonCreator;
  late int totalStoresJoinedAsTeamMember;
  late int totalStoresJoinedAsNonCreator;
  late int totalStoresInvitedToJoinAsTeamMember;
  late int totalGroupsInvitedToJoinAsGroupMember;
  

  ResourceTotals.fromJson(Map<String, dynamic> json) {
    totalOrders = json['totalOrders'];
    totalReviews = json['totalReviews'];
    totalGroupsJoined = json['totalGroupsJoined'];
    totalNotifications = json['totalNotifications'];
    totalSmsAlertCredits = json['totalSmsAlertCredits'];
    totalStoresAsFollower = json['totalStoresAsFollower'];
    totalStoresAsCustomer = json['totalStoresAsCustomer'];
    totalGroupsJoinedAsCreator = json['totalGroupsJoinedAsCreator'];
    totalStoresJoinedAsCreator = json['totalStoresJoinedAsCreator'];
    totalStoresAsRecentVisitor = json['totalStoresAsRecentVisitor'];
    totalGroupsJoinedAsNonCreator = json['totalGroupsJoinedAsNonCreator'];
    totalStoresJoinedAsNonCreator = json['totalStoresJoinedAsNonCreator'];
    totalStoresJoinedAsTeamMember = json['totalStoresJoinedAsTeamMember'];
    totalStoresInvitedToJoinAsTeamMember = json['totalStoresInvitedToJoinAsTeamMember'];
    totalGroupsInvitedToJoinAsGroupMember = json['totalGroupsInvitedToJoinAsGroupMember'];
  }
}