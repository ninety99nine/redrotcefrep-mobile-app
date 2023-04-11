import '../repositories/address_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:flutter/material.dart';
import './../models/address.dart';

/// The AddressProvider is strictly responsible for maintaining the state 
/// of the address. This state can then be shared with the rest of the 
/// application. Address related requests are managed by the 
/// AddressRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class AddressProvider with ChangeNotifier {
  
  Address? _address;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  AddressProvider({ required this.apiProvider });

  /// Return the address
  Address? get address => _address;

  /// Return the Address Repository
  AddressRepository get addressRepository => AddressRepository(address: address, apiProvider: apiProvider);

  /// Set the specified address
  AddressProvider setAddress(Address address) {
    _address = address;
    return this;
  }
}