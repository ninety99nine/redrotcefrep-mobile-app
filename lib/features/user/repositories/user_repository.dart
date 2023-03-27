import 'package:bonako_demo/features/stores/enums/store_enums.dart';

import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import '../../../core/shared_models/user.dart';
import 'package:http/http.dart' as http;

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
  Future<http.Response> showOrderFilters() {

    if(user == null) throw Exception('The user must be set to show order filters');

    String url = user!.links.showOrderFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the orders of the specified user
  Future<http.Response> showOrders({ String? filter, int? userId, int? exceptOrderId, int? startAtOrderId, bool withCustomer = false, bool withStore = false, String searchWord = '', int page = 1 }) {

    if(user == null) throw Exception('The user must be set to show orders');

    String url = user!.links.showOrders.href;

    Map<String, String> queryParams = {};

    if(withStore) queryParams.addAll({'withStore': '1'});

    if(withCustomer) queryParams.addAll({'withCustomer': '1'});

    /// Filter orders by the specified user id
    if(userId != null) queryParams.addAll({'user_id': userId.toString()});

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

}