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

}