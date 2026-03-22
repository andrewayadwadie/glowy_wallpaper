import 'package:flutter/material.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/wallpaper_entity.dart';
import 'wallpaper_thumbnail.dart';

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

  int _getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;
    if (width < 700) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final displayWallpapers = isPremium
        ? wallpapers
        : wallpapers.where((w) => !w.isPremium).toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent -
                      AppDimens.paginationThreshold &&
              !hasReachedEnd &&
              !isLoadingMore) {
            onLoadMore();
          }
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(AppDimens.paddingM),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getColumnCount(context),
                childAspectRatio: 0.75,
                crossAxisSpacing: AppDimens.gridSpacing,
                mainAxisSpacing: AppDimens.gridSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                childCount: displayWallpapers.length,
                (context, index) {
                  final wallpaper = displayWallpapers[index];
                  return WallpaperThumbnail(
                    wallpaper: wallpaper,
                    onTap: () => onWallpaperTapped(wallpaper),
                  );
                },
              ),
            ),
          ),
          if (isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.paddingM),
                child: const Center(child: AppLoading()),
              ),
            ),
        ],
      ),
    );
  }
}
