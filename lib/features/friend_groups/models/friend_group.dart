import 'package:perfect_order/core/shared_models/user_friend_group_association.dart';
import '../../../core/shared_models/user.dart';
import '../../../core/shared_models/link.dart';

class FriendGroup {
  late int id;
  late Links links;
  late String name;
  late bool shared;
  late String? emoji;
  late int? usersCount;
  late int? ordersCount;
  late int? storesCount;
  late int? friendsCount;
  late bool canAddFriends;
  late String? description;
  late Attributes attributes;
  late Relationships relationships;

  FriendGroup.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    emoji = json['emoji'];
    shared = json['shared'];
    usersCount = json['usersCount'];
    description = json['description'];
    ordersCount = json['ordersCount'];
    storesCount = json['storesCount'];
    friendsCount = json['friendsCount'];
    canAddFriends = json['canAddFriends'];
    links = Links.fromJson(json['links']);
    attributes = Attributes.fromJson(json['attributes'].runtimeType == List ? {} : json['attributes']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
  }
  
}

class Attributes {
  late UserFriendGroupAssociation? userFriendGroupAssociation;

  Attributes.fromJson(Map<String, dynamic> json) {
    userFriendGroupAssociation = json['userFriendGroupAssociation'] == null ? null : UserFriendGroupAssociation.fromJson(json['userFriendGroupAssociation']);
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
  late Link showFriendGroupOrders;
  late Link inviteMembers;
  late Link acceptInvitationToJoinFriendGroup;
  late Link declineInvitationToJoinFriendGroup;
  late Link removeMembers;
  late Link showMemberFilters;
  late Link showMembers;
  late Link showStoreFilters;
  late Link showStores;
  late Link addStores;
  late Link removeStores;
  late Link showOrderFilters;
  late Link showOrders;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    updateFriendGroup = Link.fromJson(json['updateFriendGroup']);
    deleteFriendGroup = Link.fromJson(json['deleteFriendGroup']);
    inviteMembers = Link.fromJson(json['inviteMembers']);
    acceptInvitationToJoinFriendGroup = Link.fromJson(json['acceptInvitationToJoinFriendGroup']);
    declineInvitationToJoinFriendGroup = Link.fromJson(json['declineInvitationToJoinFriendGroup']);
    removeMembers = Link.fromJson(json['removeMembers']);
    showMemberFilters = Link.fromJson(json['showMemberFilters']);
    showMembers = Link.fromJson(json['showMembers']);
    showStoreFilters = Link.fromJson(json['showStoreFilters']);
    showStores = Link.fromJson(json['showStores']);
    addStores = Link.fromJson(json['addStores']);
    removeStores = Link.fromJson(json['removeStores']);
    showOrderFilters = Link.fromJson(json['showOrderFilters']);
    showOrders = Link.fromJson(json['showOrders']);
  }
}