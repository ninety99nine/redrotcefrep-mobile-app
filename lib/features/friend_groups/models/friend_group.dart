import 'package:bonako_demo/core/shared_models/user_association_as_friend_group_member.dart';

import '../../../core/shared_models/user.dart';
import '../../../core/shared_models/link.dart';

class FriendGroup {
  late int id;
  late Links links;
  late String name;
  late bool shared;
  late int? usersCount;
  late int? friendsCount;
  late bool canAddFriends;
  late Attributes attributes;
  late Relationships relationships;

  FriendGroup.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shared = json['shared'];
    usersCount = json['usersCount'];
    friendsCount = json['friendsCount'];
    canAddFriends = json['canAddFriends'];
    links = Links.fromJson(json['links']);
    attributes = Attributes.fromJson(json['attributes']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
  }
  
}

class Attributes {
  late UserAssociationAsFriendGroupMember? userAssociationAsFriendGroupMember;

  Attributes.fromJson(Map<String, dynamic> json) {
    userAssociationAsFriendGroupMember = json['userAssociationAsFriendGroupMember'] == null ? null : UserAssociationAsFriendGroupMember.fromJson(json['userAssociationAsFriendGroupMember']);
  }
}

class Relationships {
  late List<User> users;
  Relationships.fromJson(Map<String, dynamic> json) {
    users = json['users'] == null ? [] : (json['users'] as List).map((user) => User.fromJson(user)).toList();
  }
}

class Links {
  late Link self;
  late Link updateFriendGroup;
  late Link deleteFriendGroup;
  late Link showFriendGroupMembers;
  late Link removeFriendGroupMembers;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    updateFriendGroup = Link.fromJson(json['updateFriendGroup']);
    showFriendGroupMembers = Link.fromJson(json['showFriendGroupMembers']);
    removeFriendGroupMembers = Link.fromJson(json['removeFriendGroupMembers']);
  }
}