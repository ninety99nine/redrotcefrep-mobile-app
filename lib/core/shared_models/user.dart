import 'user_association_as_friend_group_member.dart';
import 'user_association_as_order_viewer.dart';
import 'user_and_store_association.dart';
import 'mobile_number.dart';
import 'link.dart';

class User {
  late int id;
  late Links links;
  late String lastName;
  late String firstName;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late Attributes attributes;
  late MobileNumber? mobileNumber;
  late DateTime? mobileNumberVerifiedAt;
  late bool? acceptedTermsAndConditions;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lastName = json['lastName'];
    firstName = json['firstName'];
    links = Links.fromJson(json['links']);
    attributes = Attributes.fromJson(json['attributes']);
    acceptedTermsAndConditions = json['acceptedTermsAndConditions'];
    createdAt = json['createdAt'] == null ? null : DateTime.parse(json['createdAt']);
    updatedAt = json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']);
    mobileNumber = json['mobileNumber'] == null ? null : MobileNumber.fromJson(json['mobileNumber']);
    mobileNumberVerifiedAt = json['mobileNumberVerifiedAt'] == null ? null : DateTime.parse(json['mobileNumberVerifiedAt']);
  }
}

class Attributes {
  late String name;
  late bool requiresPassword;
  late UserAndStoreAssociation? userAndStoreAssociation;
  late UserAssociationAsOrderViewer? userAssociationAsOrderViewer;
  late UserAssociationAsFriendGroupMember? userAssociationAsFriendGroupMember;

  Attributes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    requiresPassword = json['requiresPassword'];
    userAndStoreAssociation = json['userAndStoreAssociation'] == null ? null : UserAndStoreAssociation.fromJson(json['userAndStoreAssociation']);
    userAssociationAsOrderViewer = json['userAssociationAsOrderViewer'] == null ? null : UserAssociationAsOrderViewer.fromJson(json['userAssociationAsOrderViewer']);
    userAssociationAsFriendGroupMember = json['userAssociationAsFriendGroupMember'] == null ? null : UserAssociationAsFriendGroupMember.fromJson(json['userAssociationAsFriendGroupMember']);
  }
}

class Links {
  late Link self;
  late Link showOrders;
  late Link showFriends;
  late Link createFriends;
  late Link removeFriends;
  late Link showAddresses;
  //  late Link updateAddress;
  late Link showFriendMenus;
  late Link createAddresses;
  late Link showOrderFilters;
  late Link showFriendGroups;
  late Link createFriendGroups;
  late Link deleteFriendGroups;
  late Link showFriendGroupMenus;
  late Link showLastSelectedFriend;
  late Link showTermsAndConditions;
  late Link acceptTermsAndConditions;
  late Link updateLastSelectedFriends;
  late Link showLastSelectedFriendGroup;
  late Link updateLastSelectedFriendGroups;
  late Link? showStoreTeamMemberPermissions;  
  late Link? updateStoreTeamMemberPermissions;  

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    showOrders = Link.fromJson(json['showOrders']);
    showFriends = Link.fromJson(json['showFriends']);
    createFriends = Link.fromJson(json['createFriends']);
    removeFriends = Link.fromJson(json['removeFriends']);
    showAddresses = Link.fromJson(json['showAddresses']);
    //  updateAddress = Link.fromJson(json['updateAddress']);
    showFriendMenus = Link.fromJson(json['showFriendMenus']);
    createAddresses = Link.fromJson(json['createAddresses']);
    showOrderFilters = Link.fromJson(json['showOrderFilters']);
    showFriendGroups = Link.fromJson(json['showFriendGroups']);
    createFriendGroups = Link.fromJson(json['createFriendGroups']);
    deleteFriendGroups = Link.fromJson(json['deleteFriendGroups']);
    showFriendGroupMenus = Link.fromJson(json['showFriendGroupMenus']);
    showLastSelectedFriend = Link.fromJson(json['showLastSelectedFriend']);
    showTermsAndConditions = Link.fromJson(json['showTermsAndConditions']);
    acceptTermsAndConditions = Link.fromJson(json['acceptTermsAndConditions']);
    updateLastSelectedFriends = Link.fromJson(json['updateLastSelectedFriends']);
    showLastSelectedFriendGroup = Link.fromJson(json['showLastSelectedFriendGroup']);
    updateLastSelectedFriendGroups = Link.fromJson(json['updateLastSelectedFriendGroups']);
    showStoreTeamMemberPermissions = json['showStoreTeamMemberPermissions'] == null ? null : Link.fromJson(json['showStoreTeamMemberPermissions']);
    updateStoreTeamMemberPermissions = json['updateStoreTeamMemberPermissions'] == null ? null : Link.fromJson(json['updateStoreTeamMemberPermissions']);
  }
}