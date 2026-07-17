import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_shimmer_widget.dart';
import '../../../../core/widgets/app_empty_state_widget.dart';
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
      return AppShimmerWidget(
        child: MasonryGridView.count(
          padding: EdgeInsets.all(AppDimens.paddingM),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: AppDimens.gridSpacing,
          mainAxisSpacing: AppDimens.gridSpacing,
          itemCount: 6,
          itemBuilder: (context, index) => AspectRatio(
            aspectRatio: 0.75,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
              ),
            ),
          ),
        ),
      );
    }

    if (contentStatus == Status.error) {
      return AppErrorWidget(
        message: errorMessage ?? AppStrings.error,
        onRetry: onRetry,
      );
    }

    if (contentStatus == Status.empty) {
      return AppEmptyStateWidget(
        message: AppStrings.noWallpapers,
        icon: Icons.image_not_supported_outlined,
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
