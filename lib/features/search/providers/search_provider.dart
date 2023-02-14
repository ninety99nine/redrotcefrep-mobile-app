import '../repositories/search_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:flutter/material.dart';

/// The SearchProvider is strictly responsible for maintaining the state 
/// of the search. This state can then be shared with the rest of the 
/// application. Search related requests are managed by the 
/// SearchRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class SearchProvider with ChangeNotifier {
  
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  SearchProvider({ required this.apiProvider });

  /// Return the Search Repository
  SearchRepository get searchRepository => SearchRepository(apiProvider: apiProvider);
}