import '../../api/repositories/api_repository.dart';
import '../../api/models/api_home.dart' as api_home;
import '../../api/providers/api_provider.dart';
import 'package:http/http.dart' as http;

class SearchRepository {

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  SearchRepository({ required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Get the Api Home links required to perform requests to using the routes
  api_home.Links get homeApiLinks => apiProvider.apiHome!.links;

  /// Show the search filters
  Future<http.Response> showSearchMenus() {

    String url = homeApiLinks.showSearchMenus;

    return apiRepository.get(url: url);
    
  }

  /// Search stores
  Future<http.Response> searchStores({ String searchWord = '', int? page = 1}) {

    String url = homeApiLinks.showSearchStores;

    Map<String, String> queryParams = {};

    queryParams.addAll({'withRating': '1'});
    queryParams.addAll({'withCountOrders': '1'});
    queryParams.addAll({'withCountReviews': '1'});

    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Search stores
  Future<http.Response> searchFriends({ String searchWord = '', int? page = 1}) {

    String url = homeApiLinks.showSearchFriends;

    Map<String, String> queryParams = {};

    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

  /// Search stores
  Future<http.Response> searchFriendGroups({ String searchWord = '', int? page = 1}) {

    String url = homeApiLinks.showSearchFriendGroups;

    Map<String, String> queryParams = {};

    queryParams.addAll({'withCountUsers': '0'});
    queryParams.addAll({'withCountFriends': '1'});

    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord}); 

    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

}