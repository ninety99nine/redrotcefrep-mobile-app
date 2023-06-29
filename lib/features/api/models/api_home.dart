import '../../../../core/shared_models/user.dart';

class ApiHome {

  User? user;
  late Links links;
  late bool authenticated;
  late bool acceptedTermsAndConditions;

  ApiHome.fromJson(Map<String, dynamic> json) {
    authenticated = json['authenticated'];
    links = Links.fromJson(json['links']);
    acceptedTermsAndConditions = json['acceptedTermsAndConditions'];
    user = json['user'] == null ? null : User.fromJson(json['user']);
  }
  
}

class Links {
  late String login;
  late String register;
  late String showStores;
  late String createStores;
  late String accountExists;
  late String resetPassword;
  late String paymentMethods;
  late String showBrandStores;
  late String showSearchStores;
  late String validateRegister;
  late String showSearchFilters;
  late String showSearchFriends;
  late String showInfluencerStores;
  late String showStoreGoldenRules;
  late String validateResetPassword;
  late String showSearchFriendGroups;
  late String verifyMobileVerificationCode;
  late String generateMobileVerificationCode;
  late String checkInvitationsToFollowStores;
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
    paymentMethods = json['paymentMethods'];
    showBrandStores = json['showBrandStores'];
    showSearchStores = json['showSearchStores'];
    validateRegister = json['validateRegister'];
    showSearchFilters = json['showSearchFilters'];
    showSearchFriends = json['showSearchFriends'];
    showInfluencerStores = json['showInfluencerStores'];
    showStoreGoldenRules = json['showStoreGoldenRules'];
    validateResetPassword = json['validateResetPassword'];
    showSearchFriendGroups = json['showSearchFriendGroups'];
    verifyMobileVerificationCode = json['verifyMobileVerificationCode'];
    generateMobileVerificationCode = json['generateMobileVerificationCode'];
    checkInvitationsToFollowStores = json['checkInvitationsToFollowStores'];
    checkInvitationsToJoinTeamStores = json['checkInvitationsToJoinTeamStores'];
    acceptAllInvitationsToFollowStores = json['acceptAllInvitationsToFollowStores'];
    declineAllInvitationsToFollowStores = json['declineAllInvitationsToFollowStores'];
    acceptAllInvitationsToJoinTeamStores = json['acceptAllInvitationsToJoinTeamStores'];
    declineAllInvitationsToJoinTeamStores = json['declineAllInvitationsToJoinTeamStores'];
  }

}
