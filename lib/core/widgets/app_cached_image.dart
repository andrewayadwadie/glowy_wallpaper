import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.semanticLabel,
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
      width: width,
      height: height,
      fit: fit,
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
      return Semantics(
        image: true,
        label: semanticLabel,
        child: image,
      );
    }
    return image;
  }
}
