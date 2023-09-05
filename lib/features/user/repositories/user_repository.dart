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
  Future<dio.Response> showOrderFilters() {

    if(user == null) throw Exception('The user must be set to show order filters');

    String url = user!.links.showOrderFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the orders of the specified user
  Future<dio.Response> showOrders({ String? filter, int? customerUserId, int? friendUserId, int? exceptOrderId, int? startAtOrderId, int? storeId, bool withStore = false, bool withCustomer = false, bool withOccasion = false, String searchWord = '', int page = 1 }) {

    if(user == null) throw Exception('The user must be set to show orders');

    String url = user!.links.showOrders.href;

    Map<String, String> queryParams = {};

    if(withStore) queryParams.addAll({'withStore': '1'});

    if(withCustomer) queryParams.addAll({'withCustomer': '1'});

    if(withOccasion) queryParams.addAll({'withOccasion': '1'});

    /// Filter orders by the specified friend user id
    if(friendUserId != null) queryParams.addAll({'friend_user_id': friendUserId.toString()});

    /// Filter orders by the specified customer user id
    if(customerUserId != null) queryParams.addAll({'customer_user_id': customerUserId.toString()});

    /// Exclude specific orders matching the specified order id
    if(exceptOrderId != null) queryParams.addAll({'except_order_id': exceptOrderId.toString()});

    /// Include orders after the specified order id
    if(startAtOrderId != null) queryParams.addAll({'start_at_order_id': startAtOrderId.toString()});

    /// Only orders matching the specified store id
    if(storeId != null) queryParams.addAll({'store_id': storeId.toString()});

    /// Page
    queryParams.addAll({'page': page.toString()});
    
    /// Filter orders by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});
    
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

  /// Join a store
  Future<dio.Response> joinStore({ required String teamMemberJoinCode }){

    if(user == null) throw Exception('The user must be set to join a store');

    String url = user!.links.joinStores.href;

    Map<String, dynamic> body = {
      'team_member_join_code': teamMemberJoinCode
    };

    return apiRepository.post(url: url, body: body);
    
  }

}