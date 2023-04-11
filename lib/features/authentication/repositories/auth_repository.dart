import 'package:bonako_demo/core/utils/mobile_number.dart';
import '../../api/models/api_home.dart' as api_home;
import '../../api/repositories/api_repository.dart';
import '../../addresses/enums/address_enums.dart';
import '../../api/providers/api_provider.dart';
import '../../../core/shared_models/user.dart';
import '../../api/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../enums/auth_enums.dart';

class AuthRepository {

  /// Before signin, the user is a guest and does not yet exist.
  /// Once login is successful, the user must be set to utilise
  /// user specific methods
  final User? user;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  AuthRepository({ this.user, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Get the Api Home links required to perform requests to using the routes
  api_home.Links get homeApiLinks => apiProvider.apiHome!.links;

  /// Signin using the provided inputs
  Future<http.Response> signin({ required String mobileNumber, required String password, String? passwordConfirmation, String? verificationCode, BuildContext? context }) async {

    final url = homeApiLinks.login;

    final Map<String, String?> body = {
      'mobile_number': mobileNumber,
      'password': password,
    };

    if(passwordConfirmation != null) body['password_confirmation'] = passwordConfirmation;
    if(verificationCode != null) body['verification_code'] = verificationCode;

    return apiRepository.post(url: url, body: body, context: context)
      .then((response) async {
        await ApiService.setBearerTokenFromResponse(response, apiProvider);
        return response;
      });
    
  }

  /// Validate the signup inputs 
  Future<http.Response> validateSignup({ required String firstName, required String lastName, required String mobileNumber, required String password, String? passwordConfirmation, BuildContext? context }) async {

    final url = homeApiLinks.validateRegister;

    final Map<String, String?> body = {
      'password_confirmation': passwordConfirmation,
      'mobile_number': mobileNumber,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Signup using the provided inputs
  Future<http.Response> signup({ required String firstName, required String lastName, required String mobileNumber, required String password, String? passwordConfirmation, required String verificationCode, BuildContext? context }) async {

    final url = homeApiLinks.register;

    final Map<String, String?> body = {
      'password_confirmation': passwordConfirmation,
      'verification_code': verificationCode,
      'mobile_number': mobileNumber,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
    };

    return apiRepository.post(url: url, body: body, context: context)
      .then((response) async {
        await ApiService.setBearerTokenFromResponse(response, apiProvider);
        return response;
      });
    
  }

  /// Validate the reset password inputs 
  Future<http.Response> validateResetPassword({ required String password, String? passwordConfirmation, BuildContext? context }) async {

    final url = homeApiLinks.validateResetPassword;

    final Map<String, String?> body = {
      'password_confirmation': passwordConfirmation,
      'password': password,
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Reset password using the provided inputs
  Future<http.Response> resetPassword({ required String mobileNumber, required String password, required String passwordConfirmation, required String verificationCode, BuildContext? context }) async {

    final url = homeApiLinks.resetPassword;

    final Map<String, String?> body = {
      'password_confirmation': passwordConfirmation,
      'verification_code': verificationCode,
      'mobile_number': mobileNumber,
      'password': password,
    };

    return apiRepository.post(url: url, body: body, context: context)
      .then((response) async {
        await ApiService.setBearerTokenFromResponse(response, apiProvider);
        return response;
      });
    
  }

  /// Generate the mobile verification code to use for signin
  Future<http.Response> generateMobileVerificationCodeForSignin({ required String mobileNumber, BuildContext? context  }) async {

    return generateMobileVerificationCode(
      mobileNumber: mobileNumber, 
      purpose: 'Verify Account',
      context: context
    );
    
  }

  /// Generate the mobile verification code to use for signup
  Future<http.Response> generateMobileVerificationCodeForSignup({ required String mobileNumber, BuildContext? context  }) async {

    return generateMobileVerificationCode(
      mobileNumber: mobileNumber, 
      purpose: 'Verify Account',
      context: context
    );
    
  }

  /// Generate the mobile verification code to use for reset password
  Future<http.Response> generateMobileVerificationCodeForResetPassword({ required String mobileNumber, BuildContext? context  }) async {

    return generateMobileVerificationCode(
      mobileNumber: mobileNumber, 
      purpose: 'Reset Password',
      context: context
    );
    
  }

  /// Generate the mobile verification code
  Future<http.Response> generateMobileVerificationCode({ required String mobileNumber, required String purpose, BuildContext? context }) async {

    final url = homeApiLinks.generateMobileVerificationCode;

    final Map<String, String?> body = {
      'mobile_number': mobileNumber,
      'purpose': purpose,
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Check if an account matching the provided mobile number exists
  Future<http.Response> checkIfMobileAccountExists({ required String? mobileNumber, BuildContext? context }){
    
    final url = homeApiLinks.accountExists;

    final body = {
      'mobile_number': mobileNumber
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Update the specified user
  Future<http.Response> updateUser({ String? firstName, String? lastName, String? nickName, bool? anonymous }) {

    if(user == null) throw Exception('An authenticated user is required to update');

    String url = user!.links.updateUser.href;

    Map body = {};
    if((firstName ?? '').isNotEmpty) body.addAll({'first_name': firstName});
    if((lastName ?? '').isNotEmpty) body.addAll({'last_name': lastName});
    if((nickName ?? '').isNotEmpty) body.addAll({'nick_name': nickName});
    if(anonymous != null) body.addAll({'anonymous': anonymous});

    return apiRepository.put(url: url, body: body);
    
  }

  /// Show friend menus
  Future<http.Response> showFriendMenus({ BuildContext? context }){
    
    if(user == null) throw Exception('An authenticated user is required to show friend menus'); 
    
    final url =  user!.links.showFriendMenus.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Show friends
  Future<http.Response> showFriends({ int? page = 1, BuildContext? context }){
    
    if(user == null) throw Exception('An authenticated user is required to show friends'); 
    
    final url =  user!.links.showFriends.href;

    return apiRepository.get(url: url, page: page, context: context);
    
  }

  /// Create friends
  Future<http.Response> createFriends({ required List<String> mobileNumbers, BuildContext? context }) {

    if(user == null) throw Exception('An authenticated user is required to show friends'); 
    
    final url =  user!.links.showFriends.href;

    Map body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList()
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Remove friends
  Future<http.Response> removeFriends({ required List<User> friends, BuildContext? context }) {

    if(user == null) throw Exception('An authenticated user is required to remove the friends');

    String url = user!.links.removeFriends.href;

    List<String> mobileNumbers = friends.map((friend) {
        return friend.mobileNumber!.withExtension;
    }).toList();
    
    Map body = {
      'mobile_numbers': mobileNumbers,
    };

    return apiRepository.delete(url: url, body: body, context: context);
    
  }
  
  /// Show last selected friend
  Future<http.Response> showLastSelectedFriend({ BuildContext? context }) {

    final url = user!.links.showLastSelectedFriend.href;

    return apiRepository.get(url: url, context: context);
  
  }

  /// Update last selected friend groups
  Future<http.Response> updateLastSelectedFriends({ required List<User> friends, BuildContext? context }) {

    final url = user!.links.updateLastSelectedFriends.href;

    List<int> friendUserIds = friends.map((friend) {
        return friend.id;
    }).toList();
    
    Map body = {
      'friend_user_ids': friendUserIds,
    };

    return apiRepository.put(url: url, body: body, context: context);
    
  }

  /// Logout
  Future<http.Response> logout({ LogoutType logoutType = LogoutType.everyone, BuildContext? context }) {

    if(user == null) throw Exception('An authenticated user is required to logout'); 
    
    final url =  homeApiLinks.logout;

    final body = {};
    if(logoutType == LogoutType.everyone) body.addAll({'everyone': true});
    if(logoutType == LogoutType.others) body.addAll({'others': true});

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Show the terms and conditions
  Future<http.Response> showTermsAndConditions({ BuildContext? context }) {

    if(user == null) throw Exception('An authenticated user is required to show the terms and conditions'); 
    
    final url =  user!.links.showTermsAndConditions.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Accept the terms and conditions
  Future<http.Response> acceptTermsAndConditions({ BuildContext? context }) {

    if(user == null) throw Exception('An authenticated user is required to accept the terms and conditions'); 
    
    final url =  user!.links.acceptTermsAndConditions.href;

    final body = {
      'accept': true
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Show the user addresses
  Future<http.Response> showAddresses({ List<AddressType> types = const [], int? page = 1, BuildContext? context }){

    if(user == null) throw Exception('An authenticated user is required to show addresses');

    String url =  user!.links.showAddresses.href;

    Map<String, String> queryParams = {
      'types': types.map((type) => type.name).join(',')
    };

    return apiRepository.get(url: url, page: page, queryParams: queryParams, context: context);
    
  }
}