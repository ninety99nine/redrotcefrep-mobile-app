import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:perfect_order/core/utils/mobile_number.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../../../core/shared_models/user.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;
import '../models/friend_group.dart';

class FriendGroupRepository {
  
  /// The friend group does not exist until it is set.
  final FriendGroup? friendGroup;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final AuthProvider authProvider;

  /// Constructor: Set the provided FriendGroup and Auth Provider
  FriendGroupRepository({ this.friendGroup, required this.authProvider });

  /// Get the Auth User
  User get user => authProvider.user!;

  /// Get the Api Provider required to enable requests with the set Bearer Token
  ApiProvider get apiProvider => authProvider.apiProvider;

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;
  
  /// Show first created friend group
  Future<dio.Response> showFirstCreatedFriendGroup() {

    final url = user.links.showFirstCreatedFriendGroup.href;

    return apiRepository.get(url: url);
  
  }
  
  /// Show last selected friend group
  Future<dio.Response> showLastSelectedFriendGroup({ bool withCountFriends = false, bool withCountUsers = false, bool withCountStores = false, bool withCountOrders = false }) {

    final url = user.links.showLastSelectedFriendGroup.href;

    Map<String, String> queryParams = {};

    if(withCountUsers) queryParams.addAll({'withCountUsers': '1'});
    if(withCountStores) queryParams.addAll({'withCountStores': '1'});
    if(withCountOrders) queryParams.addAll({'withCountOrders': '1'});
    if(withCountFriends) queryParams.addAll({'withCountFriends': '1'});

    return apiRepository.get(url: url, queryParams: queryParams);
  
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

  /// Delete many friend groups
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

  /// Remove friend groups
  Future<dio.Response> createFriendGroup({ String? emoji, required String name, String? description, required bool shared, required bool canAddFriends, List<User> friends = const [] }) {

    String url = user.links.createFriendGroups.href;
    
    Map<String, dynamic> body = {
      'name': name,
      'emoji': emoji,
      'shared': shared,
      'description': description,
      'can_add_friends': canAddFriends,
    };

    if(friends.isNotEmpty) {
      body['mobile_numbers'] = friends.map((friend) {
          return friend.mobileNumber!.withExtension;
      }).toList();
    }

    return apiRepository.post(url: url, body: body);
    
  }

  /// Show friend group filters
  Future<dio.Response> showFriendGroupFilters(){
    
    final url =  user.links.showFriendGroupFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Show friend groups
  Future<dio.Response> showFriendGroups({ String? filter, bool withCountFriends = false, bool withCountUsers = false, bool withCountStores = false, bool withCountOrders = false, String searchWord = '', int page = 1 }) {

    final url =  user.links.showFriendGroups.href;

    Map<String, String> queryParams = {};

    if(withCountUsers) queryParams.addAll({'withCountUsers': '1'});
    if(withCountStores) queryParams.addAll({'withCountStores': '1'});
    if(withCountOrders) queryParams.addAll({'withCountOrders': '1'});
    if(withCountFriends) queryParams.addAll({'withCountFriends': '1'});
    
    /// Filter friend groups by the specified filter
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
  
  }

  /// Check the invitations to join friend groups
  Future<dio.Response> checkInvitationsToJoinFriendGroups() {

    String url = user.links.checkInvitationsToJoinFriendGroups.href;

    return apiRepository.get(url: url);
    
  }

  /// Accept all invitations to join friend groups
  Future<dio.Response> acceptAllInvitationsToJoinFriendGroups() {

    String url = user.links.acceptAllInvitationsToJoinFriendGroups.href;

    return apiRepository.put(url: url);
    
  }

  /// Decline all invitations to join friend groups
  Future<dio.Response> declineAllInvitationsToJoinFriendGroups() {

    String url = user.links.declineAllInvitationsToJoinFriendGroups.href;

    return apiRepository.put(url: url);
    
  }

  /// Show friend group
  Future<dio.Response> showFriendGroup({ bool withCountFriends = false, bool withCountUsers = false, bool withCountStores = false, bool withCountOrders = false }){

    if(friendGroup == null) throw Exception('The friend group must be set to show');

    String url = friendGroup!.links.self.href;

    Map<String, String> queryParams = {};

    if(withCountUsers) queryParams.addAll({'withCountUsers': '1'});
    if(withCountStores) queryParams.addAll({'withCountStores': '1'});
    if(withCountOrders) queryParams.addAll({'withCountOrders': '1'});
    if(withCountFriends) queryParams.addAll({'withCountFriends': '1'});

    return apiRepository.get(url: url, queryParams: queryParams);
  
  }

  /// Update friend group
  Future<dio.Response> updateFriendGroup({ String? emoji, required String name, String? description, required bool shared, required bool canAddFriends, List<User> friends = const [] }) {

    if(friendGroup == null) throw Exception('The friend group must be set to update');

    String url = friendGroup!.links.updateFriendGroup.href;
    
    Map<String, dynamic> body = {
      'name': name,
      'emoji': emoji,
      'shared': shared,
      'description': description,
      'can_add_friends': canAddFriends,
    };

    if(friends.isNotEmpty) {
      body['mobile_numbers'] = friends.map((friend) {
          return friend.mobileNumber!.withExtension;
      }).toList();
    }

    return apiRepository.put(url: url, body: body);
    
  }

  /// Delete friend group
  Future<dio.Response> deleteFriendGroup() {

    if(friendGroup == null) throw Exception('The friend group must be set to delete');

    String url = friendGroup!.links.deleteFriendGroup.href;

    return apiRepository.delete(url: url);
    
  }

  /// Invite members to join this friend group
  Future<dio.Response> inviteMembers({ required List<String> mobileNumbers, required String role }) {

    if(friendGroup == null) throw Exception('The friend group must be set to invite members');

    String url = friendGroup!.links.inviteMembers.href;

    Map<String, dynamic> body = {
      'role': role,
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList(),
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Remove members from this friend group
  Future<dio.Response> removeMembers({ required List<String> mobileNumbers }) {

    if(friendGroup == null) throw Exception('The friend group must be set to remove members');

    String url = friendGroup!.links.removeMembers.href;

    Map<String, dynamic> body = {
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList(),
    };

    return apiRepository.delete(url: url, body: body);
    
  }

  /// Accept all invitations to join friend groups
  Future<dio.Response> acceptInvitationToJoinFriendGroup() {

    if(friendGroup == null) throw Exception('The friend group must be set to accept invitations');

    String url = friendGroup!.links.acceptInvitationToJoinFriendGroup.href;

    return apiRepository.put(url: url);
    
  }

  /// Decline all invitations to join friend groups
  Future<dio.Response> declineInvitationToJoinFriendGroup() {

    if(friendGroup == null) throw Exception('The friend group must be set to decline invitations');

    String url = friendGroup!.links.declineInvitationToJoinFriendGroup.href;

    return apiRepository.put(url: url);
    
  }

  /// Show friend group member filters
  Future<dio.Response> showFriendGroupMemberFilters(){

    if(friendGroup == null) throw Exception('The friend group must be set to show member filters');

    String url = friendGroup!.links.showMemberFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Show friend group members
  Future<dio.Response> showFriendGroupMembers({ String? filter, bool withCountFriends = false, bool withCountUsers = false, bool withCountStores = false, bool withCountOrders = false, String searchWord = '', int page = 1 }) {

    if(friendGroup == null) throw Exception('The friend group must be set to show members');

    String url = friendGroup!.links.showMembers.href;

    Map<String, String> queryParams = {};
    
    /// Filter members by the specified filter
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
  
  }

  /// Get the store filters of the specified friend group
  Future<dio.Response> showFriendGroupStoreFilters() {

    if(friendGroup == null) throw Exception('The friend group must be set to show store filters');

    String url = friendGroup!.links.showStoreFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the stores of the specified friend group
  Future<dio.Response> showFriendGroupStores({ String? filter, bool withVisibleProducts = false, bool withCountProducts = false, bool withCountFollowers = false, bool withVisitShortcode = false, bool withCountTeamMembers = false, bool withCountReviews = false, bool withCountOrders = false, withCountCoupons = false, bool withRating = false, String searchWord = '', int page = 1 }) {

    if(friendGroup == null) throw Exception('The friend group must be set to show stores');

    String url = friendGroup!.links.showStores.href;

    Map<String, String> queryParams = {};
    if(withRating) queryParams.addAll({'withRating': '1'});
    if(withCountOrders) queryParams.addAll({'withCountOrders': '1'});
    if(withCountCoupons) queryParams.addAll({'withCountCoupons': '1'});
    if(withCountReviews) queryParams.addAll({'withCountReviews': '1'});
    if(withCountProducts) queryParams.addAll({'withCountProducts': '1'});
    if(withCountFollowers) queryParams.addAll({'withCountFollowers': '1'});
    if(withVisitShortcode) queryParams.addAll({'withVisitShortcode': '1'});
    if(withVisibleProducts) queryParams.addAll({'withVisibleProducts': '1'});
    if(withCountTeamMembers) queryParams.addAll({'withCountTeamMembers': '1'});
    
    /// Filter stores by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Add friend group stores
  Future<dio.Response> addFriendGroupStores({ required List<ShoppableStore> stores }) {

    if(friendGroup == null) throw Exception('The friend group must be set to add stores');

    String url = friendGroup!.links.addStores.href;

    List<int> storeIds = stores.map((store) {
        return store.id;
    }).toList();
    
    Map<String, dynamic> body = {
      'store_ids': storeIds,
    };

    return apiRepository.post(url: url, body: body);
  
  }

  /// Remove friend group stores
  Future<dio.Response> removeFriendGroupStores({ required List<ShoppableStore> stores }) {

    if(friendGroup == null) throw Exception('The friend group must be set to remove stores');

    String url = friendGroup!.links.removeStores.href;

    List<int> storeIds = stores.map((store) {
        return store.id;
    }).toList();
    
    Map<String, dynamic> body = {
      'store_ids': storeIds,
    };

    return apiRepository.delete(url: url, body: body);
  
  }

  /// Get the order filters of the specified friend group
  Future<dio.Response> showFriendGroupOrderFilters({ required UserOrderAssociation userOrderAssociation }) {

    if(friendGroup == null) throw Exception('The friend group must be set to show order filters');

    String url = friendGroup!.links.showMembers.href;

    Map<String, String> queryParams = {};
    
    /// Extract orders by the specified user order association
    queryParams.addAll({'userOrderAssociation': userOrderAssociation.name});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the orders of the specified friend group
  Future<dio.Response> showFriendGroupOrders({ String? filter, required UserOrderAssociation userOrderAssociation, int? startAtOrderId, bool withStore = false, bool withCustomer = false, bool withOccasion = false, bool withUserOrderCollectionAssociation = false, String searchWord = '', int page = 1 }) {

    if(friendGroup == null) throw Exception('The friend group must be set to show orders');

    String url = friendGroup!.links.showOrders.href;

    Map<String, String> queryParams = {};

    if(withStore) queryParams.addAll({'withStore': '1'});

    if(withCustomer) queryParams.addAll({'withCustomer': '1'});

    if(withOccasion) queryParams.addAll({'withOccasion': '1'});

    /// Extract orders by the specified user order association
    queryParams.addAll({'userOrderAssociation': userOrderAssociation.name});

    /// Exclude specific orders matching the specified order id
    if(startAtOrderId != null) queryParams.addAll({'start_at_order_id': startAtOrderId.toString()});

    if(withUserOrderCollectionAssociation) queryParams.addAll({'withUserOrderCollectionAssociation': '1'});
    
    /// Filter orders by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});
    
    return apiRepository.get(url: url, queryParams: queryParams);
    
  }
}