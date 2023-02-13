import '../repositories/order_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';

/// The OrderProvider is strictly responsible for maintaining the state 
/// of the order. This state can then be shared with the rest of the 
/// application. Order related requests are managed by the 
/// OrderRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class OrderProvider with ChangeNotifier {
  
  Order? _order;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  OrderProvider({ required this.apiProvider });

  /// Return the order
  Order? get order => _order;

  /// Return the Order Repository
  OrderRepository get orderRepository => OrderRepository(order: order, apiProvider: apiProvider);

  /// Set the specified order
  OrderProvider setOrder(Order order) {
    _order = order;
    return this;
  }
}