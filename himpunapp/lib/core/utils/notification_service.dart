import 'package:flutter/foundation.dart';

/// Notification service that is web-compatible.
/// On web, local notifications are not supported natively,
/// so we use a simple in-app snackbar approach.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      // On web, we skip native notification initialization
      debugPrint('NotificationService: Running on web, using in-app notifications');
    } else {
      // On mobile platforms, you could initialize flutter_local_notifications here
      debugPrint('NotificationService: Running on mobile platform');
    }
    _initialized = true;
  }

  /// Show a notification - on web, this is a no-op (use ScaffoldMessenger instead)
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      debugPrint('Notification: $title - $body');
    } else {
      debugPrint('Notification: $title - $body');
    }
  }
}
