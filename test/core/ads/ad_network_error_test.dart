import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/ads/ad_network_error.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// [AdError]'s constructor is @protected — a tiny subclass lets tests
/// fabricate errors without touching the live SDK.
class _TestAdError extends AdError {
  _TestAdError(super.code, super.domain, super.message);
}

void main() {
  group('AdNetworkError.isNetworkError', () {
    test('returns true for error code 2 (ERROR_CODE_NETWORK_ERROR)', () {
      final error = _TestAdError(2, 'com.google.android.gms.ads', 'No fill');
      expect(AdNetworkError.isNetworkError(error), isTrue);
    });

    test('returns true when message mentions network', () {
      final error = _TestAdError(1, 'com.google.admob', 'Network error.');
      expect(AdNetworkError.isNetworkError(error), isTrue);
    });

    test('returns true when message mentions internet', () {
      final error = _TestAdError(9, 'com.google.admob', 'No internet access');
      expect(AdNetworkError.isNetworkError(error), isTrue);
    });

    test(
      'returns true when message mentions connection (case-insensitive)',
      () {
        final error = _TestAdError(11, 'com.google.admob', 'CONNECTION lost');
        expect(AdNetworkError.isNetworkError(error), isTrue);
      },
    );

    test('returns true when message mentions offline', () {
      final error = _TestAdError(1, 'com.google.admob', 'Device is offline');
      expect(AdNetworkError.isNetworkError(error), isTrue);
    });

    test('returns true when request timed out', () {
      final error = _TestAdError(1, 'com.google.admob', 'Request timed out');
      expect(AdNetworkError.isNetworkError(error), isTrue);
    });

    test('returns false for a non-network failure', () {
      final error = _TestAdError(
        0,
        'com.google.android.gms.ads',
        'Invalid request',
      );
      expect(AdNetworkError.isNetworkError(error), isFalse);
    });

    test('returns false for a no-fill failure', () {
      final error = _TestAdError(3, 'com.google.android.gms.ads', 'No fill.');
      expect(AdNetworkError.isNetworkError(error), isFalse);
    });
  });
}
