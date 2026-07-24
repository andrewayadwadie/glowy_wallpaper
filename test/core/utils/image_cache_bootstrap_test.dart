import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/utils/constants.dart';
import 'package:glowy_wallpaper/core/utils/image_cache_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('configureImageCache raises the global ImageCache limits', () {
    configureImageCache();

    expect(
      PaintingBinding.instance.imageCache.maximumSize,
      AppConstants.imageCacheMaxImages,
    );
    expect(
      PaintingBinding.instance.imageCache.maximumSizeBytes,
      AppConstants.imageCacheMaxSizeBytes,
    );
  });
}
