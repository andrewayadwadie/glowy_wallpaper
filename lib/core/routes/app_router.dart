import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:glowy_wallpaper/core/di/injection_container.dart';
import 'package:glowy_wallpaper/features/home/presentation/cubit/home_cubit.dart';
import 'routes.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/categories/domain/entities/classification_entity.dart';
import '../../features/categories/presentation/cubit/classification_detail_cubit.dart';
import '../../features/categories/presentation/pages/classification_detail_page.dart';
import '../../features/wallpapers/domain/usecases/get_wallpapers_by_classification.dart';
import '../../features/wallpapers/domain/entities/wallpaper_entity.dart';
import '../../features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart';
import '../../features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart';
import '../../features/downloads/presentation/cubit/download_cubit.dart';
import '../../features/favorites/presentation/cubit/favorite_cubit.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/downloads/presentation/pages/downloads_page.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: AutoSizeText('Page not found: ${state.uri}')),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<HomeCubit>()..loadCategories(),
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: login'))),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: register'))),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: profile'))),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<FavoriteCubit>(),
          child: const FavoritesPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.downloads,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<DownloadCubit>(),
          child: const DownloadsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.wallpaperDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(child: Text('Invalid navigation parameters')),
            );
          }
          final wallpapers = extra['wallpapers'] as List<WallpaperEntity>;
          final initialIndex = extra['initialIndex'] as int? ?? 0;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<WallpaperDetailCubit>()
                  ..init(wallpapers: wallpapers, initialIndex: initialIndex),
              ),
              BlocProvider(create: (_) => sl<DownloadCubit>()),
              BlocProvider(
                create: (_) {
                  final cubit = sl<FavoriteCubit>();
                  if (wallpapers.isNotEmpty) {
                    cubit.checkIsFavorite(wallpapers[initialIndex].id);
                  }
                  return cubit;
                },
              ),
            ],
            child: WallpaperDetailPage(
              wallpapers: wallpapers,
              initialIndex: initialIndex,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.classificationDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ClassificationEntity) {
            return const Scaffold(
              body: Center(child: Text('Invalid navigation parameters')),
            );
          }
          final classification = extra;
          return BlocProvider(
            create: (context) => ClassificationDetailCubit(
              getWallpapersByClassification:
                  sl<GetWallpapersByClassification>(),
              classification: classification,
            )..loadWallpapers(),
            child: const ClassificationDetailPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: premium'))),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: settings'))),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: about'))),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: onboarding'))),
      ),
    ],
  );
}
