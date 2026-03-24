import '../entities/notification_payload.dart';

abstract class NotificationService {
  /// One-time initialization. Must be called before runApp().
  Future<void> initialize();

  /// Request notification permission from the OS. Returns true if granted.
  Future<bool> requestPermission();

  /// Whether permission has already been requested (regardless of outcome).
  bool get hasRequestedPermission;

  /// Route string set when the user taps a notification with a deep link.
  String? get pendingRoute;

  /// Clear the pending route after it has been consumed by navigation.
  void clearPendingRoute();

  /// Stream of notification taps from foreground local notifications.
  Stream<NotificationPayload> get onNotificationTap;
}
