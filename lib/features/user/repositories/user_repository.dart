import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import '../../../core/shared_models/user.dart';
import 'package:http/http.dart' as http;

class UserRepository {

  /// The user does not exist until it is set.
  final User? user;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  UserRepository({ this.user, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Get the orders of the specified user
  Future<http.Response> showOrders({ String searchWord = '', int page = 1 }) {

    if(user == null) throw Exception('The user must be set to show orders');

    String url = user!.links.showOrders!.href;

    Map<String, String> queryParams = {};

    /// Filter by search
    if(searchWord.isNotEmpty) queryParams.addAll({'search': searchWord});
    
    return apiRepository.get(url: url, page: page, queryParams: queryParams);
    
  }

}