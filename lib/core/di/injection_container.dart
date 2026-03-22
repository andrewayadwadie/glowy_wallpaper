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
}
