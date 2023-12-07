import 'package:bonako_demo/features/addresses/models/address.dart';
import 'package:bonako_demo/features/coupons/enums/coupon_enums.dart';
import 'package:bonako_demo/features/occasions/models/occasion.dart';
import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:bonako_demo/features/stores/models/store.dart';
import '../../../../../core/shared_models/permission.dart';
import '../../friend_groups/models/friend_group.dart';
import '../../../../../core/utils/mobile_number.dart';
import '../../../../../core/shared_models/user.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/models/api_home.dart' as api_home;
import 'package:image_picker/image_picker.dart';
import '../../api/providers/api_provider.dart';
import '../../products/models/product.dart';
import '../models/shoppable_store.dart';
import 'package:dio/dio.dart' as dio;
import '../enums/store_enums.dart';
import 'package:intl/intl.dart';

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
  Future<dio.Response> createStore({ required String name, String? description, required String callToAction, required String mobileNumber }) {

    String url = homeApiLinks.createStores;
    
    Map<String, dynamic> body = {
      'name': name,
      'mobile_number': mobileNumber,
      'call_to_action': callToAction,
    };

    if(description != null && description.isNotEmpty) body.addAll({'description': description});
    
    return apiRepository.post(url: url, body: body);
    
  }

  /// Get the stores of the specified url
  /// e.g brand stores, influencer stores, e.t.c
  Future<dio.Response> showStores({ String? url, bool withVisibleProducts = false, bool withCountProducts = false, bool withCountFollowers = false, bool withVisitShortcode = false, bool withCountTeamMembers = false, bool withCountReviews = false, bool withCountOrders = false, withCountCoupons = false, bool withRating = false, String searchWord = '', int page = 1 }) {

    url ??= homeApiLinks.showStores;

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

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    if(page != null) queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the stores of the specified user by association 
  /// e.g where the user is a follower, customer, or team member.
  /// If the association is not provided, the default behaviour is
  /// to return stores where the authenticated user is a team member
  Future<dio.Response> showUserStores({ required User user, UserAssociation? userAssociation, bool withVisibleProducts = false, bool withCountProducts = false, bool withCountFollowers = false, bool withVisitShortcode = false, bool withCountTeamMembers = false, bool withCountReviews = false, bool withCountOrders = false, withCountCoupons = false, bool withRating = false, FriendGroup? friendGroup, String searchWord = '', int page = 1 }) {

    String url = user.links.showStores.href;

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
    if(userAssociation != null) queryParams.addAll({'filter': userAssociation.name});
    if(friendGroup != null) queryParams.addAll({'friend_group_id': friendGroup.id.toString()});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the specified store
  Future<dio.Response> showStore({ required String storeUrl, bool withVisibleProducts = false, bool withCountProducts = false, bool withCountFollowers = false, bool withVisitShortcode = false, bool withCountTeamMembers = false, bool withCountReviews = false, bool withCountOrders = false, withCountCoupons = false, bool withRating = false }) {

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
  Future<dio.Response> updateStore({
    String? name, bool? online, String? description, String? smsSenderName, String? offlineMessage, String? deliveryNote,
    bool? allowDelivery, bool? allowFreeDelivery, List<Map>? deliveryDestinations, 
    String? deliveryFlatFee, String? pickupNote, bool? allowPickup,
    List<Map>? supportedPaymentMethods, bool? allowDepositPayments,
    List<String>? depositPercentages, bool? allowInstallmentPayments,
    List<String>? installmentPercentages, List<Map>? pickupDestinations,
    bool? perfectPayEnabled, bool? dpoPaymentEnabled, String? dpoCompanyToken, 
    bool? orangeMoneyPaymentEnabled, String? orangeMoneyMerchantCode, 
    String? mobileNumber
  }) {

    if(store == null) throw Exception('The store must be set to update');

    String url = store!.links.updateStore.href;
    
    Map<String, dynamic> body = {};

    if(online != null) body['online'] = online;
    if(name != null && name.isNotEmpty) body['name'] = name;
    if(allowPickup != null) body['allowPickup'] = allowPickup;
    if(allowDelivery != null) body['allowDelivery'] = allowDelivery;
    if(allowFreeDelivery != null) body['allowFreeDelivery'] = allowFreeDelivery;
    if(pickupNote != null && pickupNote.isNotEmpty) body['pickupNote'] = pickupNote;
    if(description != null && description.isNotEmpty) body['description'] = description;
    if(allowDepositPayments != null) body['allowDepositPayments'] = allowDepositPayments;
    if(deliveryNote != null && deliveryNote.isNotEmpty) body['delivery_note'] = deliveryNote;
    if(offlineMessage != null && offlineMessage.isNotEmpty) body['offlineMessage'] = offlineMessage;
    if(allowInstallmentPayments != null) body['allowInstallmentPayments'] = allowInstallmentPayments;
    if(deliveryFlatFee != null && deliveryFlatFee.isNotEmpty) body['deliveryFlatFee'] = deliveryFlatFee;

    if((smsSenderName != null && smsSenderName.isEmpty) || smsSenderName == null) {
      body['smsSenderName'] = null;
    }else{
      body['smsSenderName'] = smsSenderName;
    }

    if(depositPercentages != null && depositPercentages.isNotEmpty) {
      body['depositPercentages'] = depositPercentages.map((depositPercentage) => int.parse(depositPercentage)).toList();
    }

    if(installmentPercentages != null && installmentPercentages.isNotEmpty) {
      body['installmentPercentages'] = installmentPercentages.map((installmentPercentage) => int.parse(installmentPercentage)).toList();
    }

    if(pickupDestinations != null && pickupDestinations.isNotEmpty) {
      body['pickupDestinations'] = pickupDestinations.map((pickupDestination) => pickupDestination).toList();
    }
    
    if(deliveryDestinations != null && deliveryDestinations.isNotEmpty) {
      body['deliveryDestinations'] = deliveryDestinations.map((deliveryDestination) => deliveryDestination).toList();
    }

    if(supportedPaymentMethods != null && supportedPaymentMethods.isNotEmpty) {
      body['supportedPaymentMethods'] = supportedPaymentMethods;
    }

    if(perfectPayEnabled != null) {
      body['perfectPayEnabled'] = perfectPayEnabled;
    }

    if(dpoPaymentEnabled != null) {
      body['dpoPaymentEnabled'] = dpoPaymentEnabled;
    }

    if(dpoCompanyToken != null) {
      body['dpoCompanyToken'] = dpoCompanyToken;
    }

    if(orangeMoneyPaymentEnabled != null) {
      body['orangeMoneyPaymentEnabled'] = orangeMoneyPaymentEnabled;
    }

    if(orangeMoneyMerchantCode != null) {
      body['orangeMoneyMerchantCode'] = orangeMoneyMerchantCode;
    }

    if(mobileNumber != null) {
      body['mobileNumber'] = mobileNumber;
    }

    return apiRepository.put(url: url, body: body);

  }

  /// Delete the specified store
  Future<dio.Response> deleteStore() {

    if(store == null) throw Exception('The store must be set to delete');

    String url = store!.links.deleteStore.href;

    return apiRepository.delete(url: url);

  }

  ///////////////////////////////////
  ///   PRODUCTS                 ///
  //////////////////////////////////

  /// Get the product filters of the specified store
  Future<dio.Response> showProductFilters() {

    if(store == null) throw Exception('The store must be set to show product filters');

    String url = store!.links.showProductFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the products of the specified store
  Future<dio.Response> showProducts({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show products');

    String url = store!.links.showProducts.href;

    Map<String, String> queryParams = {};
      
    /// Filter products by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Create a product on the specified store
  Future<dio.Response> createProduct({
    XFile? photo,
    required String name, required String? description, required bool showDescription, required bool visible,
    required String unitRegularPrice, required String unitSalePrice, required String unitCostPrice,
    required String? sku, required String? barcode, required bool isFree, required bool allowVariations,
    required String allowedQuantityPerOrder, required String maximumAllowedQuantityPerOrder, 
    required String stockQuantity, required String stockQuantityType,
    void Function(int, int)? onSendProgress
  }) {

    if(store == null) throw Exception('The store must be set to create a product');

    String url = store!.links.createProducts.href;
    
    Map<String, dynamic> body = {
      'name': name,
      'photo': photo,
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

    //if(photo != null) body['photo'] = photo;
    if(sku != null && sku.isNotEmpty) body['sku'] = sku;
    if(barcode != null && barcode.isNotEmpty) body['barcode'] = barcode;
    if(stockQuantityType == 'limited') body['stock_quantity'] = stockQuantity;
    if(description != null && description.isNotEmpty) body['description'] = description;
    if(allowedQuantityPerOrder == 'limited') body['maximum_allowed_quantity_per_order'] = maximumAllowedQuantityPerOrder;

    return apiRepository.post(url: url, body: body, onSendProgress: onSendProgress);
    
  }

  /// Update the product arrangement on the specified store
  Future<dio.Response> updateProductArrangement({ required List productIds }) {

    if(store == null) throw Exception('The store must be set to update the product arrangement');

    String url = store!.links.updateProductArrangement.href;
    
    Map<String, dynamic> body = {'arrangement': productIds};

    return apiRepository.post(url: url, body: body);
    
  }

  ///////////////////////////////////
  ///   COUPONS                  ///
  //////////////////////////////////

  /// Get the coupon filters of the specified store
  Future<dio.Response> showCouponFilters() {

    if(store == null) throw Exception('The store must be set to show coupon filters');

    String url = store!.links.showCouponFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the coupons of the specified store
  Future<dio.Response> showCoupons({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show coupons');

    String url = store!.links.showCoupons.href;

    Map<String, String> queryParams = {};
      
    /// Filter coupons by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Create a coupon on the specified store
  Future<dio.Response> createCoupon({ 
    required String name, bool active = false, String? description, DiscountType discountType = DiscountType.percentage,
    bool offerDiscount = false, String? discountFixedRate, String? discountPercentageRate, bool offerFreeDelivery = false,
    bool activateUsingCode = false, String? code, bool activateUsingMinimumGrandTotal = false, String? minimumGrandTotal,
    bool activateUsingMinimumTotalProducts = false, String? minimumTotalProducts, bool activateUsingMinimumTotalProductQuantities = false,
    String? minimumTotalProductQuantities, bool activateUsingStartDatetime = false, DateTime? startDatetime, bool activateUsingEndDatetime = false,
    DateTime? endDatetime, bool activateUsingHoursOfDay = false, List hoursOfDay = const [], bool activateUsingDaysOfTheWeek = false,
    List daysOfTheWeek = const [], bool activateUsingDaysOfTheMonth = false, List daysOfTheMonth = const [],
    bool activateUsingMonthsOfTheYear = false, List monthsOfTheYear = const [], bool activateUsingUsageLimit = false,
    String? remainingQuantity, bool activateForNewCustomer = false, bool activateForExistingCustomer = false
  }) {

    if(store == null) throw Exception('The store must be set to create a coupon');

    String url = store!.links.createCoupons.href;
    
    Map<String, dynamic> body = {
      'name': name,
      'active': active,
      'offerDiscount': offerDiscount,
      'discountType': discountType.name,
      'offerFreeDelivery': offerFreeDelivery,
      'activateUsingCode': activateUsingCode,
      'activateForNewCustomer': activateForNewCustomer,
      'activateUsingUsageLimit': activateUsingUsageLimit,
      'activateUsingHoursOfDay': activateUsingHoursOfDay,
      'activateUsingEndDatetime': activateUsingEndDatetime,
      'activateUsingStartDatetime': activateUsingStartDatetime,
      'activateUsingDaysOfTheWeek': activateUsingDaysOfTheWeek,
      'activateForExistingCustomer': activateForExistingCustomer,
      'activateUsingDaysOfTheMonth': activateUsingDaysOfTheMonth,
      'activateUsingMonthsOfTheYear': activateUsingMonthsOfTheYear,
      'activateUsingMinimumGrandTotal': activateUsingMinimumGrandTotal,
      'activateUsingMinimumTotalProducts': activateUsingMinimumTotalProducts,
      'activateUsingMinimumTotalProductQuantities': activateUsingMinimumTotalProductQuantities,
    };

    if(code != null) body['code'] = code;
    if(hoursOfDay.isNotEmpty) body['hoursOfDay'] = hoursOfDay;
    if(daysOfTheWeek.isNotEmpty) body['daysOfTheWeek'] = daysOfTheWeek;
    if(daysOfTheMonth.isNotEmpty) body['daysOfTheMonth'] = daysOfTheMonth;
    if(monthsOfTheYear.isNotEmpty) body['monthsOfTheYear'] = monthsOfTheYear;
    if(minimumGrandTotal != null) body['minimumGrandTotal'] = minimumGrandTotal;
    if(discountFixedRate != null) body['discountFixedRate'] = discountFixedRate;
    if(remainingQuantity != null) body['remainingQuantity'] = remainingQuantity;
    if(description != null && description.isNotEmpty) body['description'] = description;
    if(minimumTotalProducts != null) body['minimumTotalProducts'] = minimumTotalProducts;
    if(discountPercentageRate != null) body['discountPercentageRate'] = discountPercentageRate;
    if(endDatetime != null) body['endDatetime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDatetime);
    if(startDatetime != null) body['startDatetime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDatetime);
    if(minimumTotalProductQuantities != null) body['minimumTotalProductQuantities'] = minimumTotalProductQuantities;

    return apiRepository.post(url: url, body: body);
    
  }


  ///////////////////////////////////
  ///   PAYMENT METHOD           ///
  //////////////////////////////////

  /// Get the available payment methods of the specified store
  Future<dio.Response> showAvailablePaymentMethods({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show available payment methods');

    String url = store!.links.showAvailablePaymentMethods.href;

    Map<String, String> queryParams = {};
      
    /// Filter coupons by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the supported payment methods of the specified store
  Future<dio.Response> showSupportedPaymentMethods({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show supported payment methods');

    String url = store!.links.showSupportedPaymentMethods.href;

    Map<String, String> queryParams = {};
      
    /// Filter coupons by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  ///////////////////////////////////
  ///   SHORTCODES               ///
  //////////////////////////////////

  /// Generate a payment shortcode for the specified store
  Future<dio.Response> generatePaymentShortcode() {

    if(store == null) throw Exception('The store must be set to generate a payment shortcode');

    String url = store!.links.generatePaymentShortcode.href;

    return apiRepository.post(url: url);

  }

  ///////////////////////////////////
  ///   SUBSCRIPTIONS            ///
  //////////////////////////////////

  /// Create a subscription on the specified store
  Future<dio.Response> createFakeSubscription() {

    if(store == null) throw Exception('The store must be set to create a subscription');

    String url = store!.links.createFakeSubscriptions.href;

    Map<String, dynamic> body = {
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
  Future<dio.Response> showOrderFilters({ required UserOrderAssociation userOrderAssociation }) {

    if(store == null) throw Exception('The store must be set to show the order filters');

    String url = store!.links.showOrderFilters.href;

    Map<String, String> queryParams = {};
    
    /// Extract orders by the specified user order association
    queryParams.addAll({'userOrderAssociation': userOrderAssociation.name});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the orders of the specified store
  Future<dio.Response> showOrders({ String? filter, required UserOrderAssociation userOrderAssociation, int? startAtOrderId, bool withCustomer = false, bool withOccasion = false, bool withUserOrderCollectionAssociation = false, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show orders');

    String url = store!.links.showOrders.href;

    Map<String, String> queryParams = {};

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

  ///////////////////////////////////
  ///   FOLLOWERS                ///
  //////////////////////////////////

  /// Get the follower filters of the specified store
  Future<dio.Response> showFollowerFilters() {

    if(store == null) throw Exception('The store must be set to show follower filters');

    String url = store!.links.showFollowerFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the followers of the specified store
  Future<dio.Response> showFollowers({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show followers');

    String url = store!.links.showFollowers.href;

    Map<String, String> queryParams = {};
      
    /// Filter team members by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the following status on the specified store
  Future<dio.Response> showFollowing() {

    if(store == null) throw Exception('The store must be set to show following status');

    String url = store!.links.showFollowing.href;

    return apiRepository.get(url: url);
    
  }

  /// Update the following status on the specified store
  Future<dio.Response> updateFollowing({ String? status }) {

    if(store == null) throw Exception('The store must be set to update following status');

    String url = store!.links.updateFollowing.href;

    Map<String, String> queryParams = {};
      
    /// Set the following status (Exclude to toggle the status on the API side)
    if(status != null) queryParams.addAll({'status': status});

    return apiRepository.post(url: url, queryParams: queryParams);
    
  }

  /// Update the following status on the specified store
  Future<dio.Response> inviteFollowers({ required List<String> mobileNumbers }) {

    if(store == null) throw Exception('The store must be set to invite followers');

    String url = store!.links.inviteFollowers.href;

    Map<String, dynamic> body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList()
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Check the user invitations on the specified store
  Future<dio.Response> checkStoreInvitationsToFollow() {

    String url = homeApiLinks.checkInvitationsToFollowStores;

    return apiRepository.get(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<dio.Response> acceptInvitationToFollow() {

    if(store == null) throw Exception('The store must be set to accept invitation to follow');

    String url = store!.links.acceptInvitationToFollow.href;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<dio.Response> declineInvitationToFollow() {

    if(store == null) throw Exception('The store must be set to decline invitation to follow');

    String url = store!.links.declineInvitationToFollow.href;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<dio.Response> acceptAllInvitationsToFollow() {

    String url = homeApiLinks.acceptAllInvitationsToFollowStores;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<dio.Response> declineAllInvitationsToFollow() {

    String url = homeApiLinks.declineAllInvitationsToFollowStores;

    return apiRepository.post(url: url);
    
  }

  ///////////////////////////////////
  ///   TEAM MEMBERS             ///
  //////////////////////////////////

  /// Get the follower filters of the specified store
  Future<dio.Response> showTeamMemberFilters() {

    if(store == null) throw Exception('The store must be set to show team member filters');

    String url = store!.links.showTeamMemberFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the team members of the specified store
  Future<dio.Response> showTeamMembers({ String? filter, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show team members');

    String url = store!.links.showTeamMembers.href;

    Map<String, String> queryParams = {};
      
    /// Filter team members by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Show the store team permissions
  Future<dio.Response> showAllTeamMemberPermissions() {

    if(store == null) throw Exception('The store must be set to invite team members');

    String url = store!.links.showAllTeamMemberPermissions.href;

    return apiRepository.get(url: url);
    
  }

  /// Update the following status on the specified store
  Future<dio.Response> inviteTeamMembers({ required List<String> mobileNumbers, List<Permission> permissions = const [] }) {

    if(store == null) throw Exception('The store must be set to invite team members');

    String url = store!.links.inviteTeamMembers.href;

    Map<String, dynamic> body = {
      /// Add the mobile number extension to each mobile number
      'mobile_numbers': mobileNumbers.map((mobileNumber) => MobileNumberUtility.addMobileNumberExtension(mobileNumber)).toList(),
      /// Get the permission names in lowercase
      'permissions': permissions.map((permission) => permission.name.toLowerCase()).toList(),
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Update the following status on the specified store
  Future<dio.Response> updateTeamMemberPermissions({ required User teamMember, List<Permission> permissions = const [] }) {

    if(store == null) throw Exception('The store must be set to update the team member permissions');

    String url = teamMember.links.updateStoreTeamMemberPermissions!.href;

    Map<String, dynamic> body = {
      /// Get the permission names in lowercase
      'permissions': permissions.map((permission) => permission.name.toLowerCase()).toList(),
    };

    return apiRepository.put(url: url, body: body);
    
  }

  /// Remove team members on the specified store
  Future<dio.Response> removeTeamMembers({ required List<User> teamMembers }) {

    if(store == null) throw Exception('The store must be set to remove the team members');

    String url = store!.links.removeTeamMembers.href;

    List<String> mobileNumbers = teamMembers.map((selectedTeamMember) {

      if(selectedTeamMember.attributes.userStoreAssociation!.mobileNumber != null) {
        return selectedTeamMember.attributes.userStoreAssociation!.mobileNumber!.withExtension;
      }else{
        return selectedTeamMember.mobileNumber!.withExtension;
      }

    }).toList();
    
    Map<String, dynamic> body = {
      'mobile_numbers': mobileNumbers,
    };

    return apiRepository.delete(url: url, body: body);
    
  }

  /// Check the user invitations on the specified store
  Future<dio.Response> checkStoreInvitationsToJoinTeam() {

    String url = homeApiLinks.checkInvitationsToJoinTeamStores;

    return apiRepository.get(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<dio.Response> acceptInvitationToJoinTeam() {

    if(store == null) throw Exception('The store must be set to accept invitation to join team');

    String url = store!.links.acceptInvitationToJoinTeam.href;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<dio.Response> declineInvitationToJoinTeam() {

    if(store == null) throw Exception('The store must be set to decline invitation to join team');

    String url = store!.links.declineInvitationToJoinTeam.href;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<dio.Response> acceptAllInvitationsToJoinTeam() {

    String url = homeApiLinks.acceptAllInvitationsToJoinTeamStores;

    return apiRepository.post(url: url);
    
  }

  /// Accept invitation to follow specified store
  Future<dio.Response> declineAllInvitationsToJoinTeam() {

    String url = homeApiLinks.declineAllInvitationsToJoinTeamStores;

    return apiRepository.post(url: url);
    
  }

  ///////////////////////////////////
  ///   REVIEWS                  ///
  //////////////////////////////////

  /// Get the review filters of the specified store
  Future<dio.Response> showReviewFilters() {

    if(store == null) throw Exception('The store must be set to show the review filters');

    String url = store!.links.showReviewFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the reviews of the specified store
  Future<dio.Response> showReviews({ required String? filter, int? userId, bool withUser = false, String searchWord = '', int page = 1 }) {

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

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the review rating options of the specified store
  Future<dio.Response> showReviewRatingOptions() {

    if(store == null) throw Exception('The store must be set to show review rating options');

    String url = store!.links.showReviewRatingOptions.href;
    return apiRepository.get(url: url);
    
  }

  /// Create a review on the specified store
  Future<dio.Response> createReview({ required String subject, String? comment, required int rating }) {

    if(store == null) throw Exception('The store must be set to create a review');

    String url = store!.links.createReviews.href;
    
    Map<String, dynamic> body = {
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
  Future<dio.Response> addStoreToFriendGroups({ required List<FriendGroup> friendGroups }) {

    if(store == null) throw Exception('The store must be set to add to friend groups');

    String url = store!.links.addToFriendGroups.href;

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map<String, dynamic> body = {
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Remove store from friend group
  Future<dio.Response> removeStoreFromFriendGroups({ required List<int> friendGroupIds }) {

    if(store == null) throw Exception('The store must be set to remove from friend group');

    String url = store!.links.removeFromFriendGroups.href;
    
    Map<String, dynamic> body = {
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.delete(url: url, body: body);
    
  }

  /// Add the specified store to the brand stores
  Future<dio.Response> addToBrandStores() {

    if(store == null) throw Exception('The store must be set to add to brand stores');

    String url = store!.links.addToBrandStores.href;

    return apiRepository.post(url: url);
    
  }

  /// Remove the specified store from the brand stores
  Future<dio.Response> removeFromBrandStores() {

    if(store == null) throw Exception('The store must be set to remove from brand stores');

    String url = store!.links.removeFromBrandStores.href;

    return apiRepository.post(url: url);
    
  }

  /// Add or remove the specified store from the brand stores
  Future<dio.Response> addOrRemoveFromBrandStores() {

    if(store == null) throw Exception('The store must be set to add or remove from brand stores');

    String url = store!.links.addOrRemoveFromBrandStores.href;

    return apiRepository.post(url: url);
    
  }

  /// Add the specified store to the influencer stores
  Future<dio.Response> addToInfluencerStores() {

    if(store == null) throw Exception('The store must be set to add to influencer stores');

    String url = store!.links.addToInfluencerStores.href;

    return apiRepository.post(url: url);
    
  }

  /// Remove the specified store from the influencer stores
  Future<dio.Response> removeFromInfluencerStores() {

    if(store == null) throw Exception('The store must be set to remove from influencer stores');

    String url = store!.links.removeFromBrandStores.href;

    return apiRepository.post(url: url);
    
  }

  /// Update the assigned store arrangement
  Future<dio.Response> updateAssignedStoresArrangement({ required List storeIds }) {

    String url = homeApiLinks.updateAssignedStoresArrangement;
    
    Map<String, dynamic> body = {'arrangement': storeIds};

    return apiRepository.post(url: url, body: body);
    
  }


  /// Add the specified store to the assigned stores
  Future<dio.Response> addToAssignedStores() {

    if(store == null) throw Exception('The store must be set to add to assigned stores');

    String url = store!.links.addToAssignedStores.href;

    return apiRepository.post(url: url);
    
  }

  /// Remove the specified store from the assigned stores
  Future<dio.Response> removeFromAssignedStores() {

    if(store == null) throw Exception('The store must be set to remove from assigned stores');

    String url = store!.links.removeFromAssignedStores.href;

    return apiRepository.post(url: url);
    
  }

  /// Add or remove the specified store from the assigned stores
  Future<dio.Response> addOrRemoveFromAssignedStores() {

    if(store == null) throw Exception('The store must be set to add or remove from assigned stores');

    String url = store!.links.addOrRemoveFromAssignedStores.href;

    return apiRepository.post(url: url);
    
  }

  /// Add or remove the specified store from the influencer stores
  Future<dio.Response> addOrRemoveFromInfluencerStores() {

    if(store == null) throw Exception('The store must be set to add or remove from influencer stores');

    String url = store!.links.addOrRemoveFromInfluencerStores.href;

    return apiRepository.post(url: url);
    
  }

  ///////////////////////////////////
  ///   SHOPPING CART            ///
  //////////////////////////////////

  /// Show the shopping cart order for options
  Future<dio.Response> showShoppingCartOrderForOptions() {

    if(store == null) throw Exception('The store must be set to show the shopping cart order for options');

    String url = store!.links.showShoppingCartOrderForOptions.href;

    return apiRepository.get(url: url);
    
  }

  /// Show the shopping cart order for total users (customer & friends)
  Future<dio.Response> countShoppingCartOrderForUsers({ required String orderFor, required List<User> friends, required List<FriendGroup> friendGroups }) {

    if(store == null) throw Exception('The store must be set to show the shopping cart order for total friends');

    String url = store!.links.countShoppingCartOrderForUsers.href;

    List<int> friendUserIds = friends.map((friend) {
        return friend.id;
    }).toList();

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map<String, dynamic> body = {
      'order_for': orderFor,
      'friend_user_ids': friendUserIds,
      'friend_group_ids': friendGroupIds,
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Show the shopping cart order for users (customer & friends)
  Future<dio.Response> showShoppingCartOrderForUsers({ required String orderFor, required List<User> friends, required List<FriendGroup> friendGroups, String searchWord = '', int page = 1 }) {

    if(store == null) throw Exception('The store must be set to show the shopping cart order for friends');

    String url = store!.links.showShoppingCartOrderForUsers.href;

    List<int> friendUserIds = friends.map((friend) {
        return friend.id;
    }).toList();

    List<int> friendGroupIds = friendGroups.map((friendGroup) {
        return friendGroup.id;
    }).toList();
    
    Map<String, dynamic> body = {
      'order_for': orderFor,
      'friend_user_ids': friendUserIds,
      'friend_group_ids': friendGroupIds,
    };

    Map<String, String> queryParams = {};

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    /// Page
    queryParams.addAll({'page': page.toString()});

    return apiRepository.post(url: url, body: body, queryParams: queryParams);
    
  }


  ///////////////////////////////////
  ///   SHARABLE CONTENT          ///
  //////////////////////////////////

  /// Get the sharable content of the specified store
  Future<dio.Response> showSharableContent() {

    if(store == null) throw Exception('The store must be set to show sharable content');

    String url = store!.links.showSharableContent.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the sharable content choices of the specified store
  Future<dio.Response> showSharableContentChoices() {

    if(store == null) throw Exception('The store must be set to show sharable content choices');

    String url = store!.links.showSharableContentChoices.href;

    return apiRepository.get(url: url);
    
  }

  /// Inspect the shopping cart
  Future<dio.Response> inspectShoppingCart({ List<Product> products = const [], List<String> cartCouponCodes = const [], DeliveryDestination? deliveryDestination }) {

    if(store == null) throw Exception('The store must be set to inspect the shopping cart');

    String url = store!.links.inspectShoppingCart.href;
    
    Map<String, dynamic> body = {
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
  Future<dio.Response> convertShoppingCart({ 
    required String orderFor, required List<User> friends, required List<FriendGroup> friendGroups, 
    List<Product> products = const [], List<String> cartCouponCodes = const [], 
    CollectionType? collectionType, PickupDestination? pickupDestination, 
    DeliveryDestination? deliveryDestination, Address? addressForDelivery,
    Occasion? occasion, String? specialNote,
  }) {

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
    
    Map<String, dynamic> body = {
      'order_for': orderFor,
      'cart_products': cartProducts,
      'friend_user_ids': friendUserIds,
      'friend_group_ids': friendGroupIds,
      'cart_coupon_codes': cartCouponCodes,
    };

    if(occasion != null) body.addAll({'occasion_id': occasion.id});
    if(collectionType != null) body.addAll({'collection_type': collectionType.name});
    if(addressForDelivery != null) body.addAll({'address_id': addressForDelivery.id});
    if(specialNote != null && specialNote.isNotEmpty) body.addAll({'specialNote': specialNote});
    if(pickupDestination != null) body.addAll({'pickup_destination_name': pickupDestination.name});
    if(deliveryDestination != null) body.addAll({'delivery_destination_name': deliveryDestination.name});

    return apiRepository.post(url: url, body: body);
    
  }

}