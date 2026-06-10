import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/ads/ad_gatekeeper.dart';

void main() {
  group('AdGatekeeper', () {
    test('defaults to showing ads (guest)', () {
      expect(AdGatekeeper().shouldShowAds, isTrue);
    });

    test('can be flipped when the user becomes premium', () {
      final gatekeeper = AdGatekeeper();
      gatekeeper.shouldShowAds = false;
      expect(gatekeeper.shouldShowAds, isFalse);

      gatekeeper.shouldShowAds = true;
      expect(gatekeeper.shouldShowAds, isTrue);
    });
  });
}
