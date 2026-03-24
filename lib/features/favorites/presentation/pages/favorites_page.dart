import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/app_strings.dart';
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

  void _onFavoriteTapped(FavoriteEntity favorite, List<FavoriteEntity> all) {
    final wallpapers = all.map((f) => f.wallpaper).toList();
    final index = all.indexOf(favorite);
    context.push(
      AppRoutes.wallpaperDetail.replaceFirst(':id', favorite.wallpaperId),
      extra: {'wallpapers': wallpapers, 'initialIndex': index},
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
              return const Center(child: CircularProgressIndicator());

            case Status.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(state.errorMessage ?? AppStrings.error),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<FavoriteCubit>().loadFavorites(),
                      child: const AutoSizeText(AppStrings.retry),
                    ),
                  ],
                ),
              );

            case Status.empty:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border, size: 64),
                    const SizedBox(height: 16),
                    const AutoSizeText(AppStrings.noFavorites),
                    const SizedBox(height: 8),
                    const AutoSizeText(AppStrings.noFavoritesSubtitle),
                  ],
                ),
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
