import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/network_info.dart';
import '../api/api_interceptors.dart';
import '../config/app_config.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/validate_token.dart';
import '../../features/auth/domain/usecases/get_cached_user.dart';
import '../../features/auth/domain/usecases/unsubscribe.dart';
import '../../features/auth/presentation/cubit/subscription_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/categories/data/datasources/category_remote_data_source.dart';
import '../../features/categories/data/datasources/category_local_data_source.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/get_classifications.dart';
import '../../features/wallpapers/data/datasources/wallpaper_remote_data_source.dart';
import '../../features/wallpapers/data/repositories/wallpaper_repository_impl.dart';
import '../../features/wallpapers/domain/repositories/wallpaper_repository.dart';
import '../../features/wallpapers/domain/usecases/get_wallpapers_by_category.dart';
import '../../features/wallpapers/domain/usecases/get_wallpapers_by_classification.dart';
import '../../features/wallpaper_detail/data/datasources/similar_wallpaper_remote_data_source.dart';
import '../../features/wallpaper_detail/data/repositories/similar_wallpaper_repository_impl.dart';
import '../../features/wallpaper_detail/domain/repositories/similar_wallpaper_repository.dart';
import '../../features/wallpaper_detail/domain/usecases/get_similar_wallpapers.dart';
import '../../features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart';
import '../../features/downloads/data/datasources/download_local_data_source.dart';
import '../../features/downloads/data/datasources/gallery_data_source.dart';
import '../../features/downloads/data/repositories/download_repository_impl.dart';
import '../../features/downloads/domain/repositories/download_repository.dart';
import '../../features/downloads/domain/usecases/download_wallpaper.dart';
import '../../features/downloads/domain/usecases/get_download_history.dart';
import '../../features/downloads/presentation/cubit/download_cubit.dart';
import '../../features/favorites/data/datasources/favorite_local_data_source.dart';
import '../../features/favorites/data/datasources/favorite_remote_data_source.dart';
import '../../features/favorites/data/repositories/favorite_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorite_repository.dart';
import '../../features/favorites/domain/usecases/toggle_favorite.dart';
import '../../features/favorites/domain/usecases/is_favorite.dart';
import '../../features/favorites/domain/usecases/get_favorites.dart';
import '../../features/favorites/domain/usecases/merge_guest_favorites.dart';
import '../../features/favorites/presentation/cubit/favorite_cubit.dart';
import '../../features/premium/data/datasources/iap_data_source.dart';
import '../../features/premium/data/datasources/premium_local_source.dart';
import '../../features/premium/data/datasources/premium_remote_source.dart';
import '../../features/premium/data/repositories/premium_repository_impl.dart';
import '../../features/premium/domain/repositories/premium_repository.dart';
import '../services/ad_helper.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../features/premium/domain/usecases/get_products.dart';
import '../../features/premium/domain/usecases/purchase_premium.dart';
import '../../features/premium/domain/usecases/get_subscription_status.dart';
import '../../features/premium/domain/usecases/restore_purchases.dart';
import '../../features/premium/presentation/cubit/premium_cubit.dart';

final sl = GetIt.instance;

