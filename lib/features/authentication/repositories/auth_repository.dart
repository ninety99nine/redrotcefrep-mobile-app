import 'package:bonako_demo/core/utils/mobile_number.dart';
import '../../api/models/api_home.dart' as api_home;
import '../../api/repositories/api_repository.dart';
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
  Future<http.Response> signin({ required String mobileNumber, required String password, String? passwordConfirmation, String? verificationCode }) async {

    final url = homeApiLinks.login;

    final Map<String, String?> body = {
      'mobile_number': mobileNumber,
      'password': password,
    };

    if(passwordConfirmation != null) body['password_confirmation'] = passwordConfirmation;
    if(verificationCode != null) body['verification_code'] = verificationCode;

    return apiRepository.post(url: url, body: body)
      .then((response) async {
        await ApiService.setBearerTokenFromResponse(response, apiProvider);
        return response;
      });
    
  }

  /// Validate the signup inputs 
  Future<http.Response> validateSignup({ required String firstName, required String lastName, required String mobileNumber, required String password, String? passwordConfirmation }) async {

    final url = homeApiLinks.validateRegister;

    final Map<String, String?> body = {
      'password_confirmation': passwordConfirmation,
      'mobile_number': mobileNumber,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Signup using the provided inputs
  Future<http.Response> signup({ required String firstName, required String lastName, required String mobileNumber, required String password, String? passwordConfirmation, required String verificationCode }) async {

    final url = homeApiLinks.register;

    final Map<String, String?> body = {
      'password_confirmation': passwordConfirmation,
      'verification_code': verificationCode,
      'mobile_number': mobileNumber,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
    };

    return apiRepository.post(url: url, body: body)
      .then((response) async {
        await ApiService.setBearerTokenFromResponse(response, apiProvider);
        return response;
      });
    
  }

  /// Validate the reset password inputs 
  Future<http.Response> validateResetPassword({ required String password, String? passwordConfirmation }) async {

    final url = homeApiLinks.validateResetPassword;

    final Map<String, String?> body = {
      'password_confirmation': passwordConfirmation,
      'password': password,
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Reset password using the provided inputs
  Future<http.Response> resetPassword({ required String mobileNumber, required String password, required String passwordConfirmation, required String verificationCode }) async {

    final url = homeApiLinks.resetPassword;

    final Map<String, String?> body = {
      'password_confirmation': passwordConfirmation,
      'verification_code': verificationCode,
      'mobile_number': mobileNumber,
      'password': password,
    };

    return apiRepository.post(url: url, body: body)
      .then((response) async {
        await ApiService.setBearerTokenFromResponse(response, apiProvider);
        return response;
      });
    
  }

  /// Check if an account matching the provided mobile number exists
  Future<http.Response> checkIfMobileAccountExists({ required String? mobileNumber }){
    
    final url = homeApiLinks.accountExists;

    final body = {
      'mobile_number': mobileNumber
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Update the specified user
  Future<http.Response> updateUser({ String? firstName, String? lastName }) {

    if(user == null) throw Exception('An authenticated user is required to update');

    String url = user!.links.updateUser.href;

    Map body = {};
    if((firstName ?? '').isNotEmpty) body.addAll({'first_name': firstName});
    if((lastName ?? '').isNotEmpty) body.addAll({'last_name': lastName});

    return apiRepository.put(url: url, body: body);
    
  }

  /// Show friend and friend group filters
  Future<http.Response> showFriendAndFriendGroupFilters(){
    
    if(user == null) throw Exception('An authenticated user is required to show the friend and friend group filters'); 
    
    final url =  user!.links.showFriendAndFriendGroupFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Show friends
  Future<http.Response> showFriends({ int? page = 1 }){
    
    if(user == null) throw Exception('An authenticated user is required to show friends'); 
    
    final url =  user!.links.showFriends.href;

    return apiRepository.get(url: url, page: page);
    
  }

  /// Create friends
  Future<http.Response> createFriends({ required List<String> mobileNumbers }) {

    if(user == null) throw Exception('An authenticated user is required to show friends'); 
    
    final url =  user!.links.showFriends.href;

    Map body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList()
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Remove friends
  Future<http.Response> removeFriends({ required List<User> friends }) {

    if(user == null) throw Exception('An authenticated user is required to remove the friends');

    String url = user!.links.removeFriends.href;

    List<String> mobileNumbers = friends.map((friend) {
        return friend.mobileNumber!.withExtension;
    }).toList();
    
    Map body = {
      'mobile_numbers': mobileNumbers,
    };

    return apiRepository.delete(url: url, body: body);
    
  }
  
  /// Show last selected friend
  Future<http.Response> showLastSelectedFriend() {

    final url = user!.links.showLastSelectedFriend.href;

    return apiRepository.get(url: url);
  
  }

  /// Update last selected friend groups
  Future<http.Response> updateLastSelectedFriends({ required List<User> friends }) {

    final url = user!.links.updateLastSelectedFriends.href;

    List<int> friendUserIds = friends.map((friend) {
        return friend.id;
    }).toList();
    
    Map body = {
      'friend_user_ids': friendUserIds,
    };

    return apiRepository.put(url: url, body: body);
    
  }
  
  /// Show resource totals
  Future<http.Response> showResourceTotals() {

    final url = user!.links.showResourceTotals.href;

    return apiRepository.get(url: url);
  
  }

  /// Logout
  Future<http.Response> logout({ LogoutType logoutType = LogoutType.everyone }) {

    if(user == null) throw Exception('An authenticated user is required to logout'); 
    
    final url =  user!.links.logout.href;

    final body = {};
    if(logoutType == LogoutType.everyone) body.addAll({'everyone': true});
    if(logoutType == LogoutType.others) body.addAll({'others': true});

    return apiRepository.post(url: url, body: body);
    
  }

  /// Show the terms and conditions
  Future<http.Response> showTermsAndConditions() {

    if(user == null) throw Exception('An authenticated user is required to show the terms and conditions'); 
    
    final url =  user!.links.showTermsAndConditions.href;

    return apiRepository.get(url: url);
    
  }

  /// Accept the terms and conditions
  Future<http.Response> acceptTermsAndConditions() {

    if(user == null) throw Exception('An authenticated user is required to accept the terms and conditions'); 
    
    final url =  user!.links.acceptTermsAndConditions.href;

    final body = {
      'accept': true
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Show notification filters
  Future<http.Response> showNotificationFilters() {
    
    if(user == null) throw Exception('An authenticated user is required to show the notification filters'); 
    
    final url =  user!.links.showNotificationFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Show notifications
  Future<http.Response> showNotifications({ String? filter, int? page = 1 }) {
    
    if(user == null) throw Exception('An authenticated user is required to show the notifications'); 
    
    final url =  user!.links.showNotifications.href;

    Map<String, String> queryParams = {};

    /// Filter notifications by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Show notification filters
  Future<http.Response> countNotifications() {
    
    if(user == null) throw Exception('An authenticated user is required to count the notifications'); 
    
    final url =  user!.links.countNotifications.href;

    return apiRepository.get(url: url);
    
  }

  /// Mark notifications as read
  Future<http.Response> markNotificationsAsRead({ required List<String> mobileNumbers }) {

    if(user == null) throw Exception('An authenticated user is required to mark the notifications as read');
    
    final url =  user!.links.markNotificationsAsRead.href;

    Map body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList()
    };

    return apiRepository.post(url: url, body: body);
    
  }
}