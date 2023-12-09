import 'package:bonako_demo/core/utils/stream_utility.dart';
import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:bonako_demo/features/reviews/enums/review_enums.dart';
import 'package:bonako_demo/features/sms_alert/models/sms_alert_activity_association.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import '../../../core/shared_models/user.dart';
import 'package:dio/dio.dart' as dio;

class UserRepository {

  /// The user does not exist until it is set.
  final User? user;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  UserRepository({ this.user, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Get the order filters of the specified user
  Future<dio.Response> showOrderFilters({ required UserOrderAssociation userOrderAssociation }) {
 
    if(user == null) throw Exception('The user must be set to show order filters');

    String url = user!.links.showOrderFilters.href;

    Map<String, String> queryParams = {};
    
    /// Extract orders by the specified user order association
    queryParams.addAll({'userOrderAssociation': userOrderAssociation.name});

    print(queryParams);

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the orders of the specified user
  Future<dio.Response> showOrders({ String? filter, required UserOrderAssociation userOrderAssociation, int? startAtOrderId, int? storeId, bool withStore = false, bool withCustomer = false, bool withOccasion = false, String searchWord = '', int page = 1 }) {

    if(user == null) throw Exception('The user must be set to show orders');

    String url = user!.links.showOrders.href;

    Map<String, String> queryParams = {};

    if(withStore) queryParams.addAll({'withStore': '1'});

    if(withCustomer) queryParams.addAll({'withCustomer': '1'});

    if(withOccasion) queryParams.addAll({'withOccasion': '1'});
    
    /// Extract orders by the specified user order association
    queryParams.addAll({'userOrderAssociation': userOrderAssociation.name});

    /// Only orders matching the specified store id
    if(storeId != null) queryParams.addAll({'store_id': storeId.toString()});

    /// Include orders after the specified order id
    if(startAtOrderId != null) queryParams.addAll({'start_at_order_id': startAtOrderId.toString()});
    
    /// Filter orders by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});

    /// Page
    queryParams.addAll({'page': page.toString()});
    
    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the review filters of the specified user
  Future<dio.Response> showReviewFilters({ required UserReviewAssociation userReviewAssociation }) {

    if(user == null) throw Exception('The user must be set to show review filters');

    String url = user!.links.showReviewFilters.href;

    Map<String, String> queryParams = {};
    
    /// Extract reviews by the specified user review association
    queryParams.addAll({'userReviewAssociation': userReviewAssociation.name});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }
  
  /// Get the reviews of the specified user
  Future<dio.Response> showReviews({ String? filter, required UserReviewAssociation userReviewAssociation, bool withStore = false, bool withUser = false, String searchWord = '', int page = 1 }) {

    if(user == null) throw Exception('The user must be set to show reviews');

    String url = user!.links.showReviews.href;

    Map<String, String> queryParams = {};

    if(withUser) queryParams.addAll({'withUser': '1'});

    if(withStore) queryParams.addAll({'withStore': '1'});
    
    /// Extract reviews by the specified user review association
    queryParams.addAll({'userReviewAssociation': userReviewAssociation.name});

    /// Page
    queryParams.addAll({'page': page.toString()});
    
    /// Filter reviews by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});
    
      print('queryParams');
      print(queryParams);
    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Create user address
  Future<dio.Response> createAddress({ required String name, required String addressLine }){

    if(user == null) throw Exception('The user must be set to show addresses');

    String url = user!.links.createAddresses.href;

    Map<String, dynamic> body = {
      'name': name,
      'addressLine': addressLine
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Show the user addresses
  Future<dio.Response> showAddresses({ String searchWord = '', int page = 1 }){

    if(user == null) throw Exception('The user must be set to show addresses');

    String url =  user!.links.showAddresses.href;
    
    Map<String, String> queryParams = {};

    /// Page
    queryParams.addAll({'page': page.toString()});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Show the user AI Assistant
  Future<dio.Response> showAiAssistant() {

    if(user == null) throw Exception('The user must be set to show AI Assistant');

    String url =  user!.links.showAiAssistant.href;

    return apiRepository.get(url: url);
    
  }


  /// Generate a payment shortcode for the AI Assistant
  Future<dio.Response> generateAiAssistantPaymentShortcode() {

    if(user == null) throw Exception('The user must be set to generate a payment shortcode');

    String url = user!.links.generateAiAssistantPaymentShortcode.href;

    return apiRepository.post(url: url);

  }

  /// Create user AI Message
  Future<dio.Response> createAiMessage({ required int categoryId, required String userContent, required StreamUtility streamUtility }){

    if(user == null) throw Exception('The user must be set to create AI message');

    String url = user!.links.createAiMessages.href;

    Map<String, dynamic> body = {
      'userContent': userContent,
      'categoryId': categoryId,
      'stream': true
    };

    return apiRepository.post(url: url, body: body, streamUtility: streamUtility, stream: true);
    
  }

  /// Show the user AI Messages
  Future<dio.Response> showAiMessages({ required int categoryId, String searchWord = '', int page = 1 }){

    if(user == null) throw Exception('The user must be set to show AI messages');

    String url =  user!.links.showAiMessages.href;
    
    Map<String, String> queryParams = {};

    /// Get the AI Messages matching the specified category id
    queryParams.addAll({'categoryId': categoryId.toString()});

    /// Page
    queryParams.addAll({'page': page.toString()});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Show the user SMS Alert
  Future<dio.Response> showSmsAlert() {

    if(user == null) throw Exception('The user must be set to show SMS Alert');

    String url =  user!.links.showSmsAlert.href;

    return apiRepository.get(url: url);
    
  }

  /// Generate a payment shortcode for the Sms Alert
  Future<dio.Response> generateSmsAlertPaymentShortcode() {

    if(user == null) throw Exception('The user must be set to generate a payment shortcode');

    String url = user!.links.generateSmsAlertPaymentShortcode.href;

    return apiRepository.post(url: url);

  }
  
  /// Update sms alert activity association
  Future<dio.Response> updateSmsAlertActivityAssociation({ required SmsAlertActivityAssociation smsAlertActivityAssociation, required bool enabled, List<int> storeIds = const [] }){

    if(user == null) throw Exception('The user must be set to update the sms alert activity association');

    String url = smsAlertActivityAssociation.links.updateSmsAlertActivityAssociation.href;

    Map<String, dynamic> body = {
      'enabled': enabled,
    };

    body['storeIds'] = storeIds;

    return apiRepository.put(url: url, body: body);
    
  }

  /// Show first created store
  Future<dio.Response> showFirstCreatedStore({ bool withVisibleProducts = false, bool withCountProducts = false, bool withCountFollowers = false, bool withVisitShortcode = false, bool withCountTeamMembers = false, bool withCountReviews = false, bool withCountOrders = false, bool withCountCollectedOrders = false, withCountCoupons = false, bool withRating = false }) {

    if(user == null) throw Exception('The user must be set to show their first created store');

    String url = user!.links.showFirstCreatedStore.href;

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
    if(withCountCollectedOrders) queryParams.addAll({'withCountCollectedOrders': '1'});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Join a store
  Future<dio.Response> joinStore({ required String teamMemberJoinCode }){

    if(user == null) throw Exception('The user must be set to join a store');

    String url = user!.links.joinStores.href;

    Map<String, dynamic> body = {
      'team_member_join_code': teamMemberJoinCode
    };

    return apiRepository.post(url: url, body: body);
    
  }

  /// Show first created group
  Future<dio.Response> showFirstCreatedFriendGroup() {

    if(user == null) throw Exception('The user must be set to show their first created friend group');

    String url = user!.links.showFirstCreatedFriendGroup.href;

    Map<String, String> queryParams = {};

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

}