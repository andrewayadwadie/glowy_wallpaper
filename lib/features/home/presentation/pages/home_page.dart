import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ads/managers/interstitial_ad_manager.dart';
import '../../../../core/ads/widgets/anchored_adaptive_banner.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/neon_text.dart';
import '../../../auth/presentation/cubit/subscription_cubit.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/category_selector.dart';
import '../widgets/content_switcher.dart';
import '../widgets/home_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<SubscriptionCubit>().isPremium;

    return BlocListener<HomeCubit, HomeState>(
      // Category-switch interstitial trigger (US4, R8). Cap + cooldown live
      // in the manager — HomeCubit stays ad-free.
      listenWhen: (prev, curr) =>
          prev.selectedCategoryIndex != curr.selectedCategoryIndex &&
          curr.categoriesStatus == Status.success,
      listener: (_, _) => sl<InterstitialAdManager>().onCategorySwitched(),
      child: Scaffold(
        appBar: AppBar(
          title: NeonText(AppStrings.appNameHome),
          centerTitle: true,
          actions: [
            if (isPremium)
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: AppStrings.profile,
                onPressed: () => _onProfileTapped(context, isPremium),
              ),
          ],
        ),
        drawer: const HomeDrawer(),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final homeCubit = context.read<HomeCubit>();
            return Column(
              children: [
                if (state.categoriesStatus == Status.success)
                  CategorySelector(
                    categories: state.categories,
                    selectedIndex: state.selectedCategoryIndex,
                    onCategorySelected: (index) =>
                        homeCubit.selectCategory(index),
                  ),
                Gap(10.h),
                Expanded(
                  child: ContentSwitcher(
                    categoryType: homeCubit.selectedCategory?.type,
                    wallpapers: state.wallpapers,
                    classifications: state.classifications,
                    contentStatus: state.contentStatus,
                    isLoadingMore: state.isLoadingMore,
                    hasReachedEnd: state.hasReachedEnd,
                    onLoadMore: () => homeCubit.loadMore(),
                    onWallpaperTapped: (wallpaper) {
                      final wallpapers = state.wallpapers;
                      final index = wallpapers.indexOf(wallpaper);
                      context.push(
                        '/wallpaper/${wallpaper.id}',
                        extra: {
                          'wallpapers': wallpapers,
                          'initialIndex': index >= 0 ? index : 0,
                          'categoryId': homeCubit.selectedCategoryId,
                          'categoryType': homeCubit.selectedCategory?.type,
                          'classificationId': '',
                        },
                      );
                    },
                    onClassificationTapped: (classification) {
                      context.push(
                        '/classification/${classification.id}',
                        extra: classification,
                      );
                    },
                    onRetry: () => homeCubit.retry(),
                    errorMessage: state.errorMessage,
                    isPremium: isPremium,
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: isPremium ? null : const AnchoredAdaptiveBanner(),
      ),
    );
  }

  void _onProfileTapped(BuildContext context, bool isPremium) {
    if (isPremium) {
      context.push(AppRoutes.profile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoSizeText(AppStrings.premiumActionPrompt)),
      );
    }
  }
}