/// Initialize Dependency Injection
Future<void> init() async {
  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(sl()));

    // Add pretty logger in debug mode
    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  });

  //! Firebase & Ads
  sl.registerLazySingleton<FirebaseAnalytics>(() => FirebaseAnalytics.instance);
  sl.registerLazySingleton<MobileAds>(() => MobileAds.instance);

  // Auth Data Sources
  sl.registerLazySingleton(() => Hive.box('user_cache'));
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<FlutterSecureStorage>(), sl<Box>()),
  );

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );

  // Auth Use Cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => ValidateToken(sl()));
  sl.registerLazySingleton(() => GetCachedUser(sl()));
  sl.registerLazySingleton(() => Unsubscribe(sl()));

  // Auth Cubits
  sl.registerFactory(
    () => SubscriptionCubit(
      validateToken: sl(),
      getCachedUser: sl(),
      unsubscribe: sl(),
    ),
  );

  //! Phase 3 — Categories & Wallpapers

  // Category Data Sources
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(Hive.box('categories')),
  );

  // Wallpaper Data Sources
  sl.registerLazySingleton<WallpaperRemoteDataSource>(
    () => WallpaperRemoteDataSource(sl<Dio>()),
  );

  // Category Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl(), sl(), sl()),
  );

  // Wallpaper Repository
  sl.registerLazySingleton<WallpaperRepository>(
    () => WallpaperRepositoryImpl(sl(), sl()),
  );

  // Category Use Cases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetClassifications(sl()));

  // Wallpaper Use Cases
  sl.registerLazySingleton(() => GetWallpapersByCategory(sl()));
  sl.registerLazySingleton(() => GetWallpapersByClassification(sl()));

  // Home Cubit
  sl.registerFactory(
    () => HomeCubit(
      getCategories: sl(),
      getWallpapersByCategory: sl(),
      getClassifications: sl(),
      categoryRepo: sl<CategoryRepository>() as CategoryRepositoryImpl,
    ),
  );

  // ClassificationDetail Cubit (factory with params — registered via factoryParam)
  // Note: ClassificationDetailCubit needs a ClassificationEntity at creation time,
  // so it's provided inline in the router via BlocProvider.

  //! Phase 4 — Wallpaper Detail, Download & Favorites

  // SimilarWallpaper Data Source & Repository
  sl.registerLazySingleton<SimilarWallpaperRemoteDataSource>(
    () => SimilarWallpaperRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<SimilarWallpaperRepository>(
    () => SimilarWallpaperRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetSimilarWallpapers(sl()));

  // WallpaperDetail Cubit
  sl.registerFactory(
    () => WallpaperDetailCubit(getSimilarWallpapers: sl(), analytics: sl()),
  );

  // Download Data Sources
  sl.registerLazySingleton<DownloadLocalDataSource>(
    () => DownloadLocalDataSourceImpl(Hive.box('downloads')),
  );
  sl.registerLazySingleton<GalleryDataSource>(() => GalleryDataSourceImpl());

  // Download Repository
  sl.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(sl(), sl(), sl()),
  );

  // Download Use Cases
  sl.registerLazySingleton(() => DownloadWallpaper(sl()));
  sl.registerLazySingleton(() => GetDownloadHistory(sl()));

  // Download Cubit
  sl.registerFactory(
    () => DownloadCubit(
      downloadWallpaper: sl(),
      getDownloadHistory: sl(),
      analytics: sl(),
    ),
  );

  // Favorite Data Sources
  sl.registerLazySingleton<FavoriteLocalDataSource>(
    () => FavoriteLocalDataSourceImpl(Hive.box('favorites')),
  );
  sl.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSource(sl<Dio>()),
  );

  // Favorite Repository
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl(), sl(), sl()),
  );

  // Favorite Use Cases
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => IsFavorite(sl()));
  sl.registerLazySingleton(() => GetFavorites(sl()));
  sl.registerLazySingleton(() => MergeGuestFavorites(sl()));

  // Favorite Cubit
  sl.registerFactory(
    () => FavoriteCubit(
      toggleFavorite: sl(),
      isFavorite: sl(),
      getFavorites: sl(),
      analytics: sl(),
    ),
  );

  //! Phase 5 — Premium & Monetization

  // AdHelper
  sl.registerLazySingleton<AdHelper>(() => AdHelper.instance);

  // Premium Hive Boxes
  final subscriptionCacheBox = Hive.box('subscription_cache') as Box<String>;
  final adFrequencyBox = Hive.box('ad_frequency') as Box<String>;
  sl.registerLazySingleton(() => subscriptionCacheBox);
  sl.registerLazySingleton(() => adFrequencyBox);

  // Premium Data Sources
  sl.registerLazySingleton<IAPDataSource>(
    () => IAPDataSource(InAppPurchase.instance),
  );
  sl.registerLazySingleton<PremiumRemoteSource>(
    () => PremiumRemoteSource(sl<Dio>()),
  );
  sl.registerLazySingleton<PremiumLocalSource>(
    () => PremiumLocalSource(subscriptionCacheBox, adFrequencyBox),
  );

  // Premium Repository
  sl.registerLazySingleton<PremiumRepository>(
    () => PremiumRepositoryImpl(sl(), sl(), sl()),
  );

  // Premium Use Cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => PurchasePremium(sl()));
  sl.registerLazySingleton(() => GetSubscriptionStatus(sl()));
  sl.registerLazySingleton(() => RestorePurchases(sl()));

  // Premium Cubit — subscriptionCubit must be passed from widget tree (same instance as app-level BlocProvider)
  sl.registerFactoryParam<PremiumCubit, SubscriptionCubit, void>(
    (subscriptionCubit, _) => PremiumCubit(
      getProducts: sl(),
      purchasePremium: sl(),
      restorePurchases: sl(),
      subscriptionCubit: subscriptionCubit,
      analytics: sl(),
    ),
  );
}
