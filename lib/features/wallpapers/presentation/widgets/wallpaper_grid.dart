import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/exclusive_badge.dart';
import '../../../../core/widgets/staggered_wallpaper_card.dart';
import '../../../../core/widgets/staggered_wallpaper_grid.dart';
import '../../domain/entities/wallpaper_entity.dart';

class WallpaperGrid extends StatelessWidget {
  final List<WallpaperEntity> wallpapers;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final VoidCallback onLoadMore;
  final ValueChanged<WallpaperEntity> onWallpaperTapped;
  final bool isPremium;

  const WallpaperGrid({
    super.key,
    required this.wallpapers,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    required this.onLoadMore,
    required this.onWallpaperTapped,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredWallpaperGrid<WallpaperEntity>(
      items: wallpapers,
      isLoadingMore: isLoadingMore,
      hasReachedEnd: hasReachedEnd,
      onLoadMore: onLoadMore,
      itemBuilder: (context, wallpaper, index) => StaggeredWallpaperCard(
        key: ValueKey(wallpaper.id),
        imageUrl: wallpaper.thumbUrl,
        onTap: () => onWallpaperTapped(wallpaper),
        heroTag: 'wallpaper_${wallpaper.id}',
        overlay: wallpaper.isTopRated ? const ExclusiveBadge() : null,
        semanticLabel:
            wallpaper.classificationName ?? AppStrings.wallpaperDetail,
      ),
    );
  }
}
