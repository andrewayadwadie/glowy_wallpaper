import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/enums/status.dart';
import '../../../wallpapers/presentation/widgets/wallpaper_grid.dart';
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
        return const Center(child: CircularProgressIndicator());
      case Status.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: Theme.of(context).colorScheme.error,
              ),
              Gap(AppDimens.paddingM),
              AutoSizeText(
                state.errorMessage ?? AppStrings.error,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              Gap(AppDimens.paddingL),
              ElevatedButton(
                onPressed: () =>
                    context.read<ClassificationDetailCubit>().retry(),
                child: AutoSizeText(AppStrings.retry),
              ),
            ],
          ),
        );
      case Status.empty:
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
              ],
            ),
          ),
        );
      case Status.success:
        return WallpaperGrid(
          wallpapers: state.wallpapers,
          isLoadingMore: state.isLoadingMore,
          hasReachedEnd: state.hasReachedEnd,
          onLoadMore: () =>
              context.read<ClassificationDetailCubit>().loadMore(),
          onWallpaperTapped: (wallpaper) {
            context.push('/wallpaper/${wallpaper.id}', extra: wallpaper);
          },
          isPremium: context.read<SubscriptionCubit>().isPremium,
        );
    }
  }
}
