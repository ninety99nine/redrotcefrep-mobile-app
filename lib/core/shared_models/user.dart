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
  late Link? showOrders;
  late Link? showFriends;
  late Link? createFriends;
  late Link? removeFriends;
  late Link? showAddresses;
  late Link? updateAddress;
  late Link? showFriendMenus;
  late Link? createAddresses;
  late Link? showFriendGroups;
  late Link? createFriendGroups;
  late Link? deleteFriendGroups;
  late Link? showFriendGroupMenus;
  late Link? removeStoreTeamMember;
  late Link? showLastSelectedFriend;
  late Link? showTermsAndConditions;
  late Link? acceptTermsAndConditions;
  late Link? updateLastSelectedFriends;
  late Link? showLastSelectedFriendGroup;
  late Link? updateLastSelectedFriendGroups;
  late Link? updateStoreTeamMemberPermissions;  

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    showOrders = json['showOrders'] == null ? null : Link.fromJson(json['showOrders']);
    showFriends = json['showFriends'] == null ? null : Link.fromJson(json['showFriends']);
    createFriends = json['createFriends'] == null ? null : Link.fromJson(json['createFriends']);
    removeFriends = json['removeFriends'] == null ? null : Link.fromJson(json['removeFriends']);
    showAddresses = json['showAddresses'] == null ? null : Link.fromJson(json['showAddresses']);
    updateAddress = json['updateAddress'] == null ? null : Link.fromJson(json['updateAddress']);
    showFriendMenus = json['showFriendMenus'] == null ? null : Link.fromJson(json['showFriendMenus']);
    createAddresses = json['createAddresses'] == null ? null : Link.fromJson(json['createAddresses']);
    showFriendGroups = json['showFriendGroups'] == null ? null : Link.fromJson(json['showFriendGroups']);
    createFriendGroups = json['createFriendGroups'] == null ? null : Link.fromJson(json['createFriendGroups']);
    deleteFriendGroups = json['deleteFriendGroups'] == null ? null : Link.fromJson(json['deleteFriendGroups']);
    showFriendGroupMenus = json['showFriendGroupMenus'] == null ? null : Link.fromJson(json['showFriendGroupMenus']);
    removeStoreTeamMember = json['removeStoreTeamMember'] == null ? null : Link.fromJson(json['removeStoreTeamMember']);
    showLastSelectedFriend = json['showLastSelectedFriend'] == null ? null : Link.fromJson(json['showLastSelectedFriend']);
    showTermsAndConditions = json['showTermsAndConditions'] == null ? null : Link.fromJson(json['showTermsAndConditions']);
    acceptTermsAndConditions = json['acceptTermsAndConditions'] == null ? null : Link.fromJson(json['acceptTermsAndConditions']);
    updateLastSelectedFriends = json['updateLastSelectedFriends'] == null ? null : Link.fromJson(json['updateLastSelectedFriends']);
    showLastSelectedFriendGroup = json['showLastSelectedFriendGroup'] == null ? null : Link.fromJson(json['showLastSelectedFriendGroup']);
    updateLastSelectedFriendGroups = json['updateLastSelectedFriendGroups'] == null ? null : Link.fromJson(json['updateLastSelectedFriendGroups']);
    updateStoreTeamMemberPermissions = json['updateStoreTeamMemberPermissions'] == null ? null : Link.fromJson(json['updateStoreTeamMemberPermissions']);
  }
}