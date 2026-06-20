import '../entities/notification_entity.dart';

abstract class NotificationService {
  /// One-time initialization. Must be called after Firebase init, before runApp().
  Future<void> initialize();

  /// Request notification permission from the OS. Returns true if granted.
  Future<bool> requestPermission();

  /// Current device FCM registration token, or null if unavailable.
  Future<String?> getFcmToken();

  /// Stream of refreshed FCM tokens (platform rotates the token over time).
  Stream<String> get onTokenRefresh;

  /// Whether permission has already been requested (regardless of outcome).
  bool get hasRequestedPermission;

  /// Notification that launched the app from a terminated state, if any.
  /// Consumed once via [clearInitialNotification] after the app is initialized.
  NotificationEntity? get initialNotification;

  /// Clear the initial (terminated-launch) notification after it is consumed.
  void clearInitialNotification();

  /// Stream of notification taps (foreground local taps + background opens).
  Stream<NotificationEntity> get onNotificationTap;

  /// Release streams and resources.
  Future<void> dispose();
}
