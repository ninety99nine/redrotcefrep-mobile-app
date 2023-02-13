import '../../authentication/providers/auth_provider.dart';
import '../repositories/friend_group_repository.dart';
import 'package:flutter/material.dart';
import '../models/friend_group.dart';

/// The FriendGroupProvider is strictly responsible for maintaining the state 
/// of the friend group. This state can then be shared with the rest of the 
/// application. FriendGroup related requests are managed by the 
/// FriendGroupRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the AuthProvider
class FriendGroupProvider with ChangeNotifier {
  
  FriendGroup? _friendGroup;
  final AuthProvider authProvider;

  /// Constructor: Set the provided Api Provider
  FriendGroupProvider({ required this.authProvider });

  /// Return the store
  FriendGroup? get store => _friendGroup;

  /// Return the Friend Group Repository
  FriendGroupRepository get friendGroupRepository => FriendGroupRepository(friendGroup: _friendGroup, authProvider: authProvider);

  /// Set the specified store
  FriendGroupProvider setFriendGroup(FriendGroup friendGroup) {
    _friendGroup = friendGroup;
    return this;
  }
}