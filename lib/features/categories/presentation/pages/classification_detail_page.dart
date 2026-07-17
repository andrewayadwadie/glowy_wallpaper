import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_empty_state_widget.dart';
import '../../../../core/widgets/app_shimmer_widget.dart';
import '../../../wallpapers/presentation/widgets/wallpaper_grid.dart';
import '../../domain/entities/category_entity.dart';
import '../../../auth/presentation/cubit/subscription_cubit.dart';
import '../cubit/classification_detail_cubit.dart';
import '../cubit/classification_detail_state.dart';

class ClassificationDetailPage extends StatelessWidget {
  const ClassificationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassificationDetailCubit, ClassificationDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: AutoSizeText(state.classification.name, maxLines: 1),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ClassificationDetailState state) {
    switch (state.status) {
      case Status.loading:
        return AppShimmerWidget(
          child: MasonryGridView.count(
            padding: EdgeInsets.all(AppDimens.paddingM),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: AppDimens.gridSpacing,
            mainAxisSpacing: AppDimens.gridSpacing,
            itemCount: 6,
            itemBuilder: (context, idx) => AspectRatio(
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
      case Status.error:
        return AppErrorWidget(
          message: state.errorMessage ?? AppStrings.error,
          onRetry: () => context.read<ClassificationDetailCubit>().retry(),
        );
      case Status.empty:
        return AppEmptyStateWidget(
          message: AppStrings.noWallpapers,
          icon: Icons.image_not_supported_outlined,
        );
      case Status.success:
        return WallpaperGrid(
          wallpapers: state.wallpapers,
          isLoadingMore: state.isLoadingMore,
          hasReachedEnd: state.hasReachedEnd,
          onLoadMore: () =>
              context.read<ClassificationDetailCubit>().loadMore(),
          onWallpaperTapped: (wallpaper) {
            final cubit = context.read<ClassificationDetailCubit>();
            final wallpapers = state.wallpapers;
            final index = wallpapers.indexOf(wallpaper);
            context.push(
              '/wallpaper/${wallpaper.id}',
              extra: {
                'wallpapers': wallpapers,
                'initialIndex': index >= 0 ? index : 0,
                'categoryId': cubit.classification.categoryId,
                'categoryType': CategoryType.classification,
                'classificationId': cubit.selectedClassificationId,
              },
            );
          },
          isPremium: context.read<SubscriptionCubit>().isPremium,
        );
    }
  }
}
