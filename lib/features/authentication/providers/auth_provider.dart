import '../../api/providers/api_provider.dart';
import '../../../core/shared_models/user.dart';
import '../repositories/auth_repository.dart';
import 'package:flutter/material.dart';

/// The AuthProvider is strictly responsible for maintaining the
/// state of the authenticated user. This state can then be 
/// shared with the rest of the application. Authenticaiton
/// related requests are managed by the AuthRepository
/// which is responsible for communicating with data 
/// sources via a REST API connection provided by
/// the ApiProvider
class AuthProvider with ChangeNotifier {
  
  User? _user;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  AuthProvider({ required this.apiProvider });

  /// Return the user
  User? get user => _user;
  int? get userId => _user?.id;
  String? get bearerToken => apiProvider.apiRepository.bearerToken;

  /// Return the Auth Repository
  AuthRepository get authRepository => AuthRepository(user: user, apiProvider: apiProvider);

  /// Set the specified user
  AuthProvider setUser(User user, { bool canNotifyListeners = false }) {
    _user = user;
    if(canNotifyListeners) notifyListeners();
    return this;
  }

}