class ResourceTotals {
  late int totalReviews;
  late int totalNotifications;
  late int totalSmsAlertCredits;
  late int totalOrdersAsCustomer;
  late int totalStoresAsFollower;
  late int totalStoresAsCustomer;
  late int totalOrdersAsTeamMember;
  late int totalUnreadNotifications;
  late int totalReviewsAsTeamMember;
  late int totalOrdersAsCustomerOrFriend;

  late int totalGroupsJoined;
  late int totalGroupsJoinedAsCreator;
  late int totalGroupsJoinedAsNonCreator;
  late int totalGroupsInvitedToJoinAsGroupMember;

  late int totalStoresJoinedAsCreator;
  late int totalStoresAsRecentVisitor;
  late int totalStoresJoinedAsTeamMember;
  late int totalStoresJoinedAsNonCreator;
  late int totalStoresInvitedToJoinAsTeamMember;

  ResourceTotals.fromJson(Map<String, dynamic> json) {
    totalReviews = json['totalReviews'];
    totalNotifications = json['totalNotifications'];
    totalSmsAlertCredits = json['totalSmsAlertCredits'];
    totalOrdersAsCustomer = json['totalOrdersAsCustomer'];
    totalStoresAsFollower = json['totalStoresAsFollower'];
    totalStoresAsCustomer = json['totalStoresAsCustomer'];
    totalOrdersAsTeamMember = json['totalOrdersAsTeamMember'];
    totalUnreadNotifications = json['totalUnreadNotifications'];
    totalReviewsAsTeamMember = json['totalReviewsAsTeamMember'];
    totalOrdersAsCustomerOrFriend = json['totalOrdersAsCustomerOrFriend'];

    totalGroupsJoined = json['totalGroupsJoined'];
    totalGroupsJoinedAsCreator = json['totalGroupsJoinedAsCreator'];
    totalGroupsJoinedAsNonCreator = json['totalGroupsJoinedAsNonCreator'];
    totalGroupsInvitedToJoinAsGroupMember = json['totalGroupsInvitedToJoinAsGroupMember'];

    totalStoresJoinedAsCreator = json['totalStoresJoinedAsCreator'];
    totalStoresAsRecentVisitor = json['totalStoresAsRecentVisitor'];
    totalStoresJoinedAsTeamMember = json['totalStoresJoinedAsTeamMember'];
    totalStoresJoinedAsNonCreator = json['totalStoresJoinedAsNonCreator'];
    totalStoresInvitedToJoinAsTeamMember = json['totalStoresInvitedToJoinAsTeamMember'];
  }
}