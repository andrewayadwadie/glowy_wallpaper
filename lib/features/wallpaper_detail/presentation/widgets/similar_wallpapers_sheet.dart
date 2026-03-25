import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_strings.dart';

import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_empty_state_widget.dart';
import '../../../../core/widgets/app_shimmer_widget.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

class SimilarWallpapersSheet extends StatelessWidget {
  final List<WallpaperEntity> wallpapers;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<WallpaperEntity> onTap;
  final VoidCallback onRetry;

  const SimilarWallpapersSheet({
    super.key,
    required this.wallpapers,
    required this.isLoading,
    this.errorMessage,
    required this.onTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingM,
                  vertical: 4.h,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    AppStrings.similarWallpapers,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(child: _buildContent(context, scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    if (isLoading) {
      return AppShimmerWidget(
        child: GridView.builder(
          padding: EdgeInsets.all(AppDimens.paddingM),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
          ),
        ),
      );
    }
    if (errorMessage != null) {
      return AppErrorWidget(message: errorMessage!, onRetry: onRetry);
    }
    if (wallpapers.isEmpty) {
      return AppEmptyStateWidget(message: AppStrings.noSimilarWallpapers);
    }
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(AppDimens.paddingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppDimens.gridSpacing,
        mainAxisSpacing: AppDimens.gridSpacing,
      ),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = wallpapers[index];
        return GestureDetector(
          onTap: () => onTap(wallpaper),
          child: Hero(
            tag: 'similar_${wallpaper.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
              child: AppCachedImage(
                imageUrl: wallpaper.thumbUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
