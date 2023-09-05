import '../../authentication/providers/auth_provider.dart';
import '../../../../../core/shared_models/user.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../models/friend_group.dart';

class FriendGroupRepository {
  
  /// The friend group does not exist until it is set.
  final FriendGroup? friendGroup;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final AuthProvider authProvider;

  /// Constructor: Set the provided FriendGroup and Api Provider
  FriendGroupRepository({ this.friendGroup, required this.authProvider });

  /// Get the Auth User
  User get user => authProvider.user!;

  /// Get the Api Provider required to enable requests with the set Bearer Token
  ApiProvider get apiProvider => authProvider.apiProvider;

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Show friend group filters
  Future<dio.Response> showFriendGroupFilters({ BuildContext? context }){
    
    final url =  user.links.showFriendGroupFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Show friend groups
  Future<dio.Response> showFriendGroups({ String? filter, bool withCountFriends = false, bool withCountUsers = false, bool withCountStores = false, bool withCountOrders = false, String searchWord = '', int page = 1 }){

    final url =  user.links.showFriendGroups.href;

    Map<String, String> queryParams = {};

    if(withCountUsers) queryParams.addAll({'withCountUsers': '1'});
    if(withCountStores) queryParams.addAll({'withCountStores': '1'});
    if(withCountOrders) queryParams.addAll({'withCountOrders': '1'});
    if(withCountFriends) queryParams.addAll({'withCountFriends': '1'});
      
    /// Page
    queryParams.addAll({'page': page.toString()});

    /// Filter friend groups by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, queryParams: queryParams);
  
  }

  /// Remove friend groups
  Future<dio.Response> createFriendGroup({ required String name, required bool shared, required bool canAddFriends, required List<User> friends }) {

    String url = user.links.createFriendGroups.href;

    List<String> mobileNumbers = friends.map((friend) {
        return friend.mobileNumber!.withExtension;
    }).toList();
    
    Map<String, dynamic> body = {
      'name': name,
      'shared': shared,
      'mobile_numbers': mobileNumbers,
      'can_add_friends': canAddFriends,
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Update friend group
  Future<dio.Response> updateFriendGroup({ required String name, required bool shared, required bool canAddFriends, required List<User> friends }) {

    if(friendGroup == null) throw Exception('A friend group is required to update');

    String url = friendGroup!.links.updateFriendGroup.href;

    List<String> mobileNumbers = friends.map((friend) {
        return friend.mobileNumber!.withExtension;
    }).toList();
    
    Map<String, dynamic> body = {
      'name': name,
      'shared': shared,
      'mobile_numbers': mobileNumbers,
      'can_add_friends': canAddFriends,
    };

    return apiRepository.put(url: url, body: body);
    
  }

  /// Delete friend group
  Future<dio.Response> deleteFriendGroup({ required String name, required bool shared, required bool canAddFriends, required List<User> friends }) {

    if(friendGroup == null) throw Exception('A friend group is required to delete');

    String url = friendGroup!.links.deleteFriendGroup.href;

    List<String> mobileNumbers = friends.map((friend) {
        return friend.mobileNumber!.withExtension;
    }).toList();
    
    Map<String, dynamic> body = {
      'name': name,
      'shared': shared,
      'mobile_numbers': mobileNumbers,
      'can_add_friends': canAddFriends,
    };

    return apiRepository.put(url: url, body: body);
    
  }

  /// Delete friend groups
  Future<dio.Response> deleteManyFriendGroups({ required List<FriendGroup> friendGroups }) {

    String url = user.links.deleteManyFriendGroups.href;

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map<String, dynamic> body = {
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.delete(url: url, body: body);
    
  }

  /// Show friend groups members
  Future<dio.Response> showFriendGroupMembers({ int? exceptUserId, int page = 1,  BuildContext? context }){

    if(friendGroup == null) throw Exception('A friend group is required to show members');

    String url = friendGroup!.links.showFriendGroupMembers.href;

    Map<String, String> queryParams = {};
      
    /// Page
    queryParams.addAll({'page': page.toString()});
    
    /// Exclude specific users matching the specified user id
    if(exceptUserId != null) queryParams.addAll({'except_user_id': exceptUserId.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Remove friend groups members
  Future<dio.Response> removeFriendGroupMembers({ required List<User> friends }) {

    if(friendGroup == null) throw Exception('A friend group is required to remove members');

    String url = friendGroup!.links.removeFriendGroupMembers.href;

    List<int> userIds = friends.map((friend) {
        return friend.id;
    }).toList();
    
    Map<String, dynamic> body = {
      'user_ids': userIds,
    };

    return apiRepository.delete(url: url, body: body);
    
  }
  
  /// Show last selected friend group
  Future<dio.Response> showLastSelectedFriendGroup({ BuildContext? context }) {

    final url = user.links.showLastSelectedFriendGroup.href;

    return apiRepository.get(url: url);
  
  }

  /// Update last selected friend groups
  Future<dio.Response> updateLastSelectedFriendGroups({ required List<FriendGroup> friendGroups }) {

    final url = user.links.updateLastSelectedFriendGroups.href;

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map<String, dynamic> body = {
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.put(url: url, body: body);
    
  }
  
  /// Get the orders of the specified friend group
  Future<dio.Response> showFriendGroupOrders({ String searchWord = '', bool withStore = false, bool withOccasion = false, int page = 1 }) {

    if(friendGroup == null) throw Exception('A friend group is required to show orders');

    String url = friendGroup!.links.showFriendGroupOrders.href;

    Map<String, String> queryParams = {};
      
    /// Page
    queryParams.addAll({'page': page.toString()});

    /// Check if we should eager load the store
    if(withStore) queryParams.addAll({'withStore': '1'});

    if(withOccasion) queryParams.addAll({'withOccasion': '1'});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});
    
    return apiRepository.get(url: url, queryParams: queryParams);
    
  }
}