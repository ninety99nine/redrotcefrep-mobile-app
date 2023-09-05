import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;
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
  Future<dio.Response> showOrder({ bool withCart = false, bool withCustomer = false, bool withDeliveryAddress = false, bool withOccasion = false, bool withPaymentMethod = false, bool withCountTransactions = false, bool withTransactions = false }) {
    
    if(order == null) throw Exception('The order must be set to show this order');

    String url = order!.links.self.href;

    Map<String, String> queryParams = {};
    if(withCart) queryParams.addAll({'withCart': '1'});
    if(withCustomer) queryParams.addAll({'withCustomer': '1'});
    if(withOccasion) queryParams.addAll({'withOccasion': '1'});
    if(withTransactions) queryParams.addAll({'withTransactions': '1'});
    if(withPaymentMethod) queryParams.addAll({'withPaymentMethod': '1'});
    if(withDeliveryAddress) queryParams.addAll({'withDeliveryAddress': '1'});
    if(withCountTransactions) queryParams.addAll({'withCountTransactions': '1'});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Show the specified order cart
  Future<dio.Response> showOrderCart() {
    
    if(order == null) throw Exception('The order must be set to show this order cart');

    String url = order!.links.showCart.href;

    Map<String, String> queryParams = {};

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Show the specified order customer
  Future<dio.Response> showOrderCustomer() {
    
    if(order == null) throw Exception('The order must be set to show this order customer');

    String url = order!.links.showCustomer.href;

    Map<String, String> queryParams = {};

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Show the specified order occasion
  Future<dio.Response> showOrderOccasion() {
    
    if(order == null) throw Exception('The order must be set to show this order occasion');

    String url = order!.links.showOccasion.href;

    Map<String, String> queryParams = {};

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Show the specified order delivery address
  Future<dio.Response> showOrderDeliveryAddress() {
    
    if(order == null) throw Exception('The order must be set to show this order delivery address');

    String url = order!.links.showDeliveryAddress.href;

    Map<String, String> queryParams = {};

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Generate the collection code
  Future<dio.Response> generateCollectionCode() {
    
    if(order == null) throw Exception('The order must be set to generate the collection code');

    String url = order!.links.generateCollectionCode.href;

    return apiRepository.post(url: url);
    
  }

  /// Revoke the collection code
  Future<dio.Response> revokeCollectionCode() {
    
    if(order == null) throw Exception('The order must be set to revoke the collection code');

    String url = order!.links.revokeCollectionCode.href;

    return apiRepository.post(url: url);
    
  }

  /// Update the status of the specified order
  Future<dio.Response> updateStatus({ required String status, String? collectionCode, bool withCart = false, bool withCustomer = false, bool withDeliveryAddress = false, bool withPaymentMethod = false, bool withCountTransactions = false, bool withTransactions = false }) {
    
    if(order == null) throw Exception('The order must be set to update status');

    String url = order!.links.updateStatus.href;

    Map<String, String> queryParams = {};
    if(withCart) queryParams.addAll({'withCart': '1'});
    if(withCustomer) queryParams.addAll({'withCustomer': '1'});
    if(withTransactions) queryParams.addAll({'withTransactions': '1'});
    if(withPaymentMethod) queryParams.addAll({'withPaymentMethod': '1'});
    if(withDeliveryAddress) queryParams.addAll({'withDeliveryAddress': '1'});
    if(withCountTransactions) queryParams.addAll({'withCountTransactions': '1'});

    Map<String, dynamic> body = {
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
  Future<dio.Response> showViewers({ String searchWord = '', int page = 1 }) {
    
    if(order == null) throw Exception('The order must be set to show viewers');

    String url = order!.links.showViewers.href;

    Map<String, String> queryParams = {};

    queryParams.addAll({'page': page.toString()}); 
      
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Request payment for the specified order
  Future<dio.Response> requestPayment({ required int percentage }) {

    if(order == null) throw Exception('The order must be set to request payment');

    String url = order!.links.requestPayment.href;
    
    Map<String, dynamic> body = {
      'percentage': percentage,
    };
    
    return apiRepository.post(url: url, body: body);
    
  }

  ///////////////////////////////////
  ///   TRANSACTIONS              ///
  //////////////////////////////////

  /// Show the specified order transactions count
  Future<dio.Response> showOrderTransactionsCount() {
    
    if(order == null) throw Exception('The order must be set to show this order transactions count');

    String url = order!.links.showTransactionsCount.href;

    Map<String, String> queryParams = {};

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Get the transaction filters of the specified order
  Future<dio.Response> showTransactionFilters() {

    if(order == null) throw Exception('The order must be set to show transaction filters');

    String url = order!.links.showTransactionFilters.href;

    return apiRepository.get(url: url);
    
  }

  /// Get the transactions of the specified order
  Future<dio.Response> showTransactions({ String? filter, bool withRequestingUser = false, bool withPayingUser = false, String searchWord = '', int page = 1 }) {

    if(order == null) throw Exception('The order must be set to show transactions');

    String url = order!.links.showTransactions.href;

    Map<String, String> queryParams = {};

    /// Page
    queryParams.addAll({'page': page.toString()}); 
      
    /// Filter transactions by the specified status
    if(filter != null) queryParams.addAll({'filter': filter});

    if(withRequestingUser) queryParams.addAll({'withPayingUser': '1'});
    if(withRequestingUser) queryParams.addAll({'withRequestingUser': '1'});
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }


  ///////////////////////////////////
  ///   PAYMENTS                 ///
  //////////////////////////////////

  /// Mark the specified order as paid
  Future<dio.Response> markAsUnverifiedPayment({ int? percentage, String? amount, required paymentMethodId }) {
    
    if(order == null) throw Exception('The order must be set to mark as paid');

    String url = order!.links.markAsUnverifiedPayment.href;
    
    Map<String, dynamic> body = {
      'payment_method_id': paymentMethodId,
    };

    if(percentage != null) {
      body['percentage'] = percentage;
    }else if(amount != null) {
      body['amount'] = amount;
    }else{
      throw Exception('Provide the transaction percentage or amount');
    }

    return apiRepository.post(url: url, body: body);
    
  }
}