import 'package:flutter/painting.dart';

import 'constants.dart';

/// Raises Flutter's global in-memory decoded-image cache limits once at
/// app startup so long scroll sessions don't evict decoded thumbnails.
/// Call once, immediately after `WidgetsFlutterBinding.ensureInitialized()`.
void configureImageCache() {
  PaintingBinding.instance.imageCache.maximumSize =
      AppConstants.imageCacheMaxImages;
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      AppConstants.imageCacheMaxSizeBytes;
}
