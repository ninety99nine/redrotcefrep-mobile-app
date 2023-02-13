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
  late String stores;
  late String register;
  late String accountExists;
  late String resetPassword;
  late String validateRegister;
  late String validateResetPassword;
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
    stores = json['stores'];
    register = json['register'];
    accountExists = json['accountExists'];
    resetPassword = json['resetPassword'];
    validateRegister = json['validateRegister'];
    validateResetPassword = json['validateResetPassword'];
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
