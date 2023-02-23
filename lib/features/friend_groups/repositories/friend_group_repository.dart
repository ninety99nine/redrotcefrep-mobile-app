import '../../authentication/providers/auth_provider.dart';
import '../../../../../core/shared_models/user.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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

  /// Show friend group menus
  Future<http.Response> showFriendGroupMenus({ BuildContext? context }){
    
    final url =  user.links.showFriendGroupMenus!.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Show friend groups
  Future<http.Response> showFriendGroups({ String? filter, bool withCountFriends = false, bool withCountUsers = false, bool withCountStores = false, String searchWord = '', int? page = 1, BuildContext? context }){

    final url =  user.links.showFriendGroups!.href;

    Map<String, String> queryParams = {};

    if(withCountUsers) queryParams.addAll({'withCountUsers': '1'});
    if(withCountStores) queryParams.addAll({'withCountStores': '1'});
    if(withCountFriends) queryParams.addAll({'withCountFriends': '1'});

    /// Filter friend groups by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams, context: context);
  
  }

  /// Remove friend groups
  Future<http.Response> createFriendGroup({ required String name, required bool shared, required bool canAddFriends, required List<User> friends, BuildContext? context }) {

    String url = user.links.createFriendGroups!.href;

    List<String> mobileNumbers = friends.map((friend) {
        return friend.mobileNumber!.withExtension;
    }).toList();
    
    Map body = {
      'name': name,
      'shared': shared,
      'mobile_numbers': mobileNumbers,
      'can_add_friends': canAddFriends,
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Update friend group
  Future<http.Response> updateFriendGroup({ required String name, required bool shared, required bool canAddFriends, required List<User> friends, BuildContext? context }) {

    if(friendGroup == null) throw Exception('A friend group is required to update');

    String url = friendGroup!.links.updateFriendGroup.href;

    List<String> mobileNumbers = friends.map((friend) {
        return friend.mobileNumber!.withExtension;
    }).toList();
    
    Map body = {
      'name': name,
      'shared': shared,
      'mobile_numbers': mobileNumbers,
      'can_add_friends': canAddFriends,
    };

    return apiRepository.put(url: url, body: body, context: context);
    
  }

  /// Delete friend group
  Future<http.Response> deleteFriendGroup({ required String name, required bool shared, required bool canAddFriends, required List<User> friends, BuildContext? context }) {

    if(friendGroup == null) throw Exception('A friend group is required to delete');

    String url = friendGroup!.links.deleteFriendGroup.href;

    List<String> mobileNumbers = friends.map((friend) {
        return friend.mobileNumber!.withExtension;
    }).toList();
    
    Map body = {
      'name': name,
      'shared': shared,
      'mobile_numbers': mobileNumbers,
      'can_add_friends': canAddFriends,
    };

    return apiRepository.put(url: url, body: body, context: context);
    
  }

  /// Delete friend groups
  Future<http.Response> deleteFriendGroups({ required List<FriendGroup> friendGroups, BuildContext? context }) {

    String url = user.links.deleteFriendGroups!.href;

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map body = {
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.delete(url: url, body: body, context: context);
    
  }

  /// Show friend groups members
  Future<http.Response> showFriendGroupMembers({ int? exceptUserId, int? page = 1,  BuildContext? context }){

    if(friendGroup == null) throw Exception('A friend group is required to show members');

    String url = friendGroup!.links.showFriendGroupMembers.href;

    Map<String, String> queryParams = {};
    
    /// Exclude specific users matching the specified user id
    if(exceptUserId != null) queryParams.addAll({'except_user_id': exceptUserId.toString()});

    return apiRepository.get(url: url, page: page, queryParams: queryParams, context: context);
    
  }

  /// Remove friend groups members
  Future<http.Response> removeFriendGroupMembers({ required List<User> friends, BuildContext? context }) {

    if(friendGroup == null) throw Exception('A friend group is required to remove members');

    String url = friendGroup!.links.removeFriendGroupMembers.href;

    List<int> userIds = friends.map((friend) {
        return friend.id;
    }).toList();
    
    Map body = {
      'user_ids': userIds,
    };

    return apiRepository.delete(url: url, body: body, context: context);
    
  }
  
  /// Show last selected friend group
  Future<http.Response> showLastSelectedFriendGroup({ BuildContext? context }) {

    final url = user.links.showLastSelectedFriendGroup!.href;

    return apiRepository.get(url: url, context: context);
  
  }

  /// Update last selected friend groups
  Future<http.Response> updateLastSelectedFriendGroups({ required List<FriendGroup> friendGroups, BuildContext? context }) {

    final url = user.links.updateLastSelectedFriendGroups!.href;

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map body = {
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.put(url: url, body: body, context: context);
    
  }
  
  /// Get the orders of the specified friend group
  Future<http.Response> showFriendGroupOrders({ String searchWord = '', int page = 1 }) {

    if(friendGroup == null) throw Exception('A friend group is required to show orders');

    String url = friendGroup!.links.showFriendGroupOrders.href;

    Map<String, String> queryParams = {};

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});
    
    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }
}