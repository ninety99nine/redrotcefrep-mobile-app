import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import '../../notifications/models/notification.dart';
import '../../../../../core/shared_models/user.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;

class NotificationRepository {

  /// The notification does not exist until it is set.
  final Notification? notification;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final AuthProvider authProvider;

  /// Constructor: Set the provided notification and Auth Provider
  NotificationRepository({ this.notification, required this.authProvider });

  /// Get the Auth User
  User get user => authProvider.user!;

  /// Get the Api Provider required to enable requests with the set Bearer Token
  ApiProvider get apiProvider => authProvider.apiProvider;

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Mark notifications as read
  Future<dio.Response> markNotificationsAsRead() {

    final url = user.links.markNotificationsAsRead.href;

    return apiRepository.post(url: url);
    
  }

  /// Mark specified notification as read
  Future<dio.Response> markNotificationAsRead() {

    if(notification == null) throw Exception('The notification must be set to mark the notification as read');
    
    final url = notification!.links.markAsRead.href;

    return apiRepository.post(url: url);
    
  }

}