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
  late String logout;
  late String register;
  late String showStores;
  late String createStores;
  late String accountExists;
  late String resetPassword;
  late String showSearchMenus;
  late String showSearchStores;
  late String validateRegister;
  late String showSearchFriends;
  late String validateResetPassword;
  late String showSearchFriendGroups;
  late String showAllTeamMemberPermissions;
  late String verifyMobileVerificationCode;
  late String generateMobileVerificationCode;
  late String storesCheckInvitationsToFollow;
  late String storesCheckInvitationsToJoinTeam;
  late String storesAcceptAllInvitationsToFollow;
  late String storesDeclineAllInvitationsToFollow;
  late String storesAcceptAllInvitationsToJoinTeam;
  late String storesDeclineAllInvitationsToJoinTeam;

  Links.fromJson(Map<String, dynamic> json) {
    login = json['login'];
    logout = json['logout'];
    register = json['register'];
    showStores = json['showStores'];
    createStores = json['createStores'];
    accountExists = json['accountExists'];
    resetPassword = json['resetPassword'];
    showSearchMenus = json['showSearchMenus'];
    showSearchStores = json['showSearchStores'];
    validateRegister = json['validateRegister'];
    showSearchFriends = json['showSearchFriends'];
    validateResetPassword = json['validateResetPassword'];
    showSearchFriendGroups = json['showSearchFriendGroups'];
    showAllTeamMemberPermissions = json['showAllTeamMemberPermissions'];
    verifyMobileVerificationCode = json['verifyMobileVerificationCode'];
    generateMobileVerificationCode = json['generateMobileVerificationCode'];
    storesCheckInvitationsToFollow = json['storesCheckInvitationsToFollow'];
    storesCheckInvitationsToJoinTeam = json['storesCheckInvitationsToJoinTeam'];
    storesAcceptAllInvitationsToFollow = json['storesAcceptAllInvitationsToFollow'];
    storesDeclineAllInvitationsToFollow = json['storesDeclineAllInvitationsToFollow'];
    storesAcceptAllInvitationsToJoinTeam = json['storesAcceptAllInvitationsToJoinTeam'];
    storesDeclineAllInvitationsToJoinTeam = json['storesDeclineAllInvitationsToJoinTeam'];
  }

}
