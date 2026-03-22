import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/routes/routes.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(AppStrings.appName, maxLines: 1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _onProfileTapped(context),
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
                    context.push(
                      '/wallpaper/${wallpaper.id}',
                      extra: wallpaper,
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
      bottomNavigationBar: isPremium
          ? null
          : SizedBox(
              height: 50.h,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: AutoSizeText(
                    AppStrings.adPlaceholder,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
    );
  }

  void _onProfileTapped(BuildContext context) {
    final subscriptionCubit = context.read<SubscriptionCubit>();
    if (subscriptionCubit.isPremium) {
      context.push(AppRoutes.profile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoSizeText(AppStrings.premiumActionPrompt)),
      );
    }
  }
}
