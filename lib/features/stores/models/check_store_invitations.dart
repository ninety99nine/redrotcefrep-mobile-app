class CheckStoreInvitations {
  late bool hasInvitations;
  late int totalInvitations;

  CheckStoreInvitations.fromJson(Map<String, dynamic> json) {
    hasInvitations = json['hasInvitations'];
    totalInvitations = json['totalInvitations'];
  }
  
}