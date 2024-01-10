import '../../authentication/providers/auth_provider.dart';
import '../repositories/notification_repository.dart';
import '../models/notification.dart' as model;
import 'package:flutter/material.dart';

/// The NotificationProvider is strictly responsible for maintaining the state 
/// of the notification. This state can then be shared with the rest of the 
/// application. Notification related requests are managed by the 
/// NotificationRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the AuthProvider
class NotificationProvider with ChangeNotifier {
  
  model.Notification? _notification;
  final AuthProvider authProvider;

  /// Constructor: Set the provided Api Provider
  NotificationProvider({ required this.authProvider });

  /// Return the notification
  model.Notification? get notification => _notification;

  /// Return the Notification Repository
  NotificationRepository get notificationRepository => NotificationRepository(notification: notification, authProvider: authProvider);

  /// Set the specified notification
  NotificationProvider setNotification(model.Notification notification) {
    _notification = notification;
    return this;
  }
}