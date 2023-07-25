import '../repositories/transaction_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

/// The TransactionProvider is strictly responsible for maintaining the state 
/// of the transaction. This state can then be shared with the rest of the 
/// application. Transaction related requests are managed by the 
/// TransactionRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class TransactionProvider with ChangeNotifier {
  
  Transaction? _transaction;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  TransactionProvider({ required this.apiProvider });

  /// Return the transaction
  Transaction? get transaction => _transaction;

  /// Return the Transaction Repository
  TransactionRepository get transactionRepository => TransactionRepository(transaction: transaction, apiProvider: apiProvider);

  /// Set the specified transaction
  TransactionProvider setTransaction(Transaction transaction) {
    _transaction = transaction;
    return this;
  }
}