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
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: favorites'))),
      ),
      GoRoute(
        path: AppRoutes.downloads,
        builder: (context, state) =>
            Scaffold(body: Center(child: AutoSizeText('Route: downloads'))),
      ),
      GoRoute(
        path: AppRoutes.wallpaperDetail,
        builder: (context, state) => Scaffold(
          body: Center(child: AutoSizeText('Route: wallpaperDetail')),
        ),
      ),
      GoRoute(
        path: AppRoutes.classificationDetail,
        builder: (context, state) {
          final classification = state.extra as ClassificationEntity;
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
