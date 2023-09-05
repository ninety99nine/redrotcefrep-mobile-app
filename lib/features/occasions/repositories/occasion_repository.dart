import '../../api/models/api_home.dart' as api_home;
import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;
import '../models/occasion.dart';

class OccasionRepository {

  /// The occasion does not exist until it is set.
  final Occasion? occasion;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  OccasionRepository({ this.occasion, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Get the Api Home links required to perform requests to using the routes
  api_home.Links get homeApiLinks => apiProvider.apiHome!.links;

  /// Show the occasion
  Future<dio.Response> showOccasions() {

    String url = homeApiLinks.showOccasions;
    
    return apiRepository.get(url: url);
    
  }

}