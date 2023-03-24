class TeamMemberAccess {
  
  late bool status;
  late String? description;
  late DateTime? expiresAt;

  TeamMemberAccess.fromJson(Map<String, dynamic> json) {

    status = json['status'];
    description = json['description'];
    expiresAt = json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt']);
    
  }

}