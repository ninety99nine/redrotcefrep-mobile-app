import 'user_friend_group_association.dart';
import 'user_order_view_association.dart';
import 'user_store_association.dart';
import 'mobile_number.dart';
import 'link.dart';

class User {
  late int id;
  late Links links;
  late String lastName;
  late String firstName;
  late bool? isSuperAdmin;
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
    isSuperAdmin = json['isSuperAdmin'];
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
  late String mobileNumberShortcode;
  late UserStoreAssociation? userStoreAssociation;
  late UserOrderViewAssociation? userOrderViewAssociation;
  late UserFriendGroupAssociation? userFriendGroupAssociation;

  Attributes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    requiresPassword = json['requiresPassword'];
    mobileNumberShortcode = json['mobileNumberShortcode'];
    userStoreAssociation = json['userStoreAssociation'] == null ? null : UserStoreAssociation.fromJson(json['userStoreAssociation']);
    userOrderViewAssociation = json['userOrderViewAssociation'] == null ? null : UserOrderViewAssociation.fromJson(json['userOrderViewAssociation']);
    userFriendGroupAssociation = json['userFriendGroupAssociation'] == null ? null : UserFriendGroupAssociation.fromJson(json['userFriendGroupAssociation']);
  }
}

class Links {
  late Link self; 
  late Link updateUser; 
  late Link deleteUser; 
  late Link confirmDeleteUser; 
  late Link logout; 
  late Link showTokens; 
  late Link showTermsAndConditions; 
  late Link acceptTermsAndConditions; 
  late Link showAddresses; 
  late Link createAddresses; 
  late Link showAiMessages;
  late Link showAiAssistant;
  late Link generateAiAssistantPaymentShortcode;
  late Link createAiMessages; 
  late Link showFriends; 
  late Link createFriends; 
  late Link removeFriends; 
  late Link showLastSelectedFriend; 
  late Link updateLastSelectedFriends; 
  late Link showFriendAndFriendGroupFilters; 
  late Link showFriendGroups; 
  late Link createFriendGroups; 
  late Link deleteManyFriendGroups; 
  late Link showFriendGroupFilters; 
  late Link showLastSelectedFriendGroup; 
  late Link updateLastSelectedFriendGroups; 
  late Link showOrderFilters; 
  late Link showOrders; 
  late Link showStoreFilters; 
  late Link createStores; 
  late Link showStores; 
  late Link joinStores; 
  late Link showNotificationFilters; 
  late Link showNotifications;
  late Link countNotifications; 
  late Link markNotificationsAsRead; 
  late Link? showStoreTeamMember; 
  late Link? showStoreTeamMemberPermissions; 
  late Link? updateStoreTeamMemberPermissions; 
  late Link? showStoreCustomer; 
  late Link showResourceTotals;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    updateUser = Link.fromJson(json['updateUser']);
    deleteUser = Link.fromJson(json['deleteUser']);
    confirmDeleteUser = Link.fromJson(json['confirmDeleteUser']);
    logout = Link.fromJson(json['logout']);
    showTokens = Link.fromJson(json['showTokens']);
    showTermsAndConditions = Link.fromJson(json['showTermsAndConditions']);
    acceptTermsAndConditions = Link.fromJson(json['acceptTermsAndConditions']);
    showAddresses = Link.fromJson(json['showAddresses']);
    createAddresses = Link.fromJson(json['createAddresses']);
    showAiMessages = Link.fromJson(json['showAiMessages']);
    showAiAssistant = Link.fromJson(json['showAiAssistant']);
    generateAiAssistantPaymentShortcode = Link.fromJson(json['generateAiAssistantPaymentShortcode']);
    createAiMessages = Link.fromJson(json['createAiMessages']);
    showFriends = Link.fromJson(json['showFriends']);
    createFriends = Link.fromJson(json['createFriends']);
    removeFriends = Link.fromJson(json['removeFriends']);
    showLastSelectedFriend = Link.fromJson(json['showLastSelectedFriend']);
    updateLastSelectedFriends = Link.fromJson(json['updateLastSelectedFriends']);
    showFriendAndFriendGroupFilters = Link.fromJson(json['showFriendAndFriendGroupFilters']);
    showFriendGroups = Link.fromJson(json['showFriendGroups']);
    createFriendGroups = Link.fromJson(json['createFriendGroups']);
    deleteManyFriendGroups = Link.fromJson(json['deleteManyFriendGroups']);
    showFriendGroupFilters = Link.fromJson(json['showFriendGroupFilters']);
    showLastSelectedFriendGroup = Link.fromJson(json['showLastSelectedFriendGroup']);
    updateLastSelectedFriendGroups = Link.fromJson(json['updateLastSelectedFriendGroups']);
    showOrderFilters = Link.fromJson(json['showOrderFilters']);
    showOrders = Link.fromJson(json['showOrders']);
    showStoreFilters = Link.fromJson(json['showStoreFilters']);
    createStores = Link.fromJson(json['createStores']);
    showStores = Link.fromJson(json['showStores']);
    joinStores = Link.fromJson(json['joinStores']);
    showNotifications = Link.fromJson(json['showNotifications']);
    countNotifications = Link.fromJson(json['countNotifications']);
    markNotificationsAsRead = Link.fromJson(json['markNotificationsAsRead']);
    showNotificationFilters = Link.fromJson(json['showNotificationFilters']);
    showStoreTeamMember = json['showStoreTeamMember'] == null ? null : Link.fromJson(json['showStoreTeamMember']);
    showStoreTeamMemberPermissions = json['showStoreTeamMemberPermissions'] == null ? null : Link.fromJson(json['showStoreTeamMemberPermissions']);
    updateStoreTeamMemberPermissions = json['updateStoreTeamMemberPermissions'] == null ? null : Link.fromJson(json['updateStoreTeamMemberPermissions']);
    showStoreCustomer = json['showStoreCustomer'] == null ? null : Link.fromJson(json['showStoreCustomer']);
    showResourceTotals = Link.fromJson(json['showResourceTotals']);
  }
}