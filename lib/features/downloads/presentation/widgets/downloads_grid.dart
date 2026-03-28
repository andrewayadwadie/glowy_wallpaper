import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/widgets/exclusive_badge.dart';
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
    return GridView.builder(
      padding: EdgeInsets.all(AppDimens.paddingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppDimens.gridColumnCount(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: AppDimens.gridSpacing,
        mainAxisSpacing: AppDimens.gridSpacing,
      ),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final record = downloads[index];
        return Semantics(
          button: true,
          label: AppStrings.wallpaperDetail,
          child: GestureDetector(
            onTap: () => onTap(record),
            child: Hero(
              tag: 'wallpaper_${record.wallpaperId}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LayoutBuilder(
                      builder: (_, constraints) => AppCachedImage(
                        imageUrl: record.thumbnailUrl,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (record.isTopRated)
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
      },
    );
  }
}
