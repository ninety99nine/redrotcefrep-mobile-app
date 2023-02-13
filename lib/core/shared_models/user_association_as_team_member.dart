import 'permission.dart';
import 'mobile_number.dart';
import 'name_description.dart';

class UserAssociationAsTeamMember {
  late int id;
  late String role;
  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime? lastSeenAt;
  late MobileNumber? mobileNumber;
  late List<Permission> permissions;
  late NameAndDescription acceptedInvitation;

  UserAssociationAsTeamMember.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    acceptedInvitation = NameAndDescription.fromJson(json['acceptedInvitation']);
    lastSeenAt = json['lastSeenAt'] == null ? null : DateTime.parse(json['lastSeenAt']);
    mobileNumber = json['mobileNumber'] == null ? null : MobileNumber.fromJson(json['mobileNumber']);
    permissions = List.from((json['permissions'] as List).map((permission) => Permission.fromJson(permission)).toList());
  }
}