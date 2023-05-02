import 'package:bonako_demo/features/addresses/models/address.dart';
import 'package:bonako_demo/features/stores/models/store.dart';

import '../../../../../core/shared_models/permission.dart';
import '../../friend_groups/models/friend_group.dart';
import '../../../../../core/utils/mobile_number.dart';
import '../../../../../core/shared_models/user.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/models/api_home.dart' as api_home;
import '../../api/providers/api_provider.dart';
import '../../products/models/product.dart';
import 'package:http/http.dart' as http;
import '../models/shoppable_store.dart';
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

  /// Create a store
  Future<http.Response> createStore({ required String name, required String callToAction, required bool acceptedGoldenRules }) {

    String url = homeApiLinks.createStores;
    
    Map body = {
      'name': name,
      'call_to_action': callToAction,
      'accepted_golden_rules': acceptedGoldenRules
    };
    
    return apiRepository.post(url: url, body: body);
    
  }

  /// Get the stores of the authenticated user by association 
  /// e.g where the user is a follower, customer, or team member.
  /// If the association is not provided, the default behaviour is
  /// to return stores where the authenticated user is a team member
  Future<http.Response> showStores({ UserAssociation? userAssociation, bool withVisibleProducts = false, bool withCountProducts = false, bool withCountFollowers = false, bool withVisitShortcode = false, bool withCountTeamMembers = false, bool withCountReviews = false, bool withCountOrders = false, withCountCoupons = false, bool withRating = false, FriendGroup? friendGroup, String searchWord = '', int? page = 1 }) {

    String url = homeApiLinks.showStores;

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
    if(userAssociation != null) queryParams.addAll({'type': userAssociation.name});
    if(friendGroup != null) queryParams.addAll({'friend_group_id': friendGroup.id.toString()});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Get the specified store
  Future<http.Response> showStore({ required String storeUrl, bool withVisibleProducts = false, bool withCountProducts = false, bool withCountFollowers = false, bool withVisitShortcode = false, bool withCountTeamMembers = false, bool withCountReviews = false, bool withCountOrders = false, withCountCoupons = false, bool withRating = false }) {

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

    return apiRepository.get(url: storeUrl, queryParams: queryParams);
    
  }

  /// Update the specified store
  Future<http.Response> updateStore({ 
    String? name, bool? online, String? description, String? offlineMessage, String? deliveryNote,
    bool? allowDelivery, bool? allowFreeDelivery, List<Map>? deliveryDestinations, 
    String? deliveryFlatFee, String? pickupNote, bool? allowPickup,
    List<Map>? pickupDestinations,
    List<String>? supportedPaymentMethods,
  }) {

    if(store == null) throw Exception('The store must be set to update');

    String url = store!.links.updateStore.href;
    
    Map body = {};

    if(online != null) body['online'] = online;
    if(name != null && name.isNotEmpty) body['name'] = name;
    if(allowPickup != null) body['allowPickup'] = allowPickup;
    if(allowDelivery != null) body['allowDelivery'] = allowDelivery;
    if(allowFreeDelivery != null) body['allowFreeDelivery'] = allowFreeDelivery;
    if(pickupNote != null && pickupNote.isNotEmpty) body['pickupNote'] = pickupNote;
    if(description != null && description.isNotEmpty) body['description'] = description;
    if(deliveryNote != null && deliveryNote.isNotEmpty) body['delivery_note'] = deliveryNote;
    if(offlineMessage != null && offlineMessage.isNotEmpty) body['offlineMessage'] = offlineMessage;
    if(deliveryFlatFee != null && deliveryFlatFee.isNotEmpty) body['deliveryFlatFee'] = deliveryFlatFee;
    if(supportedPaymentMethods != null && supportedPaymentMethods.isNotEmpty) body['supportedPaymentMethods'] = supportedPaymentMethods;

    if(pickupDestinations != null && pickupDestinations.isNotEmpty) {
      body['pickupDestinations'] = pickupDestinations.map((pickupDestination) => pickupDestination).toList();
    }
    
    if(deliveryDestinations != null && deliveryDestinations.isNotEmpty) {
      body['deliveryDestinations'] = deliveryDestinations.map((deliveryDestination) => deliveryDestination).toList();
    }

    return apiRepository.put(url: url, body: body);

  }

  /// Delete the specified store
  Future<http.Response> deleteStore() {

    if(store == null) throw Exception('The store must be set to delete');

    String url = store!.links.deleteStore.href;

    return apiRepository.delete(url: url);

  }

  ///////////////////////////////////
  ///   PRODUCTS                 ///
  //////////////////////////////////

  /// Get the product filters of the specified store
  Future<http.Response> showProductFilters() {

    if(store == null) throw Exception('The store must be set to show product filters');

    String url = store!.links.showProductFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the products of the specified store
  Future<http.Response> showProducts({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show products');

    String url = store!.links.showProducts.href;

    Map<String, String> queryParams = {};
      
    /// Filter products by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Create a product on the specified store
  Future<http.Response> createProduct({ 
    required String name, required String? description, required bool showDescription, required bool visible,
    required String unitRegularPrice, required String unitSalePrice, required String unitCostPrice,
    required String? sku, required String? barcode, required bool isFree, required bool allowVariations,
    required String allowedQuantityPerOrder, required String maximumAllowedQuantityPerOrder, 
    required String stockQuantity, required String stockQuantityType, 
  }) {

    if(store == null) throw Exception('The store must be set to create a product');

    String url = store!.links.createProducts.href;
    
    Map body = {
      'name': name,
      'is_free': isFree,
      'visible': visible,
      'unit_cost_price': unitCostPrice,
      'unit_sale_price': unitSalePrice,
      'allow_variations': allowVariations,
      'show_description': showDescription,
      'unit_regular_price': unitRegularPrice,
      'stock_quantity_type': stockQuantityType,
      'allowed_quantity_per_order': allowedQuantityPerOrder,
    };

    if(sku != null && sku.isNotEmpty) body['sku'] = sku;
    if(barcode != null && barcode.isNotEmpty) body['barcode'] = barcode;
    if(stockQuantityType == 'limited') body['stock_quantity'] = stockQuantity;
    if(description != null && description.isNotEmpty) body['description'] = description;
    if(allowedQuantityPerOrder == 'limited') body['maximum_allowed_quantity_per_order'] = maximumAllowedQuantityPerOrder;

    return apiRepository.post(url: url, body: body);
    
  }

  /// Update the product arrangement on the specified store
  Future<http.Response> updateProductArrangement({ required List productIds }) {

    if(store == null) throw Exception('The store must be set to update the product arrangement');

    String url = store!.links.updateProductArrangement.href;
    
    Map body = {'arrangement': productIds};

    return apiRepository.post(url: url, body: body);
    
  }

  ///////////////////////////////////
  ///   SHORTCODES               ///
  //////////////////////////////////

  /// Generate a payment shortcode for the specified store
  Future<http.Response> generatePaymentShortcode() {

    if(store == null) throw Exception('The store must be set to generate a payment shortcode');

    String url = store!.links.generatePaymentShortcode.href;

    return apiRepository.post(url: url);

  }

  ///////////////////////////////////
  ///   SUBSCRIPTIONS            ///
  //////////////////////////////////

  /// Create a subscription on the specified store
  Future<http.Response> createFakeSubscription() {

    if(store == null) throw Exception('The store must be set to create a subscription');

    String url = store!.links.createFakeSubscriptions.href;

    Map body = {
      'test_subscription': 1,
      'payment_method_id': 1,
      'subscription_plan_id': 1,
    };

    return apiRepository.post(url: url, body: body);

  }

  ///////////////////////////////////
  ///   ORDERS                   ///
  //////////////////////////////////

  /// Get the order filters of the specified store
  Future<http.Response> showOrderFilters() {

    if(store == null) throw Exception('The store must be set to show the order filters');

    String url = store!.links.showOrderFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the orders of the specified store
  Future<http.Response> showOrders({ String? filter, int? customerUserId, int? friendUserId, int? exceptOrderId, int? startAtOrderId, bool withCustomer = false, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show orders');

    String url = store!.links.showOrders.href;

    Map<String, String> queryParams = {};

    if(withCustomer) queryParams.addAll({'withCustomer': '1'});

    /// Filter orders by the specified friend user id
    if(friendUserId != null) queryParams.addAll({'friend_user_id': friendUserId.toString()});

    /// Filter orders by the specified customer user id
    if(customerUserId != null) queryParams.addAll({'customer_user_id': customerUserId.toString()});

    /// Exclude specific orders matching the specified order id
    if(exceptOrderId != null) queryParams.addAll({'except_order_id': exceptOrderId.toString()});

    /// Exclude specific orders matching the specified order id
    if(startAtOrderId != null) queryParams.addAll({'start_at_order_id': startAtOrderId.toString()});
    
    /// Filter orders by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});
    
    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  ///////////////////////////////////
  ///   COUPONS                  ///
  //////////////////////////////////

  /// Get the coupons of the specified store
  Future<http.Response> showCoupons({ int? page = 1 }) {

    if(store == null) throw Exception('The store must be set to show coupons');

    String url = store!.links.showCoupons.href;
    return apiRepository.get(url: url, page: page);
    
  }

  ///////////////////////////////////
  ///   FOLLOWERS                ///
  //////////////////////////////////

  /// Get the follower filters of the specified store
  Future<http.Response> showFollowerFilters() {

    if(store == null) throw Exception('The store must be set to show follower filters');

    String url = store!.links.showFollowerFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the followers of the specified store
  Future<http.Response> showFollowers({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show followers');

    String url = store!.links.showFollowers.href;

    Map<String, String> queryParams = {};
      
    /// Filter team members by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Get the following status on the specified store
  Future<http.Response> showFollowing() {

    if(store == null) throw Exception('The store must be set to show following status');

    String url = store!.links.showFollowing.href;

    return apiRepository.get(url: url);
    
  }

  /// Update the following status on the specified store
  Future<http.Response> updateFollowing() {

    if(store == null) throw Exception('The store must be set to update following status');

    String url = store!.links.updateFollowing.href;
    return apiRepository.post(url: url);
    
  }

  /// Update the following status on the specified store
  Future<http.Response> inviteFollowers({ required List<String> mobileNumbers }) {

    if(store == null) throw Exception('The store must be set to invite followers');

    String url = store!.links.inviteFollowers.href;

    Map body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList()
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Check the user invitations on the specified store
  Future<http.Response> checkStoreInvitationsToFollow() {

    String url = homeApiLinks.storesCheckInvitationsToFollow;

    return apiRepository.get(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> acceptInvitationToFollow() {

    if(store == null) throw Exception('The store must be set to accept invitation to follow');

    String url = store!.links.acceptInvitationToFollow.href;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> declineInvitationToFollow() {

    if(store == null) throw Exception('The store must be set to decline invitation to follow');

    String url = store!.links.declineInvitationToFollow.href;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> acceptAllInvitationsToFollow() {

    String url = homeApiLinks.storesAcceptAllInvitationsToFollow;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> declineAllInvitationsToFollow() {

    String url = homeApiLinks.storesDeclineAllInvitationsToFollow;

    return apiRepository.post(url: url);
    
  }

  ///////////////////////////////////
  ///   TEAM MEMBERS             ///
  //////////////////////////////////

  /// Get the follower filters of the specified store
  Future<http.Response> showTeamMemberFilters() {

    if(store == null) throw Exception('The store must be set to show team member filters');

    String url = store!.links.showTeamMemberFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the team members of the specified store
  Future<http.Response> showTeamMembers({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show team members');

    String url = store!.links.showTeamMembers.href;

    Map<String, String> queryParams = {};
      
    /// Filter team members by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Show the store team permissions
  Future<http.Response> showAllTeamMemberPermissions() {
    
    String url = homeApiLinks.showAllTeamMemberPermissions;

    return apiRepository.get(url: url);
    
  }

  /// Update the following status on the specified store
  Future<http.Response> inviteTeamMembers({ required List<String> mobileNumbers, List<Permission> permissions = const [] }) {

    if(store == null) throw Exception('The store must be set to invite team members');

    String url = store!.links.inviteTeamMembers.href;

    Map body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList(),
      /// Get the permission names in lowercase
      'permissions': permissions.map((permission) => permission.name.toLowerCase()).toList(),
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Update the following status on the specified store
  Future<http.Response> updateTeamMemberPermissions({ required User teamMember, List<Permission> permissions = const [] }) {

    if(store == null) throw Exception('The store must be set to update the team member permissions');

    String url = teamMember.links.updateStoreTeamMemberPermissions!.href;

    Map body = {
      /// Get the permission names in lowercase
      'permissions': permissions.map((permission) => permission.name.toLowerCase()).toList(),
    };

    return apiRepository.put(url: url, body: body);
    
  }

  /// Remove team members on the specified store
  Future<http.Response> removeTeamMembers({ required List<User> teamMembers }) {

    if(store == null) throw Exception('The store must be set to remove the team members');

    String url = store!.links.removeTeamMembers.href;

    List<String> mobileNumbers = teamMembers.map((selectedTeamMember) {

      if(selectedTeamMember.attributes.userAndStoreAssociation!.mobileNumber != null) {
        return selectedTeamMember.attributes.userAndStoreAssociation!.mobileNumber!.withExtension;
      }else{
        return selectedTeamMember.mobileNumber!.withExtension;
      }

    }).toList();
    
    Map body = {
      'mobile_numbers': mobileNumbers,
    };

    return apiRepository.delete(url: url, body: body);
    
  }

  /// Check the user invitations on the specified store
  Future<http.Response> checkStoreInvitationsToJoinTeam() {

    String url = homeApiLinks.storesCheckInvitationsToJoinTeam;

    return apiRepository.get(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> acceptInvitationToJoinTeam() {

    if(store == null) throw Exception('The store must be set to accept invitation to join team');

    String url = store!.links.acceptInvitationToJoinTeam.href;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> declineInvitationToJoinTeam() {

    if(store == null) throw Exception('The store must be set to decline invitation to join team');

    String url = store!.links.declineInvitationToJoinTeam.href;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> acceptAllInvitationsToJoinTeam() {

    String url = homeApiLinks.storesAcceptAllInvitationsToJoinTeam;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<http.Response> declineAllInvitationsToJoinTeam() {

    String url = homeApiLinks.storesDeclineAllInvitationsToJoinTeam;

    return apiRepository.post(url: url);
    
  }

  ///////////////////////////////////
  ///   REVIEWS                  ///
  //////////////////////////////////

  /// Get the review filters of the specified store
  Future<http.Response> showReviewFilters() {

    if(store == null) throw Exception('The store must be set to show the review filters');

    String url = store!.links.showReviewFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the reviews of the specified store
  Future<http.Response> showReviews({ required String? filter, int? userId, bool withUser = false, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show reviews');

    String url = store!.links.showReviews.href;

    Map<String, String> queryParams = {};

    if(withUser) queryParams.addAll({'withUser': '1'});

    /// Filter reviews by the specified user id
    if(userId != null) queryParams.addAll({'user_id': userId.toString()});
    
    /// Filter reviews by the specified filter
    if(filter != null) queryParams.addAll({'filter': filter});
    
    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Get the review rating options of the specified store
  Future<http.Response> showReviewRatingOptions() {

    if(store == null) throw Exception('The store must be set to show review rating options');

    String url = store!.links.showReviewRatingOptions.href;
    return apiRepository.get(url: url);
    
  }

  /// Create a review on the specified store
  Future<http.Response> createReview({ required String subject, String? comment, required int rating }) {

    if(store == null) throw Exception('The store must be set to create a review');

    String url = store!.links.createReviews.href;
    
    Map body = {
      'rating': rating.toString(),
      'subject': subject,
    };

    if(comment != null && comment.isNotEmpty) body.addAll({ 'comment': comment });
    
    return apiRepository.post(url: url, body: body);
    
  }

  ///////////////////////////////////
  ///   FRIEND GROUPS            ///
  //////////////////////////////////

  /// Add store to friend groups
  Future<http.Response> addStoreToFriendGroups({ required List<FriendGroup> friendGroups }) {

    if(store == null) throw Exception('The store must be set to add to friend groups');

    String url = store!.links.addToFriendGroups.href;

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map body = {
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Remove store from friend group
  Future<http.Response> removeStoreFromFriendGroups({ required FriendGroup friendGroup }) {

    if(store == null) throw Exception('The store must be set to remove from friend group');

    String url = store!.links.removeFromFriendGroups.href;
    
    Map body = {
      'friend_group_id': friendGroup.id,
    };

    return apiRepository.delete(url: url, body: body);
    
  }

  ///////////////////////////////////
  ///   SHOPPING CART            ///
  //////////////////////////////////

  /// Show the shopping cart order for options
  Future<http.Response> showShoppingCartOrderForOptions() {

    if(store == null) throw Exception('The store must be set to show the shopping cart order for options');

    String url = store!.links.showShoppingCartOrderForOptions.href;

    return apiRepository.get(url: url);
    
  }

  /// Show the shopping cart order for total users (customer & friends)
  Future<http.Response> countShoppingCartOrderForUsers({ required String orderFor, required List<User> friends, required List<FriendGroup> friendGroups }) {

    if(store == null) throw Exception('The store must be set to show the shopping cart order for total friends');

    String url = store!.links.countShoppingCartOrderForUsers.href;

    List<int> friendUserIds = friends.map((friend) {
        return friend.id;
    }).toList();

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map body = {
      'order_for': orderFor,
      'friend_user_ids': friendUserIds,
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Show the shopping cart order for users (customer & friends)
  Future<http.Response> showShoppingCartOrderForUsers({ required String orderFor, required List<User> friends, required List<FriendGroup> friendGroups, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show the shopping cart order for friends');

    String url = store!.links.showShoppingCartOrderForUsers.href;

    List<int> friendUserIds = friends.map((friend) {
        return friend.id;
    }).toList();

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map body = {
      'order_for': orderFor,
      'friend_user_ids': friendUserIds,
      'friend_group_ids': friendGroupIds,
    };

    Map<String, String> queryParams = {};
    
    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});

    return apiRepository.post(url: url, body: body, page: page, queryParams: queryParams);
    
  }

  /// Inspect the shopping cart
  Future<http.Response> inspectShoppingCart({ List<Product> products = const [], List<String> cartCouponCodes = const [], DeliveryDestination? deliveryDestination }) {

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

    if(deliveryDestination != null) body.addAll({'delivery_destination_name': deliveryDestination.name});

    return apiRepository.post(url: url, body: body);
    
  }

  /// Convert the shopping cart into an order
  Future<http.Response> convertShoppingCart({ required String orderFor, required List<User> friends, required List<FriendGroup> friendGroups, List<Product> products = const [], List<String> cartCouponCodes = const [], CollectionType? collectionType, PickupDestination? pickupDestination, DeliveryDestination? deliveryDestination, Address? addressForDelivery }) {

    if(store == null) throw Exception('The store must be set to convert the shopping cart');

    String url = store!.links.convertShoppingCart.href;

    List<int> friendUserIds = friends.map((friend) {
        return friend.id;
    }).toList();

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();

    List<Map> cartProducts = products.map((product) {
        return {
          'id': product.id,
          'quantity': product.quantity,
        };
    }).toList();
    
    Map body = {
      'order_for': orderFor,
      'cart_products': cartProducts,
      'friend_user_ids': friendUserIds,
      'friend_group_ids': friendGroupIds,
      'cart_coupon_codes': cartCouponCodes,
    };

    if(collectionType != null) body.addAll({'collection_type': collectionType.name});
    if(addressForDelivery != null) body.addAll({'address_id': addressForDelivery.id});
    if(pickupDestination != null) body.addAll({'pickup_destination_name': pickupDestination.name});
    if(deliveryDestination != null) body.addAll({'delivery_destination_name': deliveryDestination.name});

    return apiRepository.post(url: url, body: body);
    
  }

}