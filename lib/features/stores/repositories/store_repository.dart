import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';

import '../../../../../core/shared_models/permission.dart';
import '../../../../../core/utils/mobile_number.dart';
import '../../../../../core/shared_models/user.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/models/api_home.dart' as api_home;
import '../../api/providers/api_provider.dart';
import '../../products/models/product.dart';
import 'package:http/http.dart' as http;
import '../models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../enums/store_enums.dart';

class StoreRepository {

  /// The store does not exist until it is set.
  final ShoppableStore? store;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  StoreRepository({ this.store, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Get the Api Home links required to perform requests to using the routes
  api_home.Links get homeApiLinks => apiProvider.apiHome!.links;

  /// Get the stores of the authenticated user by association 
  /// e.g where the user is a follower, customer, or team member.
  /// If the association is not provided, the default behaviour is
  /// to return stores where the authenticated user is a team member
  Future<http.Response> showStores({ UserAssociation? userAssociation, bool withProducts = false, bool withCountFollowers = false, bool withCountTeamMembers = false, bool withCountReviews = false, bool withCountOrders = false, withCountCoupons = false, bool withRating = false, FriendGroup? friendGroup, String searchTerm = '', int? page = 1, BuildContext? context }) {

    String url = homeApiLinks.stores;

    Map<String, String> queryParams = {};
    if(withRating) queryParams.addAll({'withRating': '1'});
    if(withProducts) queryParams.addAll({'withProducts': '1'});
    if(withCountOrders) queryParams.addAll({'withCountOrders': '1'});
    if(withCountCoupons) queryParams.addAll({'withCountCoupons': '1'});
    if(withCountReviews) queryParams.addAll({'withCountReviews': '1'});
    if(withCountFollowers) queryParams.addAll({'withCountFollowers': '1'});
    if(withCountTeamMembers) queryParams.addAll({'withCountTeamMembers': '1'});
    if(userAssociation != null) queryParams.addAll({'type': userAssociation.name});
    if(friendGroup != null) queryParams.addAll({'friend_group_id': friendGroup.id.toString()});

    /// Filter by search
    if(searchTerm.isNotEmpty) queryParams.addAll({'search': searchTerm}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams, context: context);
    
  }

  ///////////////////////////////////
  ///   ORDERS                   ///
  //////////////////////////////////

  /// Get the order filters of the specified store
  Future<http.Response> showOrderFilters({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show the order filters');

    String url = store!.links.showOrderFilters.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Get the orders of the specified store
  Future<http.Response> showOrders({ String? filter, int? customerUserId, int? exceptOrderId, int? startAtOrderId, bool withCustomer = false, String searchTerm = '', int page = 1, BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show orders');

    String url = store!.links.showOrders.href;

    Map<String, String> queryParams = {};

    if(withCustomer) queryParams.addAll({'withCustomer': '1'});

    /// Filter orders by the specified customer id
    if(customerUserId != null) queryParams.addAll({'customer_user_id': customerUserId.toString()});

    /// Exclude specific orders matching the specified order id
    if(exceptOrderId != null) queryParams.addAll({'except_order_id': exceptOrderId.toString()});

    /// Exclude specific orders matching the specified order id
    if(startAtOrderId != null) queryParams.addAll({'start_at_order_id': startAtOrderId.toString()});
    
    /// Filter orders by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchTerm.isNotEmpty) queryParams.addAll({'search': searchTerm});
    
    return apiRepository.get(url: url, page: page, queryParams: queryParams, context: context);
    
  }

  ///////////////////////////////////
  ///   COUPONS                  ///
  //////////////////////////////////

  /// Get the coupons of the specified store
  Future<http.Response> showCoupons({ BuildContext? context, int? page = 1 }) {

    if(store == null) throw Exception('The store must be set to show coupons');

    String url = store!.links.showCoupons.href;
    return apiRepository.get(url: url, page: page, context: context);
    
  }

  ///////////////////////////////////
  ///   FOLLOWERS                ///
  //////////////////////////////////

  /// Get the follower filters of the specified store
  Future<http.Response> showFollowerFilters({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show follower filters');

    String url = store!.links.showFollowerFilters.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Get the followers of the specified store
  Future<http.Response> showFollowers({ String? filter, String searchTerm = '', int page = 1, BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show followers');

    String url = store!.links.showFollowers.href;

    Map<String, String> queryParams = {};
      
    /// Filter team members by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchTerm.isNotEmpty) queryParams.addAll({'search': searchTerm}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams, context: context);
    
  }

  /// Get the following status on the specified store
  Future<http.Response> showFollowing({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show following status');

    String url = store!.links.showFollowing.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Update the following status on the specified store
  Future<http.Response> updateFollowing({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to update following status');

    String url = store!.links.updateFollowing.href;
    return apiRepository.post(url: url, context: context);
    
  }

  /// Update the following status on the specified store
  Future<http.Response> inviteFollowers({ required List<String> mobileNumbers, BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to invite followers');

    String url = store!.links.inviteFollowers.href;

    Map body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList()
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Check the user invitations on the specified store
  Future<http.Response> checkStoreInvitationsToFollow({ BuildContext? context }) {

    String url = homeApiLinks.storesCheckInvitationsToFollow;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> acceptInvitationToFollow({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to accept invitation to follow');

    String url = store!.links.acceptInvitationToFollow.href;

    return apiRepository.post(url: url, context: context);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> declineInvitationToFollow({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to decline invitation to follow');

    String url = store!.links.declineInvitationToFollow.href;

    return apiRepository.post(url: url, context: context);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> acceptAllInvitationsToFollow({ BuildContext? context }) {

    String url = homeApiLinks.storesAcceptAllInvitationsToFollow;

    return apiRepository.post(url: url, context: context);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> declineAllInvitationsToFollow({ BuildContext? context }) {

    String url = homeApiLinks.storesDeclineAllInvitationsToFollow;

    return apiRepository.post(url: url, context: context);
    
  }

  ///////////////////////////////////
  ///   TEAM MEMBERS             ///
  //////////////////////////////////

  /// Get the follower filters of the specified store
  Future<http.Response> showTeamMemberFilters({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show team member filters');

    String url = store!.links.showTeamMemberFilters.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Get the team members of the specified store
  Future<http.Response> showTeamMembers({ String? filter, String searchTerm = '', int page = 1, BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show team members');

    String url = store!.links.showTeamMembers.href;

    Map<String, String> queryParams = {};
      
    /// Filter team members by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchTerm.isNotEmpty) queryParams.addAll({'search': searchTerm}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams, context: context);
    
  }

  /// Show the store team permissions
  Future<http.Response> showAllTeamMemberPermissions({ BuildContext? context }) {
    
    String url = homeApiLinks.showAllTeamMemberPermissions;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Update the following status on the specified store
  Future<http.Response> inviteTeamMembers({ required List<String> mobileNumbers, List<Permission> permissions = const [], BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to invite team members');

    String url = store!.links.inviteTeamMembers.href;

    Map body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList(),
      /// Get the permission names in lowercase
      'permissions': permissions.map((permission) => permission.name.toLowerCase()).toList(),
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Update the following status on the specified store
  Future<http.Response> updateTeamMemberPermissions({ required User teamMember, List<Permission> permissions = const [], BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to update the team member permissions');

    String url = teamMember.links.updateStoreTeamMemberPermissions!.href;

    Map body = {
      /// Get the permission names in lowercase
      'permissions': permissions.map((permission) => permission.name.toLowerCase()).toList(),
    };

    return apiRepository.put(url: url, body: body, context: context);
    
  }

  /// Remove team members on the specified store
  Future<http.Response> removeTeamMembers({ required List<User> teamMembers, BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to remove the team members');

    String url = store!.links.removeTeamMembers.href;

    List<String> mobileNumbers = teamMembers.map((selectedTeamMember) {

      if(selectedTeamMember.attributes.userAssociationAsTeamMember!.mobileNumber != null) {
        return selectedTeamMember.attributes.userAssociationAsTeamMember!.mobileNumber!.withExtension;
      }else{
        return selectedTeamMember.mobileNumber!.withExtension;
      }

    }).toList();
    
    Map body = {
      'mobile_numbers': mobileNumbers,
    };

    return apiRepository.delete(url: url, body: body, context: context);
    
  }

  /// Check the user invitations on the specified store
  Future<http.Response> checkStoreInvitationsToJoinTeam({ BuildContext? context }) {

    String url = homeApiLinks.storesCheckInvitationsToJoinTeam;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> acceptInvitationToJoinTeam({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to accept invitation to join team');

    String url = store!.links.acceptInvitationToJoinTeam.href;

    return apiRepository.post(url: url, context: context);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> declineInvitationToJoinTeam({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to decline invitation to join team');

    String url = store!.links.declineInvitationToJoinTeam.href;

    return apiRepository.post(url: url, context: context);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> acceptAllInvitationsToJoinTeam({ BuildContext? context }) {

    String url = homeApiLinks.storesAcceptAllInvitationsToJoinTeam;

    return apiRepository.post(url: url, context: context);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> declineAllInvitationsToJoinTeam({ BuildContext? context }) {

    String url = homeApiLinks.storesDeclineAllInvitationsToJoinTeam;

    return apiRepository.post(url: url, context: context);
    
  }

  ///////////////////////////////////
  ///   REVIEWS                  ///
  //////////////////////////////////

  /// Get the review filters of the specified store
  Future<http.Response> showReviewFilters({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show the review filters');

    String url = store!.links.showReviewFilters.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Get the reviews of the specified store
  Future<http.Response> showReviews({ required String? filter, int? userId, bool withUser = false, String searchTerm = '', int page = 1, BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show reviews');

    String url = store!.links.showReviews.href;

    Map<String, String> queryParams = {};

    if(withUser) queryParams.addAll({'withUser': '1'});

    /// Filter reviews by the specified user id
    if(userId != null) queryParams.addAll({'user_id': userId.toString()});
    
    /// Filter reviews by the specified filter
    if(filter != null) queryParams.addAll({'filter': filter});
    
    /// Filter by search
    if(searchTerm.isNotEmpty) queryParams.addAll({'search': searchTerm}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams, context: context);
    
  }

  /// Get the review rating options of the specified store
  Future<http.Response> showReviewRatingOptions({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show review rating options');

    String url = store!.links.showReviewRatingOptions.href;
    return apiRepository.get(url: url, context: context);
    
  }

  /// Create a review on the specified store
  Future<http.Response> createReview({ BuildContext? context, required String subject, String? comment, required int rating }) {

    if(store == null) throw Exception('The store must be set to create a review');

    String url = store!.links.createReviews.href;
    
    Map body = {
      'rating': rating.toString(),
      'subject': subject,
    };

    if(comment != null && comment.isNotEmpty) body.addAll({ 'comment': comment });
    
    return apiRepository.post(url: url, body: body, context: context);
    
  }

  ///////////////////////////////////
  ///   SHOPPING CART            ///
  //////////////////////////////////

  /// Inspect the shopping cart
  Future<http.Response> showShoppingCartOrderForOptions({ BuildContext? context }) {

    if(store == null) throw Exception('The store must be set to show the shopping cart order for options');

    String url = store!.links.showShoppingCartOrderForOptions.href;

    return apiRepository.get(url: url, context: context);
    
  }

  /// Inspect the shopping cart
  Future<http.Response> inspectShoppingCart({ BuildContext? context, List<Product> products = const [], List<String> cartCouponCodes = const [] }) {

    if(store == null) throw Exception('The store must be set to inspect the shopping cart');

    String url = store!.links.inspectShoppingCart.href;
    
    Map body = {
      'cart_coupon_codes': cartCouponCodes,
      'cart_products': products.map((product) {
        return {
          'id': product.id,
          'quantity': product.quantity,
        };
      }).toList(),
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }

  /// Convert the shopping cart into an order
  Future<http.Response> convertShoppingCart({ BuildContext? context, List<Product> products = const [], List<String> cartCouponCodes = const [] }) {

    if(store == null) throw Exception('The store must be set to convert the shopping cart');

    String url = store!.links.convertShoppingCart.href;
    
    Map body = {
      'cart_coupon_codes': cartCouponCodes,
      'cart_products': products.map((product) {
        return {
          'id': product.id,
          'quantity': product.quantity,
        };
      }).toList(),
    };

    return apiRepository.post(url: url, body: body, context: context);
    
  }
}