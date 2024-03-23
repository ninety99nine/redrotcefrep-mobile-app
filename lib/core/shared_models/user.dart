import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'user_friend_group_association.dart';
import 'user_order_view_association.dart';
import 'user_store_association.dart';
import 'mobile_number.dart';
import 'link.dart';

class User {
  late int id;
  late Links links;
  late String? aboutMe;
  late String? lastName;
  late String firstName;
  late bool? isSuperAdmin;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late String? profilePhoto;
  late Attributes attributes;
  late MobileNumber? mobileNumber;
  late Relationships relationships;
  late int? transactionsAsPayerCount;
  late DateTime? mobileNumberVerifiedAt;
  late bool? acceptedTermsAndConditions;
  late int? paidTransactionsAsPayerCount;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    aboutMe = json['aboutMe'];
    lastName = json['lastName'];
    firstName = json['firstName'];
    profilePhoto = json['profilePhoto'];
    isSuperAdmin = json['isSuperAdmin'];
    links = Links.fromJson(json['links']);
    attributes = Attributes.fromJson(json['attributes']);
    transactionsAsPayerCount = json['transactionsAsPayerCount'];
    acceptedTermsAndConditions = json['acceptedTermsAndConditions'];
    paidTransactionsAsPayerCount = json['paidTransactionsAsPayerCount'];
    createdAt = json['createdAt'] == null ? null : DateTime.parse(json['createdAt']);
    updatedAt = json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']);
    mobileNumber = json['mobileNumber'] == null ? null : MobileNumber.fromJson(json['mobileNumber']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
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

class Relationships {
  late Transaction? latestTransactionAsPayer;
  Relationships.fromJson(Map<String, dynamic> json) {
    latestTransactionAsPayer = json['latestTransactionAsPayer'] == null ? null : Transaction.fromJson(json['latestTransactionAsPayer']);
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
  late Link createAiMessagesWhileStreaming; 
  late Link showFriends; 
  late Link createFriends; 
  late Link removeFriends; 
  late Link showLastSelectedFriend; 
  late Link updateLastSelectedFriends; 
  late Link showFriendAndFriendGroupFilters; 

  late Link showFriendGroupFilters; 
  late Link showFirstCreatedFriendGroup; 
  late Link showLastSelectedFriendGroup; 
  late Link updateLastSelectedFriendGroups; 
  late Link deleteManyFriendGroups; 
  late Link checkInvitationsToJoinFriendGroups; 
  late Link acceptAllInvitationsToJoinFriendGroups; 
  late Link declineAllInvitationsToJoinFriendGroups; 
  late Link showFriendGroups; 
  late Link createFriendGroups;

  late Link showOrderFilters; 
  late Link showOrders; 
  late Link showReviewFilters; 
  late Link showReviews; 
  late Link showFirstCreatedStore; 
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
  late Link updateProfilePhoto;
  late Link deleteProfilePhoto;
  late Link showSmsAlert; 
  late Link showSmsAlertTransactions;
  late Link createSmsAlertTransaction;
  late Link calculateSmsAlertTransactionAmount;
  late Link generateSmsAlertPaymentShortcode;

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
    createAiMessagesWhileStreaming = Link.fromJson(json['createAiMessagesWhileStreaming']);
    showFriends = Link.fromJson(json['showFriends']);
    createFriends = Link.fromJson(json['createFriends']);
    removeFriends = Link.fromJson(json['removeFriends']);
    showLastSelectedFriend = Link.fromJson(json['showLastSelectedFriend']);
    updateLastSelectedFriends = Link.fromJson(json['updateLastSelectedFriends']);
    showFriendAndFriendGroupFilters = Link.fromJson(json['showFriendAndFriendGroupFilters']);
    
    showFriendGroupFilters = Link.fromJson(json['showFriendGroupFilters']);
    showFirstCreatedFriendGroup = Link.fromJson(json['showFirstCreatedFriendGroup']);
    showLastSelectedFriendGroup = Link.fromJson(json['showLastSelectedFriendGroup']);
    updateLastSelectedFriendGroups = Link.fromJson(json['updateLastSelectedFriendGroups']);
    deleteManyFriendGroups = Link.fromJson(json['deleteManyFriendGroups']);
    checkInvitationsToJoinFriendGroups = Link.fromJson(json['checkInvitationsToJoinFriendGroups']);
    acceptAllInvitationsToJoinFriendGroups = Link.fromJson(json['acceptAllInvitationsToJoinFriendGroups']);
    declineAllInvitationsToJoinFriendGroups = Link.fromJson(json['declineAllInvitationsToJoinFriendGroups']);
    showFriendGroups = Link.fromJson(json['showFriendGroups']);
    createFriendGroups = Link.fromJson(json['createFriendGroups']);

    showOrderFilters = Link.fromJson(json['showOrderFilters']);
    showOrders = Link.fromJson(json['showOrders']);
    showReviewFilters = Link.fromJson(json['showReviewFilters']);
    showReviews = Link.fromJson(json['showReviews']);
    showFirstCreatedStore = Link.fromJson(json['showFirstCreatedStore']);
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
    updateProfilePhoto = Link.fromJson(json['updateProfilePhoto']);
    deleteProfilePhoto = Link.fromJson(json['deleteProfilePhoto']);
    showSmsAlert = Link.fromJson(json['showSmsAlert']);
    showSmsAlertTransactions = Link.fromJson(json['showSmsAlertTransactions']);
    createSmsAlertTransaction = Link.fromJson(json['createSmsAlertTransaction']);
    calculateSmsAlertTransactionAmount = Link.fromJson(json['calculateSmsAlertTransactionAmount']);
    generateSmsAlertPaymentShortcode = Link.fromJson(json['generateSmsAlertPaymentShortcode']);
  }
}