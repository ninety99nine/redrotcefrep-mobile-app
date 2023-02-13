import '../repositories/store_repository.dart';
import '../../api/providers/api_provider.dart';
import '../models/shoppable_store.dart';
import 'package:flutter/material.dart';

/// The StoreProvider is strictly responsible for maintaining the state 
/// of the store. This state can then be shared with the rest of the 
/// application. Store related requests are managed by the 
/// StoreRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class StoreProvider with ChangeNotifier {
  
  ShoppableStore? _store;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  StoreProvider({ required this.apiProvider });

  /// Return the store
  ShoppableStore? get store => _store;

  /// Return the Store Repository
  StoreRepository get storeRepository => StoreRepository(store: store, apiProvider: apiProvider);

  /// Set the specified store
  StoreProvider setStore(ShoppableStore store) {
    _store = store;
    return this;
  }
}