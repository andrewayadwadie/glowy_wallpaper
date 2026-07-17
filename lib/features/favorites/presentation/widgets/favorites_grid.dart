import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/exclusive_badge.dart';
import '../../../../core/widgets/staggered_wallpaper_card.dart';
import '../../../favorites/domain/entities/favorite_entity.dart';

class FavoritesGrid extends StatelessWidget {
  final List<FavoriteEntity> favorites;
  final ValueChanged<FavoriteEntity> onTap;

  const FavoritesGrid({
    super.key,
    required this.favorites,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: EdgeInsets.all(AppDimens.paddingM),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimens.gridSpacing,
      mainAxisSpacing: AppDimens.gridSpacing,
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        return StaggeredWallpaperCard(
          imageUrl: fav.wallpaper.thumbUrl,
          onTap: () => onTap(fav),
          heroTag: 'wallpaper_${fav.wallpaper.id}',
          overlay: fav.wallpaper.isTopRated ? const ExclusiveBadge() : null,
          semanticLabel:
              fav.wallpaper.classificationName ?? AppStrings.wallpaperDetail,
        );
      },
    );
  }
}
