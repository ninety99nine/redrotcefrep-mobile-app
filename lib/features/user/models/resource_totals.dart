class ResourceTotals {
  late int totalOrders;
  late int totalReviews;
  late int totalNotifications;
  late int totalSmsAlertCredits;
  late int totalStoresAsFollower;
  late int totalStoresAsCustomer;
  late int totalGroupsJoinedAsMember;
  late int totalStoresJoinedAsCreator;
  late int totalStoresAsRecentVisitor;
  late int totalStoresJoinedAsTeamMember;
  late int totalStoresJoinedAsNonCreator;
  late int totalStoresInvitedToJoinAsTeamMember;

  ResourceTotals.fromJson(Map<String, dynamic> json) {
    totalOrders = json['totalOrders'];
    totalReviews = json['totalReviews'];
    totalNotifications = json['totalNotifications'];
    totalSmsAlertCredits = json['totalSmsAlertCredits'];
    totalStoresAsFollower = json['totalStoresAsFollower'];
    totalStoresAsCustomer = json['totalStoresAsCustomer'];
    totalGroupsJoinedAsMember = json['totalGroupsJoinedAsMember'];
    totalStoresJoinedAsCreator = json['totalStoresJoinedAsCreator'];
    totalStoresAsRecentVisitor = json['totalStoresAsRecentVisitor'];
    totalStoresJoinedAsNonCreator = json['totalStoresJoinedAsNonCreator'];
    totalStoresJoinedAsTeamMember = json['totalStoresJoinedAsTeamMember'];
    totalStoresInvitedToJoinAsTeamMember = json['totalStoresInvitedToJoinAsTeamMember'];
  }
}