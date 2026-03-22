import 'package:flutter/material.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../domain/entities/wallpaper_entity.dart';

class WallpaperThumbnail extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onTap;

  const WallpaperThumbnail({
    super.key,
    required this.wallpaper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'wallpaper_${wallpaper.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusS),
          child: AppCachedImage(
            imageUrl: wallpaper.thumbnailUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
