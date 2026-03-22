import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/entities/classification_entity.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../../categories/presentation/widgets/classification_bento_grid.dart';
import '../../../wallpapers/presentation/widgets/wallpaper_grid.dart';
import '../../../wallpapers/presentation/widgets/video_grid.dart';
import '../cubit/home_state.dart';

class ContentSwitcher extends StatelessWidget {
  final CategoryType? categoryType;
  final List<WallpaperEntity> wallpapers;
  final List<ClassificationEntity> classifications;
  final Status contentStatus;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final VoidCallback onLoadMore;
  final ValueChanged<WallpaperEntity> onWallpaperTapped;
  final ValueChanged<ClassificationEntity> onClassificationTapped;
  final VoidCallback onRetry;
  final String? errorMessage;
  final bool isPremium;

  const ContentSwitcher({
    super.key,
    required this.categoryType,
    required this.wallpapers,
    required this.classifications,
    required this.contentStatus,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    required this.onLoadMore,
    required this.onWallpaperTapped,
    required this.onClassificationTapped,
    required this.onRetry,
    this.errorMessage,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    if (contentStatus == Status.loading) {
      return const Center(child: AppLoading());
    }

    if (contentStatus == Status.error) {
      return AppErrorWidget(
        message: errorMessage ?? AppStrings.error,
        onRetry: onRetry,
      );
    }

    if (contentStatus == Status.empty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 64.sp,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
              ),
              Gap(AppDimens.paddingM),
              AutoSizeText(
                AppStrings.noWallpapers,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              Gap(AppDimens.paddingL),
              ElevatedButton(
                onPressed: onRetry,
                child: AutoSizeText(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (contentStatus == Status.success) {
      switch (categoryType) {
        case CategoryType.image:
          return WallpaperGrid(
            wallpapers: wallpapers,
            isLoadingMore: isLoadingMore,
            hasReachedEnd: hasReachedEnd,
            onLoadMore: onLoadMore,
            onWallpaperTapped: onWallpaperTapped,
            isPremium: isPremium,
          );
        case CategoryType.video:
          return VideoGrid(
            wallpapers: wallpapers,
            isLoadingMore: isLoadingMore,
            hasReachedEnd: hasReachedEnd,
            onLoadMore: onLoadMore,
            onWallpaperTapped: onWallpaperTapped,
            isPremium: isPremium,
          );
        case CategoryType.classification:
          return ClassificationBentoGrid(
            classifications: classifications,
            onClassificationTapped: onClassificationTapped,
          );
        case null:
          return const SizedBox();
      }
    }

    return const SizedBox();
  }
}
