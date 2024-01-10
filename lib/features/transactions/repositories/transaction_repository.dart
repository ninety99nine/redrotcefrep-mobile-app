import '../../api/repositories/api_repository.dart';
import '../../transactions/models/transaction.dart';
import '../../api/providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;

class TransactionRepository {

  /// The transaction does not exist until it is set.
  final Transaction? transaction;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  TransactionRepository({ this.transaction, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Show the specified transaction
  Future<dio.Response> showTransaction({ bool withPayingUser = false, bool withPaymentMethod = false, bool withVerifyingUser = false, bool withRequestingUser = false }) {
    
    if(transaction == null) throw Exception('The transaction must be set to show this transaction');

    String url = transaction!.links.self.href;

    Map<String, String> queryParams = {};
    if(withPayingUser) queryParams.addAll({'withPayingUser': '1'});
    if(withPaymentMethod) queryParams.addAll({'withPaymentMethod': '1'});
    if(withVerifyingUser) queryParams.addAll({'withVerifyingUser': '1'});
    if(withRequestingUser) queryParams.addAll({'withRequestingUser': '1'});

    return apiRepository.get(url: url, queryParams: queryParams);
    
  }

  /// Delete the specified transaction
  Future<dio.Response> deleteTransaction() {

    if(transaction == null) throw Exception('The transaction must be set to delete');
    String url = transaction!.links.deleteTransaction.href;
    return apiRepository.delete(url: url);
    
  }
}