import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// TODO(ads-disabled-018): ad layer registrations removed
// import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import '../../features/wallpaper_detail/data/datasources/similar_wallpaper_remote_data_source.dart';
import '../../features/wallpaper_detail/data/repositories/similar_wallpaper_repository_impl.dart';
import '../../features/wallpaper_detail/domain/repositories/similar_wallpaper_repository.dart';
import '../../features/wallpaper_detail/domain/usecases/get_similar_wallpapers.dart';
import '../../features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart';
import '../../features/downloads/data/datasources/download_local_data_source.dart';
import '../../features/downloads/data/datasources/gallery_data_source.dart';
import '../../features/downloads/data/repositories/download_repository_impl.dart';
import '../../features/downloads/data/services/download_engine.dart';
import '../../features/downloads/data/services/download_runner.dart';
import '../../features/downloads/domain/repositories/download_repository.dart';
import '../../features/downloads/domain/usecases/download_wallpaper.dart';
import '../../features/downloads/domain/usecases/get_download_history.dart';
import '../../features/downloads/domain/usecases/watch_download_events.dart';
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
// TODO(ads-disabled-018): ad layer registrations removed
// import '../ads/ad_gatekeeper.dart';
// import '../ads/ad_ids.dart';
// import '../ads/ads_initializer.dart';
// import '../ads/consent_manager.dart';
// import '../ads/managers/app_open_ad_manager.dart';
// import '../ads/managers/interstitial_ad_manager.dart';
// import '../ads/managers/rewarded_ad_manager.dart';
import '../services/device_id_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../features/premium/domain/usecases/get_products.dart';
import '../../features/premium/domain/usecases/purchase_premium.dart';
import '../../features/premium/domain/usecases/get_subscription_status.dart';
import '../../features/premium/domain/usecases/restore_purchases.dart';
import '../../features/premium/presentation/cubit/premium_cubit.dart';
import '../../features/notifications/domain/services/notification_service.dart';
import '../../features/notifications/data/services/notification_service_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/usecases/request_notification_permission.dart';
import '../../features/notifications/domain/usecases/get_fcm_token.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/app/data/datasources/bootstrap_remote_data_source.dart';
import '../../features/app/data/datasources/bootstrap_local_data_source.dart';
import '../../features/app/data/repositories/app_repository_impl.dart';
import '../../features/app/domain/repositories/app_repository.dart';
import '../../features/app/domain/usecases/get_app_data.dart';

final sl = GetIt.instance;

