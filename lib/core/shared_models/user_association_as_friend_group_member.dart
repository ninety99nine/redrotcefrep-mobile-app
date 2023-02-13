class UserAssociationAsFriendGroupMember {
  late int id;
  late String role;
  late DateTime createdAt;
  late DateTime updatedAt;

  UserAssociationAsFriendGroupMember.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }
}