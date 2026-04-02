import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_empty_state_widget.dart';
import '../../../../core/widgets/app_shimmer_widget.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../cubit/favorite_cubit.dart';
import '../cubit/favorite_state.dart';
import '../widgets/favorites_grid.dart';
import '../../domain/entities/favorite_entity.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoriteCubit>().loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FavoriteCubit>().loadFavorites();
      }
    });
  }

  void _onFavoriteTapped(FavoriteEntity favorite, List<FavoriteEntity> all) {
    final wallpapers = all.map((f) => f.wallpaper).toList();
    final index = all.indexOf(favorite);
    context.push(
      AppRoutes.wallpaperDetail.replaceFirst(':id', favorite.wallpaperId),
      extra: {
        'wallpapers': wallpapers,
        'initialIndex': index,
        'categoryType': CategoryType.image,
        'classificationId': null,
        'showAppBarActions': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AutoSizeText(AppStrings.favorites)),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          switch (state.listStatus) {
            case Status.loading:
              return AppShimmerWidget(
                child: GridView.builder(
                  padding: EdgeInsets.all(AppDimens.paddingM),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppDimens.gridColumnCount(context),
                    crossAxisSpacing: AppDimens.gridSpacing,
                    mainAxisSpacing: AppDimens.gridSpacing,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                  ),
                ),
              );

            case Status.error:
              return AppErrorWidget(
                message: state.errorMessage ?? AppStrings.error,
                onRetry: () => context.read<FavoriteCubit>().loadFavorites(),
              );

            case Status.empty:
              return AppEmptyStateWidget(
                title: AppStrings.noFavorites,
                message: AppStrings.noFavoritesSubtitle,
                icon: Icons.favorite_border,
              );

            case Status.success:
              return FavoritesGrid(
                favorites: state.favorites,
                onTap: (fav) => _onFavoriteTapped(fav, state.favorites),
              );
          }
        },
      ),
    );
  }
}
