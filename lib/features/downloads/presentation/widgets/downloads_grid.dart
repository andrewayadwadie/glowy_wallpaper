import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/exclusive_badge.dart';
import '../../../../core/widgets/staggered_wallpaper_card.dart';
import '../../domain/entities/download_record_entity.dart';

class DownloadsGrid extends StatelessWidget {
  final List<DownloadRecordEntity> downloads;
  final ValueChanged<DownloadRecordEntity> onTap;

  const DownloadsGrid({
    super.key,
    required this.downloads,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: EdgeInsets.all(AppDimens.paddingM),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimens.gridSpacing,
      mainAxisSpacing: AppDimens.gridSpacing,
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final record = downloads[index];
        return StaggeredWallpaperCard(
          imageUrl: record.thumbnailUrl,
          onTap: () => onTap(record),
          heroTag: 'wallpaper_${record.wallpaperId}',
          overlay: record.isTopRated ? const ExclusiveBadge() : null,
          semanticLabel: AppStrings.wallpaperDetail,
        );
      },
    );
  }
}
