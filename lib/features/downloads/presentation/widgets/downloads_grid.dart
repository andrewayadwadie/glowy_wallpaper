import 'package:flutter/material.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../domain/entities/download_record_entity.dart';

class DownloadsGrid extends StatelessWidget {
  final List<DownloadRecordEntity> downloads;
  final ValueChanged<DownloadRecordEntity> onTap;

  const DownloadsGrid({
    super.key,
    required this.downloads,
    required this.onTap,
  });

  int _columnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;
    if (width < 700) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(AppDimens.paddingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columnCount(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: AppDimens.gridSpacing,
        mainAxisSpacing: AppDimens.gridSpacing,
      ),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final record = downloads[index];
        return GestureDetector(
          onTap: () => onTap(record),
          child: Hero(
            tag: 'wallpaper_${record.wallpaperId}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
              child: AppCachedImage(
                imageUrl: record.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
