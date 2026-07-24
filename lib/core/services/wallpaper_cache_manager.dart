import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../utils/constants.dart';

/// Config for the shared, app-wide thumbnail cache. Kept separate from
/// [buildWallpaperThumbnailCacheManager] so tests can assert on its tuning
/// without constructing a full [CacheManager] (which eagerly opens its
/// backing store on construction).
Config buildWallpaperThumbnailCacheConfig() {
  return Config(
    AppConstants.thumbnailCacheKey,
    stalePeriod: AppConstants.thumbnailCacheStalePeriod,
    maxNrOfCacheObjects: AppConstants.thumbnailCacheMaxObjects,
  );
}

/// Builds the shared, app-wide [CacheManager] used to persist wallpaper
/// thumbnails on disk. Distinct key/folder from `cached_network_image`'s
/// `DefaultCacheManager` so it does not compete for eviction space.
CacheManager buildWallpaperThumbnailCacheManager() {
  return CacheManager(buildWallpaperThumbnailCacheConfig());
}
