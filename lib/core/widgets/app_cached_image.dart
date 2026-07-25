import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_dimens.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final String? semanticLabel;
  final CacheManager? cacheManager;

  /// Image fade-in on first display. Defaults to `cached_network_image`'s own
  /// 500 ms so existing call sites are unchanged; grid cards pass
  /// [Duration.zero] so a warm cache hit swaps in instantly on scroll-back.
  final Duration fadeInDuration;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.semanticLabel,
    this.cacheManager,
    this.fadeInDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    // Auto-calculate memory cache size from display dimensions if not provided
    final cacheWidth =
        memCacheWidth ?? (width != null ? (width! * dpr).round() : null);
    final cacheHeight =
        memCacheHeight ?? (height != null ? (height! * dpr).round() : null);

    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager:
          cacheManager ??
          GetIt.I<CacheManager>(instanceName: 'wallpaperThumbnailCacheManager'),
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        child: Container(
          width: width,
          height: height,
          color: colorScheme.surface,
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.broken_image,
        size: AppDimens.iconL,
        color: colorScheme.onSurface.withAlpha(100),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(image: true, label: semanticLabel, child: image);
    }
    return image;
  }
}
