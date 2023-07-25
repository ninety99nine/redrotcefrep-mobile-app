import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderRepository {

  /// The order does not exist until it is set.
  final Order? order;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  OrderRepository({ this.order, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Show the specified order
  Future<http.Response> showOrder({ bool withCart = false, bool withCustomer = false, bool withDeliveryAddress = false, bool withCountTransactions = false, bool withTransactions = false }) {
    
    if(order == null) throw Exception('The order must be set to show this order');

    String url = order!.links.self.href;

    Map<String, String> queryParams = {};
    if(withCart) queryParams.addAll({'withCart': '1'});
    if(withCustomer) queryParams.addAll({'withCustomer': '1'});
    if(withTransactions) queryParams.addAll({'withTransactions': '1'});
    if(withDeliveryAddress) queryParams.addAll({'withDeliveryAddress': '1'});
    if(withCountTransactions) queryParams.addAll({'withCountTransactions': '1'});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Generate the collection code
  Future<http.Response> generateCollectionCode() {
    
    if(order == null) throw Exception('The order must be set to generate the collection code');

    String url = order!.links.generateCollectionCode.href;

    return apiRepository.post(url: url);
    
  }

  /// Revoke the collection code
  Future<http.Response> revokeCollectionCode() {
    
    if(order == null) throw Exception('The order must be set to revoke the collection code');

    String url = order!.links.revokeCollectionCode.href;

    return apiRepository.post(url: url);
    
  }

  /// Update the status of the specified order
  Future<http.Response> updateStatus({ required String status, String? collectionCode, bool withCart = false, bool withCustomer = false, bool withTransactions = false }) {
    
    if(order == null) throw Exception('The order must be set to update status');

    String url = order!.links.updateStatus.href;

    Map<String, String> queryParams = {};
    if(withCart) queryParams.addAll({'withCart': '1'});
    if(withCustomer) queryParams.addAll({'withCustomer': '1'});
    if(withTransactions) queryParams.addAll({'withTransactions': '1'});

    Map body = {
      'status': status
    };

    if(collectionCode != null) {
      body.addAll({
        'collection_code': collectionCode
      });
    }

    return apiRepository.put(url: url, body: body, queryParams: queryParams);
    
  }

  /// Show viewers of the specified order
  Future<http.Response> showViewers({ String searchWord = '', int page = 1 }) {
    
    if(order == null) throw Exception('The order must be set to show viewers');

    String url = order!.links.showViewers.href;

    Map<String, String> queryParams = {};
      
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Request payment for the specified order
  Future<http.Response> requestPayment({ required int percentage, required paymentMethodId }) {

    if(order == null) throw Exception('The order must be set to request payment');

    String url = order!.links.requestPayment.href;
    
    Map body = {
      'percentage': percentage,
      'payment_method_id': paymentMethodId,
    };
    
    return apiRepository.post(url: url, body: body);
    
  }

  ///////////////////////////////////
  ///   TRANSACTIONS                 ///
  //////////////////////////////////

  /// Get the transaction filters of the specified order
  Future<http.Response> showTransactionFilters() {

    if(order == null) throw Exception('The order must be set to show transaction filters');

    String url = order!.links.showTransactionFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the transactions of the specified order
  Future<http.Response> showTransactions({ String? filter, bool withRequestingUser = false, bool withPayingUser = false, String searchWord = '', int page = 1 }) {

    if(order == null) throw Exception('The order must be set to show transactions');

    String url = order!.links.showTransactions.href;

    Map<String, String> queryParams = {};
      
    /// Filter transactions by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    /// Filter by search
    if(withRequestingUser) queryParams.addAll({'withPayingUser': '1'});
    if(withRequestingUser) queryParams.addAll({'withRequestingUser': '1'});
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

}