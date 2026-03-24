import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/features/notifications/data/services/notification_service_impl.dart';

// Note: Full integration testing of NotificationServiceImpl requires
// Firebase and FlutterLocalNotificationsPlugin to be initialized, which
// requires platform channels. These tests cover the pure-Dart logic only.
//
// For FCM end-to-end testing, use the FCM test console:
//   https://console.firebase.google.com/project/YOUR_PROJECT/messaging
// with payload: {"data": {"route": "/wallpaper/test123"}}

void main() {
  group('NotificationServiceImpl — pendingRoute logic', () {
    test('pendingRoute is null before initialization', () {
      final service = NotificationServiceImpl();
      expect(service.pendingRoute, isNull);
    });

    test('clearPendingRoute sets pendingRoute to null', () {
      final service = NotificationServiceImpl();
      // Directly exercise clearPendingRoute when already null — should be safe
      expect(() => service.clearPendingRoute(), returnsNormally);
      expect(service.pendingRoute, isNull);
    });

    test('hasRequestedPermission defaults to false before init', () {
      final service = NotificationServiceImpl();
      // Before initialize() is called, _prefsBox is null → defaults false
      expect(service.hasRequestedPermission, isFalse);
    });

    test('dispose closes the tap stream without error', () {
      final service = NotificationServiceImpl();
      expect(() => service.dispose(), returnsNormally);
    });
  });
}
