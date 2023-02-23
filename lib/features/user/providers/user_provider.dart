import '../../../core/shared_models/user.dart';
import '../../api/providers/api_provider.dart';
import '../repositories/user_repository.dart';
import 'package:flutter/material.dart';

/// The UserProvider is strictly responsible for maintaining the state 
/// of the user. This state can then be shared with the rest of the 
/// application. User related requests are managed by the 
/// UserRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class UserProvider with ChangeNotifier {
  
  User? _user;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  UserProvider({ required this.apiProvider });

  /// Return the user
  User? get user => _user;

  /// Return the User Repository
  UserRepository get userRepository => UserRepository(user: user, apiProvider: apiProvider);

  /// Set the specified user
  UserProvider setUser(User user) {
    _user = user;
    return this;
  }
}