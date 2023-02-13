import 'mobile_number.dart';
import 'name_description.dart';

class UserAssociationAsFollower {
  late int id;
  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime? lastSeenAt;
  late MobileNumber? mobileNumber;
  late NameAndDescription acceptedInvitation;

  UserAssociationAsFollower.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    acceptedInvitation = NameAndDescription.fromJson(json['acceptedInvitation']);
    lastSeenAt = json['lastSeenAt'] == null ? null : DateTime.parse(json['lastSeenAt']);
    mobileNumber = json['mobileNumber'] == null ? null : MobileNumber.fromJson(json['mobileNumber']);
  }
}