/// Initialize Dependency Injection
Future<void> init() async {
  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton(
    () => InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 5),
      addresses: [
        AddressCheckOption(uri: Uri.parse('https://www.google.com')),
        AddressCheckOption(uri: Uri.parse('https://www.cloudflare.com')),
        AddressCheckOption(uri: Uri.parse('https://www.apple.com')),
      ],
    ),
  );
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Authenticated Dio (with AuthInterceptor) — for protected endpoints
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

  // Public Dio (no AuthInterceptor) — for public endpoints (bootstrap, content, classifications)
  sl.registerLazySingleton<Dio>(() {
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
  }, instanceName: 'publicDio');

  //! Firebase & Ads
  sl.registerLazySingleton<FirebaseAnalytics>(() => FirebaseAnalytics.instance);
  // TODO(ads-disabled-018): ad layer registrations removed
  // sl.registerLazySingleton<MobileAds>(() => MobileAds.instance);

  // //! Ads layer (016) — cross-cutting core/ads, replaces AdHelper
  // sl.registerLazySingleton<AdIds>(() => AdIds());
  // sl.registerLazySingleton<AdGatekeeper>(() => AdGatekeeper());
  // sl.registerLazySingleton<ConsentManager>(() => ConsentManager());
  // sl.registerLazySingleton<AdsInitializer>(
  //   () => AdsInitializer(sl(), sl<MobileAds>()),
  // );
  // sl.registerLazySingleton<RewardedAdManager>(
  //   () => RewardedAdManager(sl(), sl(), analytics: sl()),
  // );
  // sl.registerLazySingleton<AppOpenAdManager>(
  //   () => AppOpenAdManager(sl(), sl(), analytics: sl()),
  // );
  // sl.registerLazySingleton<InterstitialAdManager>(
  //   () => InterstitialAdManager(sl(), sl(), analytics: sl()),
  // );

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
    () => CategoryRemoteDataSource(sl<Dio>(instanceName: 'publicDio')),
  );
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(Hive.box('categories')),
  );

  // Wallpaper Data Sources
  sl.registerLazySingleton<WallpaperRemoteDataSource>(
    () => WallpaperRemoteDataSource(sl<Dio>(instanceName: 'publicDio')),
  );

  // Category Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl(), sl(), sl()),
  );

  // Wallpaper Repository
  sl.registerLazySingleton<WallpaperRepository>(
    () => WallpaperRepositoryImpl(sl()),
  );

  // Category Use Cases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetClassifications(sl()));

  // Wallpaper Use Cases
  sl.registerLazySingleton(() => GetWallpapersByCategory(sl()));

  // Home Cubit
  sl.registerFactory(
    () => HomeCubit(
      getAppData: sl(),
      getWallpapersByCategory: sl(),
      getClassifications: sl(),
      appRepo: sl<AppRepository>() as AppRepositoryImpl,
    ),
  );

  // ClassificationDetail Cubit (factory with params — registered via factoryParam)
  // Note: ClassificationDetailCubit needs a ClassificationEntity at creation time,
  // so it's provided inline in the router via BlocProvider.

  //! Phase 4 — Wallpaper Detail, Download & Favorites

  // SimilarWallpaper Data Source & Repository
  sl.registerLazySingleton<SimilarWallpaperRemoteDataSource>(
    () => SimilarWallpaperRemoteDataSource(sl<Dio>(instanceName: 'publicDio')),
  );
  sl.registerLazySingleton<SimilarWallpaperRepository>(
    () => SimilarWallpaperRepositoryImpl(sl()),
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

  // Download Engine (018) — session-scoped singleton; owns the isolate job
  // so it outlives any per-route DownloadCubit (FR-018).
  sl.registerLazySingleton<DownloadRunner>(() => IsolateDownloadRunner());
  sl.registerLazySingleton<DownloadEngine>(
    () => DownloadEngine(sl(), sl(), sl()),
  );

  // Download Repository
  sl.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(sl(), sl(), sl()),
  );

  // Download Use Cases
  sl.registerLazySingleton(() => DownloadWallpaper(sl()));
  sl.registerLazySingleton(() => GetDownloadHistory(sl()));
  sl.registerLazySingleton(() => WatchDownloadEvents(sl()));

  // Download Cubit
  sl.registerFactory(
    () => DownloadCubit(
      downloadWallpaper: sl(),
      getDownloadHistory: sl(),
      watchDownloadEvents: sl(),
      networkInfo: sl(),
      // TODO(ads-disabled-018): rewarded gate removed — download no longer ad-dependent
      // rewardedAdManager: sl(),
      analytics: sl(),
      notificationService: sl(),
    ),
  );

  // Device ID Service
  sl.registerLazySingleton<DeviceIdService>(
    () => DeviceIdService(Hive.box('app_bootstrap')),
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
      deviceIdService: sl(),
      analytics: sl(),
      notificationService: sl(),
    ),
  );

  //! Phase 5 — Premium & Monetization

  // Premium Hive Boxes
  final subscriptionCacheBox = Hive.box<String>('subscription_cache');
  final adFrequencyBox = Hive.box<String>('ad_frequency');
  sl.registerLazySingleton<Box<String>>(
    () => subscriptionCacheBox,
    instanceName: 'subscriptionCacheBox',
  );
  sl.registerLazySingleton<Box<String>>(
    () => adFrequencyBox,
    instanceName: 'adFrequencyBox',
  );

  // Premium Data Sources
  sl.registerLazySingleton<IAPDataSource>(
    () => IAPDataSource(InAppPurchase.instance),
  );
  sl.registerLazySingleton<PremiumRemoteSource>(
    () => PremiumRemoteSource(sl<Dio>()),
  );
  sl.registerLazySingleton<PremiumLocalSource>(
    () => PremiumLocalSource(
      sl<Box<String>>(instanceName: 'subscriptionCacheBox'),
      sl<Box<String>>(instanceName: 'adFrequencyBox'),
    ),
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

  //! Phase 7 — App Bootstrap (public API)
  sl.registerLazySingleton<BootstrapRemoteDataSource>(
    () => BootstrapRemoteDataSource(sl<Dio>(instanceName: 'publicDio')),
  );
  sl.registerLazySingleton<BootstrapLocalDataSource>(
    () => BootstrapLocalDataSourceImpl(Hive.box('app_bootstrap')),
  );
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetAppData(sl()));

  //! Phase 6 — Notifications
  sl.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => RequestNotificationPermission(sl()));
  sl.registerLazySingleton(() => GetFcmToken(sl()));
  sl.registerFactory(
    () => NotificationCubit(
      requestPermission: sl(),
      getFcmToken: sl(),
      repository: sl(),
      analytics: sl(),
    ),
  );
}
