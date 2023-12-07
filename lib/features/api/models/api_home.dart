import '../../../../core/shared_models/user.dart';

class ApiHome {

  User? user;
  late Links links;
  late bool authenticated;
  late bool acceptedTermsAndConditions;
  late String mobileVerificationShortcode;

  ApiHome.fromJson(Map<String, dynamic> json) {
    authenticated = json['authenticated'];
    links = Links.fromJson(json['links']);
    acceptedTermsAndConditions = json['acceptedTermsAndConditions'];
    user = json['user'] == null ? null : User.fromJson(json['user']);
    mobileVerificationShortcode = json['mobileVerificationShortcode'];
  }
  
}

class Links {
  late String login;
  late String register;
  late String showStores;
  late String createStores;
  late String accountExists;
  late String resetPassword;
  late String showOccasions;
  late String showBrandStores;
  late String showSearchStores;
  late String validateRegister;
  late String showSearchFilters;
  late String showSearchFriends;
  late String showPaymentMethods;
  late String showInfluencerStores;
  late String validateResetPassword;
  late String showSearchFriendGroups;
  late String showAiMessageCategories;
  late String searchUserByMobileNumber;
  late String checkInvitationsToFollowStores;
  late String updateAssignedStoresArrangement;
  late String checkInvitationsToJoinTeamStores;
  late String acceptAllInvitationsToFollowStores;
  late String declineAllInvitationsToFollowStores;
  late String acceptAllInvitationsToJoinTeamStores;
  late String declineAllInvitationsToJoinTeamStores;

  Links.fromJson(Map<String, dynamic> json) {
    login = json['login'];
    register = json['register'];
    showStores = json['showStores'];
    createStores = json['createStores'];
    accountExists = json['accountExists'];
    resetPassword = json['resetPassword'];
    showOccasions = json['showOccasions'];
    showBrandStores = json['showBrandStores'];
    showSearchStores = json['showSearchStores'];
    validateRegister = json['validateRegister'];
    showSearchFilters = json['showSearchFilters'];
    showSearchFriends = json['showSearchFriends'];
    showPaymentMethods = json['showPaymentMethods'];
    showInfluencerStores = json['showInfluencerStores'];
    validateResetPassword = json['validateResetPassword'];
    showSearchFriendGroups = json['showSearchFriendGroups'];
    showAiMessageCategories = json['showAiMessageCategories'];
    searchUserByMobileNumber = json['searchUserByMobileNumber'];
    checkInvitationsToFollowStores = json['checkInvitationsToFollowStores'];
    updateAssignedStoresArrangement = json['updateAssignedStoresArrangement'];
    checkInvitationsToJoinTeamStores = json['checkInvitationsToJoinTeamStores'];
    acceptAllInvitationsToFollowStores = json['acceptAllInvitationsToFollowStores'];
    declineAllInvitationsToFollowStores = json['declineAllInvitationsToFollowStores'];
    acceptAllInvitationsToJoinTeamStores = json['acceptAllInvitationsToJoinTeamStores'];
    declineAllInvitationsToJoinTeamStores = json['declineAllInvitationsToJoinTeamStores'];
  }

}
