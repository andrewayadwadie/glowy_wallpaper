import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/services/aspect_ratio_cache.dart';

void main() {
  setUp(AspectRatioCache.clear);
  tearDown(AspectRatioCache.clear);

  group('AspectRatioCache', () {
    test('returns null for an unknown url', () {
      expect(AspectRatioCache.get('https://example.com/missing.jpg'), isNull);
    });

    test('stores and returns a decoded ratio', () {
      AspectRatioCache.put('https://example.com/a.jpg', 1.5);
      expect(AspectRatioCache.get('https://example.com/a.jpg'), 1.5);
    });

    test('ignores non-positive ratios', () {
      AspectRatioCache.put('https://example.com/zero.jpg', 0);
      AspectRatioCache.put('https://example.com/neg.jpg', -2);
      expect(AspectRatioCache.get('https://example.com/zero.jpg'), isNull);
      expect(AspectRatioCache.get('https://example.com/neg.jpg'), isNull);
    });

    test('evicts the least-recently-used entry past the cap', () {
      // Fill to capacity, then add one more.
      for (var i = 0; i < AspectRatioCache.maxEntries; i++) {
        AspectRatioCache.put('u$i', 1.0 + i / 10000);
      }
      expect(AspectRatioCache.length, AspectRatioCache.maxEntries);

      AspectRatioCache.put('overflow', 2.0);

      expect(AspectRatioCache.length, AspectRatioCache.maxEntries);
      // The oldest ('u0') was evicted; the newest survives.
      expect(AspectRatioCache.get('u0'), isNull);
      expect(AspectRatioCache.get('overflow'), 2.0);
    });

    test('get() promotes an entry so it outlives an untouched peer', () {
      AspectRatioCache.put('a', 1.1);
      AspectRatioCache.put('b', 1.2);
      // Fill the remaining capacity so the cache sits exactly at the cap.
      for (var i = 0; i < AspectRatioCache.maxEntries - 2; i++) {
        AspectRatioCache.put('f$i', 1.0);
      }
      expect(AspectRatioCache.length, AspectRatioCache.maxEntries);

      // Promote 'a' to most-recently-used; 'b' is now the least-recently-used.
      expect(AspectRatioCache.get('a'), 1.1);

      // One more insertion evicts exactly one entry — the LRU, now 'b'.
      AspectRatioCache.put('x', 2.0);

      expect(AspectRatioCache.get('b'), isNull);
      expect(AspectRatioCache.get('a'), 1.1);
    });
  });
}
