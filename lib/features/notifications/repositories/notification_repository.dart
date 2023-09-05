import '../../notifications/models/notification.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;

class NotificationRepository {

  /// The notification does not exist until it is set.
  final Notification? notification;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  NotificationRepository({ this.notification, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Mark notification as read
  Future<dio.Response> markNotificationsAsRead({ required List<String> mobileNumbers }) {

    if(notification == null) throw Exception('The notification must be set to mark the notification as read');
    
    final url =  notification!.links.markAsRead.href;

    return apiRepository.post(url: url);
    
  }

}