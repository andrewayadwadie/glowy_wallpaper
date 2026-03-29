import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/widgets/exclusive_badge.dart';
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
    return Semantics(
      button: true,
      label: wallpaper.classificationName ?? AppStrings.wallpaperDetail,
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: 'wallpaper_${wallpaper.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusS),
            child: Stack(
              fit: StackFit.expand,
              children: [
                LayoutBuilder(
                  builder: (_, constraints) => AppCachedImage(
                    imageUrl: wallpaper.thumbUrl,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                if (wallpaper.isTopRated)
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: const ExclusiveBadge(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
