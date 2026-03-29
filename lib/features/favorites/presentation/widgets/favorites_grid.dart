import 'package:flutter/material.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../favorites/domain/entities/favorite_entity.dart';
import '../../../wallpapers/presentation/widgets/wallpaper_thumbnail.dart';

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
    return GridView.builder(
      padding: EdgeInsets.all(AppDimens.paddingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppDimens.gridColumnCount(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: AppDimens.gridSpacing,
        mainAxisSpacing: AppDimens.gridSpacing,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        return WallpaperThumbnail(
          wallpaper: fav.wallpaper,
          onTap: () => onTap(fav),
        );
      },
    );
  }
}
