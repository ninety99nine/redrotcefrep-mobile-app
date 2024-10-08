import 'package:perfect_order/core/shared_models/mobile_number.dart';

class UserFriendGroupAssociation {
  late int id;
  late String role;
  late String status;
  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime? lastSelectedAt;
  late int? invitedToJoinByUserId;
  late MobileNumber? mobileNumber;

  late bool isGuest;
  late bool isAdmin;
  late bool isCreator;
  late bool isCreatorOrAdmin;
  late bool isUserWhoHasLeft;
  late bool isUserWhoHasJoined;
  late bool isUserWhoIsInvited;
  late bool isUserWhoHasDeclined;

  UserFriendGroupAssociation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    status = json['status'];
    isGuest = json['isGuest'];
    isAdmin = json['isAdmin'];
    isCreator = json['isCreator'];
    isCreatorOrAdmin = json['isCreatorOrAdmin'];
    isUserWhoHasLeft = json['isUserWhoHasLeft'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    isUserWhoHasJoined = json['isUserWhoHasJoined'];
    isUserWhoIsInvited = json['isUserWhoIsInvited'];
    isUserWhoHasDeclined = json['isUserWhoHasDeclined'];
    invitedToJoinByUserId = json['invitedToJoinByUserId'];
    lastSelectedAt = json['lastSelectedAt'] == null ? null : DateTime.parse(json['lastSelectedAt']);
    mobileNumber = json['mobileNumber'] == null ? null : MobileNumber.fromJson(json['mobileNumber']);
  }
}