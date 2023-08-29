import '../repositories/occasion_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:flutter/material.dart';
import '../models/occasion.dart';

/// The OccasionProvider is strictly responsible for maintaining the state 
/// of the occasion. This state can then be shared with the rest of the 
/// application. Occasion related requests are managed by the 
/// OccasionRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class OccasionProvider with ChangeNotifier {
  
  Occasion? _occasion;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  OccasionProvider({ required this.apiProvider });

  /// Return the occasion
  Occasion? get occasion => _occasion;

  /// Return the Occasion Repository
  OccasionRepository get occasionRepository => OccasionRepository(occasion: occasion, apiProvider: apiProvider);

  /// Set the specified occasion
  OccasionProvider setOccasion(Occasion occasion) {
    _occasion = occasion;
    return this;
  }
}