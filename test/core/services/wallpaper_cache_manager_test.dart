import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/services/wallpaper_cache_manager.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => '/tmp';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  group('wallpaper thumbnail cache config', () {
    test('keeps at least 1000 cache objects', () {
      final config = buildWallpaperThumbnailCacheConfig();
      expect(config.maxNrOfCacheObjects, greaterThanOrEqualTo(1000));
    });

    test('retains entries for 30 days', () {
      final config = buildWallpaperThumbnailCacheConfig();
      expect(config.stalePeriod, const Duration(days: 30));
    });

    test('uses a cache key distinct from the package default manager', () {
      final config = buildWallpaperThumbnailCacheConfig();
      expect(config.cacheKey, isNot('libCachedImageData'));
      expect(config.cacheKey, 'glowyWallpaperThumbnailCache');
    });
  });
}
