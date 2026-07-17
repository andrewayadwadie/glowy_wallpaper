import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/features/notifications/data/services/notification_service_impl.dart';

// Full integration of NotificationServiceImpl requires Firebase and
// FlutterLocalNotificationsPlugin platform channels. These tests cover the
// pure-Dart logic only.
//
// For FCM end-to-end testing, use the FCM test console with payload:
//   {"data": {"deeplink": "/wallpaper/test123", "imageUrl": "https://..."}}

void main() {
  group('NotificationServiceImpl — state defaults', () {
    test('initialNotification is null before initialization', () {
      final service = NotificationServiceImpl();
      expect(service.initialNotification, isNull);
    });

    test('clearInitialNotification is safe when already null', () {
      final service = NotificationServiceImpl();
      expect(() => service.clearInitialNotification(), returnsNormally);
      expect(service.initialNotification, isNull);
    });

    test('hasRequestedPermission defaults to false before init', () {
      final service = NotificationServiceImpl();
      expect(service.hasRequestedPermission, isFalse);
    });

    test('dispose closes the tap stream without error', () {
      final service = NotificationServiceImpl();
      expect(() => service.dispose(), returnsNormally);
    });
  });

  group('NotificationServiceImpl.validDeeplink — Home fallback (FR-006)', () {
    test('valid route starting with / is returned', () {
      expect(
        NotificationServiceImpl.validDeeplink('/wallpaper/42'),
        '/wallpaper/42',
      );
    });

    test('null returns null', () {
      expect(NotificationServiceImpl.validDeeplink(null), isNull);
    });

    test('malformed link not starting with / returns null', () {
      expect(NotificationServiceImpl.validDeeplink('wallpaper/42'), isNull);
      expect(NotificationServiceImpl.validDeeplink('https://x.com'), isNull);
      expect(NotificationServiceImpl.validDeeplink(''), isNull);
    });
  });
}
