# Tasks: Phase 1 — Foundation & Scaffolding

**Input**: Design documents from `/specs/001-phase1-foundation/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested — test tasks omitted. Constitution requires tests but they will be added in a follow-up pass.

**Organization**: Tasks are grouped by user story. Each task includes explicit instructions so a less-capable LLM can implement without ambiguity.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Install missing packages and create environment/config files the entire project depends on.

- [X] T001 Update `pubspec.yaml` to add all missing constitution-mandated packages. Add these under `dependencies`: `freezed_annotation: ^3.0.0`, `injectable: ^2.5.0`, `retrofit: ^4.4.2`, `hive: ^4.0.0`, `hive_flutter: ^2.0.0`, `flutter_secure_storage: ^9.2.4`, `auto_size_text: ^3.0.0`, `loader_overlay: ^4.0.3`, `flutter_spinkit: ^5.2.1`, `gap: ^3.0.1`, `envied: ^1.1.1`, `envied_annotation: ^1.1.1`, `flutter_native_splash: ^2.4.6`, `flutter_launcher_icons: ^0.14.3`, `json_annotation: ^4.9.0`. Add these under `dev_dependencies`: `freezed: ^3.0.0`, `build_runner: ^2.4.15`, `injectable_generator: ^2.7.0`, `retrofit_generator: ^9.1.8`, `json_serializable: ^6.9.5`, `mocktail: ^1.0.4`, `bloc_test: ^10.0.0`, `envied_generator: ^1.1.1`, `hive_generator: ^2.0.1`. Remove `flutter_lints` and add `flutter_lints: ^6.0.0` or replace with `very_good_analysis: ^7.0.0` if preferred. Run `flutter pub get` after editing.

- [X] T002 [P] Create `.env.dev` file at project root with contents: `API_BASE_URL=https://dev-api.glowywallpapers.com`, `ADMOB_APP_ID=ca-app-pub-2083776520196762~1431087691`, `STRIPE_PUBLISHABLE_KEY=pk_test_placeholder`. Create `.env.staging` with same keys but `API_BASE_URL=https://staging-api.glowywallpapers.com`. Create `.env.prod` with `API_BASE_URL=https://api.glowywallpapers.com` and same other keys. Add `.env.*` to `.gitignore` (keep them out of version control).

- [X] T003 [P] Create `flutter_native_splash.yaml` at project root. Set `color: "#121212"` (deep dark background). Set `android: true`, `ios: true`. Optionally set `image: assets/images/logo.png` if logo exists, otherwise omit the image field (solid color fallback). After creating the file, the splash can be generated later with `dart run flutter_native_splash:create`.

- [X] T004 [P] Create the feature-first folder structure. Create these empty directories (add `.gitkeep` files to keep them in git): `lib/features/auth/domain/entities/`, `lib/features/auth/domain/repositories/`, `lib/features/auth/domain/usecases/`, `lib/features/auth/data/models/`, `lib/features/auth/data/datasources/`, `lib/features/auth/data/repositories/`, `lib/features/auth/presentation/cubit/`, `lib/features/auth/presentation/pages/`, `lib/features/auth/presentation/widgets/`. Repeat this exact 9-folder pattern for each feature: `home`, `splash`, `wallpapers`, `categories`, `favorites`, `downloads`, `premium`, `notifications`, `settings`. Move existing `lib/features/home/views/home_screen.dart` to `lib/features/home/presentation/pages/home_page.dart` (rename the class inside from `HomeScreen` to `HomePage`). Move `lib/features/splash/splash_screen.dart` to `lib/features/splash/presentation/pages/splash_page.dart` (rename class to `SplashPage`). Delete the old `views/` and leftover directories. Keep `lib/features/onboarding/` as-is for now but restructure into `presentation/pages/onboarding_page.dart`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T005 Implement the sealed Failure class in `lib/core/errors/failure.dart`. The file should export a sealed base class `Failure` that extends `Equatable` with a `String message` field and `List<Object?> get props => [message]`. Add four subclasses: `ServerFailure`, `CacheFailure`, `NetworkFailure`, `UnauthorizedFailure` — each with `const` constructors calling `super(message)`. Remove any existing content in this file and replace with the new sealed class pattern. Import `package:equatable/equatable.dart`.

- [X] T006 [P] Implement custom exceptions in `lib/core/errors/exceptions.dart`. Define four exception classes: `ServerException implements Exception` with `final String message` field, `CacheException implements Exception` with `final String message`, `NetworkException implements Exception` with `final String message`, `UnauthorizedException implements Exception` with `final String message`. Each should have a `const` constructor.

- [X] T007 [P] Implement the base UseCase in `lib/core/usecases/usecase.dart`. Define `abstract class UseCase<Type, Params>` with a single method: `Future<Either<Failure, Type>> call(Params params)`. Also define `class NoParams extends Equatable` with `@override List<Object?> get props => []`. Import `package:dartz/dartz.dart` and `package:equatable/equatable.dart` and `../errors/failure.dart`.

- [X] T008 [P] Create environment config using Envied in `lib/core/config/env.dart`. Define `@Envied(path: '.env.dev')` abstract class `Env` with three `@EnviedField` static const fields: `apiBaseUrl` (varName: `API_BASE_URL`), `adMobAppId` (varName: `ADMOB_APP_ID`), `stripePublishableKey` (varName: `STRIPE_PUBLISHABLE_KEY`). Each field should reference `_Env.<fieldName>` (generated by envied). Import `package:envied/envied.dart`. Add `part 'env.g.dart';` at the top. After this file is created, run `dart run build_runner build --delete-conflicting-outputs` to generate `env.g.dart`.

- [X] T009 [P] Implement network info checker in `lib/core/network/network_info.dart`. Define `abstract class NetworkInfo` with method `Future<bool> get isConnected`. Implement `class NetworkInfoImpl implements NetworkInfo` that takes `InternetConnectionChecker` in constructor and delegates `isConnected` to `connectionChecker.hasConnection`. Import `package:internet_connection_checker/internet_connection_checker.dart`.

- [X] T010 [P] Create `AppColors` constants in `lib/core/theme/colors.dart`. Define `abstract class AppColors` with static const Color fields for both light and dark palettes. Light palette: `primary` (a vibrant accent color like `Color(0xFF6C63FF)` purple-blue), `onPrimary` (white), `background` (`Color(0xFFF5F5F5)`), `surface` (white), `onSurface` (dark gray `Color(0xFF1A1A2E)`), `error` (red). Dark palette: `darkPrimary` (same accent), `darkOnPrimary` (white), `darkBackground` (`Color(0xFF121212)`), `darkSurface` (`Color(0xFF1E1E2E)`), `darkOnSurface` (white), `darkError` (light red). Import `package:flutter/material.dart`.

- [X] T011 [P] Create `AppTextStyles` in `lib/core/theme/typography.dart`. Define `abstract class AppTextStyles` with static methods that return `TextStyle` using `GoogleFonts.poppins()`. Define styles: `headlineLarge` (fontSize: 28.sp, fontWeight: FontWeight.w700), `headlineMedium` (24.sp, w600), `titleLarge` (20.sp, w600), `titleMedium` (16.sp, w500), `bodyLarge` (16.sp, w400), `bodyMedium` (14.sp, w400), `labelLarge` (14.sp, w500), `labelSmall` (12.sp, w400). Each uses `.sp` from `flutter_screenutil` for the fontSize. Import `package:google_fonts/google_fonts.dart`, `package:flutter/material.dart`, `package:flutter_screenutil/flutter_screenutil.dart`.

- [X] T012 Implement `AppTheme` in `lib/core/theme/app_theme.dart`. Define `abstract class AppTheme` with two static methods: `static ThemeData get lightTheme` and `static ThemeData get darkTheme`. `lightTheme` returns `ThemeData(useMaterial3: true, brightness: Brightness.light, colorScheme: ColorScheme.light(primary: AppColors.primary, onPrimary: AppColors.onPrimary, surface: AppColors.surface, onSurface: AppColors.onSurface, error: AppColors.error), scaffoldBackgroundColor: AppColors.background, textTheme: TextTheme(headlineLarge: AppTextStyles.headlineLarge, headlineMedium: AppTextStyles.headlineMedium, titleLarge: AppTextStyles.titleLarge, titleMedium: AppTextStyles.titleMedium, bodyLarge: AppTextStyles.bodyLarge, bodyMedium: AppTextStyles.bodyMedium, labelLarge: AppTextStyles.labelLarge, labelSmall: AppTextStyles.labelSmall), appBarTheme: AppBarTheme(backgroundColor: AppColors.surface, foregroundColor: AppColors.onSurface, elevation: 0))`. `darkTheme` mirrors the same structure but uses `AppColors.dark*` variants and `Brightness.dark`. Import `colors.dart`, `typography.dart`, `package:flutter/material.dart`.

- [X] T013 [P] Create `AppDimens` constants in `lib/core/utils/app_dimens.dart`. Define `abstract class AppDimens` with static getters using ScreenUtil: `paddingXS` (4.w), `paddingS` (8.w), `paddingM` (16.w), `paddingL` (24.w), `paddingXL` (32.w), `radiusS` (8.r), `radiusM` (12.r), `radiusL` (16.r), `radiusXL` (24.r), `iconS` (16.w), `iconM` (24.w), `iconL` (32.w). Import `package:flutter_screenutil/flutter_screenutil.dart`.

- [X] T014 [P] Create `AppAssets` constants in `lib/core/utils/app_assets.dart`. Define `abstract class AppAssets` with static const String fields for asset paths: `logo` = `'assets/images/logo.png'`, `placeholder` = `'assets/images/placeholder.png'`, `errorIllustration` = `'assets/images/error.png'`, `emptyIllustration` = `'assets/images/empty.png'`, `langPath` = `'assets/lang'`. Create the `assets/images/` directory if it doesn't exist.

- [X] T015 [P] Update `AppStrings` in `lib/core/utils/app_strings.dart`. Define `abstract class AppStrings` with static const fields: `appName` = `'Glowy Wallpapers'`, `retry` = `'Retry'`, `error` = `'Something went wrong'`, `noInternet` = `'No internet connection'`, `cacheError` = `'Cache error occurred'`, `serverError` = `'Server error occurred'`, `unauthorized` = `'Unauthorized access'`, `emptyContent` = `'No content available'`, `loading` = `'Loading...'`, `home` = `'Home'`, `favorites` = `'Favorites'`, `downloads` = `'Downloads'`, `settings` = `'Settings'`, `profile` = `'Profile'`, `premium` = `'Get Premium'`.

- [X] T016 [P] Create route constants in `lib/core/routes/routes.dart`. Define `abstract class AppRoutes` with static const String fields: `splash` = `'/splash'`, `home` = `'/home'`, `login` = `'/login'`, `register` = `'/register'`, `profile` = `'/profile'`, `favorites` = `'/favorites'`, `downloads` = `'/downloads'`, `wallpaperDetail` = `'/wallpaper/:id'`, `classificationDetail` = `'/classification/:id'`, `premium` = `'/premium'`, `settings` = `'/settings'`, `about` = `'/about'`, `onboarding` = `'/onboarding'`.

- [X] T017 Implement GoRouter configuration in `lib/core/routes/app_router.dart`. Define `abstract class AppRouter` with a `static final GoRouter router = GoRouter(initialLocation: AppRoutes.splash, routes: [...])`. Add `GoRoute` entries for every route in `AppRoutes`. For `splash`: builder returns `SplashPage()`. For `home`: builder returns `HomePage()`. For all other routes: builder returns `Scaffold(body: Center(child: AutoSizeText('Route: ${route name}')))` as placeholder. Import `package:go_router/go_router.dart`, `routes.dart`, the splash page, and the home page. Use `AutoSizeText` instead of `Text` per constitution.

- [X] T018 Implement the Dio client factory in `lib/core/api/api_consumer.dart`. Define `class DioConsumer` that takes `Dio` in constructor. In the constructor: set `dio.options.baseUrl` to `Env.apiBaseUrl`, set `dio.options.responseType` to `ResponseType.json`, set `dio.options.headers` to `{'Content-Type': 'application/json', 'Accept': 'application/json'}`. Add an `addInterceptor(Interceptor interceptor)` method. Import `package:dio/dio.dart` and `../config/env.dart`.

- [X] T019 [P] Implement API interceptors in `lib/core/api/api_interceptors.dart`. Define `class AuthInterceptor extends Interceptor` that takes `FlutterSecureStorage` in constructor. Override `onRequest`: read token from secure storage key `'auth_token'`, if not null add `'Authorization': 'Bearer $token'` to `options.headers`, then call `handler.next(options)`. Override `onError`: if `err.response?.statusCode == 401`, clear the token from secure storage. Define `class LoggingInterceptor extends Interceptor` that uses `PrettyDioLogger` behavior (log request/response in dev only). Import `package:dio/dio.dart`, `package:flutter_secure_storage/flutter_secure_storage.dart`, `package:pretty_dio_logger/pretty_dio_logger.dart`.

- [X] T020 [P] Update `lib/core/api/server_strings.dart`. Define `abstract class ServerStrings` with static const String fields for API endpoint paths: `baseUrl` = `Env.apiBaseUrl` (static getter, not const since Env is generated), `login` = `'/auth/login'`, `register` = `'/auth/register'`, `logout` = `'/auth/logout'`, `categories` = `'/categories'`, `wallpapers` = `'/wallpapers'`, `favorites` = `'/favorites'`, `subscriptionStatus` = `'/subscription/status'`.

- [X] T021 Implement DI container in `lib/core/di/injection_container.dart`. Use `@InjectableInit()` annotation. Define `final GetIt sl = GetIt.instance;` at top level. Define `Future<void> configureDependencies() async` function that calls `sl.init()` (generated by injectable). Also manually register: `sl.registerLazySingleton(() => Dio())`, `sl.registerLazySingleton(() => const FlutterSecureStorage())`, `sl.registerLazySingleton(() => InternetConnectionChecker.instance)`, `sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))`, `sl.registerLazySingleton(() => DioConsumer(sl()))`. Add `part 'injection_container.config.dart';`. Import get_it, injectable, dio, flutter_secure_storage, internet_connection_checker, network_info, and api_consumer. After creating, run `dart run build_runner build --delete-conflicting-outputs`.

- [X] T022 [P] Update localization in `lib/core/localization/localization_manager.dart`. Ensure `easy_localization` is properly configured. Define a class or constants: `static const supportedLocales = [Locale('en')]`, `static const fallbackLocale = Locale('en')`, `static const path = 'assets/lang'`. Ensure `assets/lang/en.json` exists with at least `{"app_name": "Glowy Wallpapers", "retry": "Retry", "error": "Something went wrong", "no_internet": "No internet connection", "loading": "Loading..."}`.

**Checkpoint**: Foundation ready — all core infrastructure is in place. User story implementation can now begin.

---

## Phase 3: User Story 1 — App Launches and Reaches Home Shell (Priority: P1)

**Goal**: The app cold-starts, shows a branded #121212 native splash, initializes all core services (Hive, DI, Firebase), and navigates to an empty Home screen shell. No crashes, no white flash.

**Independent Test**: Build and install on Android/iOS emulator. Cold start the app. Verify: native splash appears instantly (dark background), then Home screen renders with correct theme colors and AppBar.

### Implementation for User Story 1

- [X] T023 [US1] Implement `SplashPage` in `lib/features/splash/presentation/pages/splash_page.dart`. This is a `StatefulWidget`. In `initState`, call an async `_initializeApp()` method. `_initializeApp` should: (1) `await Future.delayed(Duration(seconds: 2))` to show splash branding, (2) then navigate to home using `context.go(AppRoutes.home)`. The `build` method returns a `Scaffold` with `backgroundColor: Color(0xFF121212)` and a `Center` child showing the app logo (use `Image.asset(AppAssets.logo)` wrapped in a `SizedBox` with `width: 150.w, height: 150.w`). If logo asset doesn't exist, show `AutoSizeText('Glowy Wallpapers', style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold))` as fallback. Import go_router, app_routes, app_assets, flutter_screenutil, auto_size_text.

- [X] T024 [US1] Implement `HomePage` in `lib/features/home/presentation/pages/home_page.dart`. This is a `StatelessWidget`. Returns `Scaffold` with: `appBar: AppBar(title: AutoSizeText(AppStrings.appName), centerTitle: true)`, `body: Center(child: AutoSizeText(AppStrings.emptyContent, style: Theme.of(context).textTheme.bodyLarge))`. This is an empty shell — content is added in Phase 3 of the roadmap. Import app_strings, auto_size_text, flutter/material.dart.

- [X] T025 [US1] Implement `main.dart` in `lib/main.dart`. The `main()` function must: (1) `WidgetsFlutterBinding.ensureInitialized()`, (2) `await EasyLocalization.ensureInitialized()`, (3) Initialize Hive: `await Hive.initFlutter()`, (4) Call `await configureDependencies()` from DI container, (5) Initialize Firebase: wrap `await Firebase.initializeApp()` in a try-catch that logs warning but does NOT block (per FR-007), (6) Run the app: `runApp(EasyLocalization(supportedLocales: [Locale('en')], path: 'assets/lang', fallbackLocale: Locale('en'), child: const GlowyApp()))`. Import easy_localization, hive_flutter, firebase_core, injection_container, and the app widget.

- [X] T026 [US1] Create `GlowyApp` widget in `lib/app.dart`. This is a `StatelessWidget`. The `build` method returns `ScreenUtilInit(designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true, builder: (context, child) => MaterialApp.router(title: AppStrings.appName, debugShowCheckedModeBanner: false, theme: AppTheme.lightTheme, darkTheme: AppTheme.darkTheme, themeMode: ThemeMode.system, routerConfig: AppRouter.router, localizationsDelegates: context.localizationDelegates, supportedLocales: context.supportedLocales, locale: context.locale))`. Import flutter_screenutil, app_theme, app_router, app_strings, easy_localization.

**Checkpoint**: At this point, the app should compile, show the dark splash, and navigate to an empty Home screen. Run `flutter run` to verify.

---

## Phase 4: User Story 2 — Theme Switches Between Light and Dark (Priority: P2)

**Goal**: The app respects system light/dark mode and switches instantly. All surfaces use theme colors from AppTheme, not hardcoded values.

**Independent Test**: With the app running, toggle OS dark mode. Verify all surfaces (scaffold background, AppBar, text) update immediately without restart.

### Implementation for User Story 2

- [X] T027 [US2] Verify `AppTheme.lightTheme` and `AppTheme.darkTheme` in `lib/core/theme/app_theme.dart` both have complete `ColorScheme`, `textTheme`, `appBarTheme`, `scaffoldBackgroundColor`, `cardTheme`, and `iconTheme` configured. If any are missing, add them. Light: scaffold background `AppColors.background`, card color `AppColors.surface`. Dark: scaffold background `AppColors.darkBackground`, card color `AppColors.darkSurface`. Ensure `useMaterial3: true` is set on both.

- [X] T028 [US2] Update `HomePage` in `lib/features/home/presentation/pages/home_page.dart` to use only theme-derived colors. Ensure `AppBar` does NOT hardcode any color — it should inherit from `appBarTheme`. Ensure body text uses `Theme.of(context).textTheme.bodyLarge` not inline styles. Ensure `Scaffold` does NOT set `backgroundColor` explicitly (let it inherit from `scaffoldBackgroundColor` in ThemeData).

- [X] T029 [US2] Update `SplashPage` in `lib/features/splash/presentation/pages/splash_page.dart`. The splash screen is special — it always uses `Color(0xFF121212)` background regardless of system theme (this matches the native splash). However, any text on the splash should use white color (`Colors.white`) explicitly since theme may not be fully loaded yet. This is the ONE exception to "no hardcoded colors" — document with a comment: `// Matches native splash background - intentionally hardcoded`.

**Checkpoint**: Toggle system dark/light mode. Home screen should switch themes instantly. Splash stays dark always.

---

## Phase 5: User Story 3 — Errors Surfaced Clearly (Priority: P3)

**Goal**: When initialization fails (no network, cache error), the app shows a typed error screen with retry — never crashes or shows white screen.

**Independent Test**: Disable network on device, launch app. Verify an error screen with retry button appears. Re-enable network, tap retry, verify app reaches Home.

### Implementation for User Story 3

- [X] T030 [P] [US3] Create `AppErrorWidget` in `lib/core/widgets/app_error_widget.dart`. A `StatelessWidget` that takes `String message` and `VoidCallback onRetry` parameters. Returns a `Center` child with a `Column(mainAxisAlignment: MainAxisAlignment.center)` containing: (1) `Icon(Icons.error_outline, size: AppDimens.iconL * 2, color: Theme.of(context).colorScheme.error)`, (2) `Gap(AppDimens.paddingM)` (from gap package), (3) `AutoSizeText(message, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center)`, (4) `Gap(AppDimens.paddingL)`, (5) `ElevatedButton(onPressed: onRetry, child: AutoSizeText(AppStrings.retry))`. Import gap, auto_size_text, app_dimens, app_strings, flutter/material.dart.

- [X] T031 [P] [US3] Create `AppLoading` widget in `lib/core/widgets/app_loading.dart`. A `StatelessWidget`. Returns `Center(child: SpinKitFadingCircle(color: Theme.of(context).colorScheme.primary, size: 50.w))`. Import flutter_spinkit, flutter_screenutil, flutter/material.dart. Also create a static method `static void show(BuildContext context)` that calls `context.loaderOverlay.show(widgetBuilder: (_) => AppLoading())` and `static void hide(BuildContext context)` that calls `context.loaderOverlay.hide()`. Import loader_overlay.

- [X] T032 [P] [US3] Create `AppCachedImage` widget in `lib/core/widgets/app_cached_image.dart`. A `StatelessWidget` with `String imageUrl`, `double? width`, `double? height`, `BoxFit fit = BoxFit.cover` parameters. Returns `CachedNetworkImage(imageUrl: imageUrl, width: width, height: height, fit: fit, placeholder: (context, url) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(width: width, height: height, color: Colors.white)), errorWidget: (context, url, error) => Icon(Icons.broken_image, size: AppDimens.iconL))`. Import cached_network_image, shimmer, app_dimens, flutter/material.dart.

- [X] T033 [P] [US3] Create `AdaptiveGrid` widget in `lib/core/widgets/adaptive_grid.dart`. A `StatelessWidget` with `List<Widget> children`, `double childAspectRatio = 0.75`, `double spacing` (default `AppDimens.paddingS`) parameters. In `build`, use `LayoutBuilder` to determine columns: width < 400 → 2 columns, width < 700 → 3 columns, else 4 columns. Return `GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: spacing, mainAxisSpacing: spacing, childAspectRatio: childAspectRatio), itemCount: children.length, itemBuilder: (context, index) => children[index])`. Import flutter/material.dart, app_dimens.

- [X] T034 [US3] Update `SplashPage` in `lib/features/splash/presentation/pages/splash_page.dart` to handle initialization failures. Wrap the `_initializeApp()` body in a try-catch. On success: navigate to home. On `CacheException`: set state to show `AppErrorWidget(message: AppStrings.cacheError, onRetry: _initializeApp)`. On any other exception: show `AppErrorWidget(message: AppStrings.error, onRetry: _initializeApp)`. Add a `bool _hasError = false` and `String _errorMessage = ''` state fields. In `build`: if `_hasError` return `Scaffold(backgroundColor: Color(0xFF121212), body: AppErrorWidget(message: _errorMessage, onRetry: () { setState(() => _hasError = false); _initializeApp(); }))`, else show the normal splash UI. Import app_error_widget, exceptions.

- [X] T035 [US3] Update `lib/core/widgets/widgets.dart` to export all core widgets. Add: `export 'app_cached_image.dart';`, `export 'app_error_widget.dart';`, `export 'app_loading.dart';`, `export 'adaptive_grid.dart';`, `export 'custom_button.dart';`, `export 'custom_text_field.dart';`.

**Checkpoint**: Disable network/simulate failure during init. Error screen with retry should appear. Tap retry with network restored → reaches Home.

---

## Phase 6: User Story 4 — App Renders Correctly Across Screen Sizes (Priority: P4)

**Goal**: The empty Home shell and all core widgets scale correctly from 360dp phone to 768dp+ tablet with no overflow or clipping.

**Independent Test**: Run on 360dp, 390dp, and 768dp emulators. Verify no overflow warnings in console, all text legible, layout proportional.

### Implementation for User Story 4

- [X] T036 [US4] Audit `HomePage` in `lib/features/home/presentation/pages/home_page.dart`. Ensure all padding uses `AppDimens` (e.g., `EdgeInsets.all(AppDimens.paddingM)`), all text sizes come from theme textTheme (which already uses `.sp`), and no fixed pixel widths exist. If the AppBar title overflows on small screens, wrap in `Flexible` or confirm `AutoSizeText` handles it.

- [X] T037 [US4] Audit `SplashPage` in `lib/features/splash/presentation/pages/splash_page.dart`. Ensure logo/text sizing uses `.w` and `.sp` from ScreenUtil. Ensure `AppErrorWidget` (shown on failure) doesn't overflow on 360dp screens — the error message should be wrapped in `Padding(padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingL))`.

- [X] T038 [US4] Audit `AppErrorWidget` in `lib/core/widgets/app_error_widget.dart`. Wrap the entire Column in `Padding(padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingXL))`. Ensure `AutoSizeText` has `maxLines: 3` to prevent overflow. Ensure the icon size uses ScreenUtil: `size: 64.w` instead of hardcoded pixels.

- [X] T039 [US4] Verify `ScreenUtilInit` in `lib/app.dart` has `designSize: const Size(375, 812)` (iPhone X reference), `minTextAdapt: true`, `splitScreenMode: true`. These ensure proper scaling across all form factors.

**Checkpoint**: Run app on 360dp, 390dp, 768dp emulators. Zero overflow warnings in debug console.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup, code generation, and validation.

- [X] T040 [P] Run `dart run build_runner build --delete-conflicting-outputs` to generate all `.g.dart` files (envied, injectable). Verify no build_runner errors.

- [X] T041 [P] Run `dart run flutter_native_splash:create` to generate native splash assets from `flutter_native_splash.yaml`. Verify splash appears on cold start.

- [X] T042 Run `dart format .` on the entire project to ensure consistent formatting per constitution.

- [X] T043 Run `flutter analyze` and fix ALL warnings. Constitution requires zero warnings. Common issues: unused imports, missing return types, uninitialized fields. Fix each one.

- [X] T044 Verify the app compiles and runs on both Android (`flutter run`) and iOS (`flutter run` on macOS with simulator). Confirm: native splash shows → Home screen renders → no crashes. This is the Phase 1 exit criteria.

- [X] T045 [P] Ensure `.gitignore` includes: `*.g.dart` (optional — some teams commit generated files), `.env.*`, `.dart_tool/`, `build/`, `.flutter-plugins`, `.flutter-plugins-dependencies`. Verify no secrets are tracked.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (T001 must complete first for packages)
- **US1 (Phase 3)**: Depends on Phase 2 (needs DI, routing, theme, errors)
- **US2 (Phase 4)**: Depends on US1 (needs HomePage and SplashPage to exist)
- **US3 (Phase 5)**: Depends on US1 (needs SplashPage init flow to add error handling to)
- **US4 (Phase 6)**: Depends on US1 + US3 (needs all widgets to exist for auditing)
- **Polish (Phase 7)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Depends only on Phase 2. MVP target.
- **US2 (P2)**: Depends on US1 (needs themed pages to verify).
- **US3 (P3)**: Depends on US1 (needs splash init flow). Can run parallel with US2.
- **US4 (P4)**: Depends on US1 + US3 (needs all widgets created).

### Within Each User Story

- Models/entities before services
- Core widgets before pages that use them
- Pages before integration/wiring
- Story complete before moving to next priority

### Parallel Opportunities

- T002, T003, T004 can all run in parallel (Phase 1 — different files)
- T005–T022: All tasks marked [P] can run in parallel within Phase 2
- T030, T031, T032, T033 can all run in parallel (US3 — different widget files)
- US2 and US3 can run in parallel after US1 completes

---

## Parallel Example: Phase 2 Foundation

```bash
# These can all run at the same time (different files, no cross-dependencies):
Task T006: "Create exceptions in lib/core/errors/exceptions.dart"
Task T007: "Create UseCase base in lib/core/usecases/usecase.dart"
Task T008: "Create Env config in lib/core/config/env.dart"
Task T009: "Create NetworkInfo in lib/core/network/network_info.dart"
Task T010: "Create AppColors in lib/core/theme/colors.dart"
Task T011: "Create AppTextStyles in lib/core/theme/typography.dart"
Task T013: "Create AppDimens in lib/core/utils/app_dimens.dart"
Task T014: "Create AppAssets in lib/core/utils/app_assets.dart"
Task T015: "Create AppStrings in lib/core/utils/app_strings.dart"
Task T016: "Create AppRoutes in lib/core/routes/routes.dart"
Task T019: "Create interceptors in lib/core/api/api_interceptors.dart"
Task T020: "Create ServerStrings in lib/core/api/server_strings.dart"
Task T022: "Setup localization in lib/core/localization/localization_manager.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T004)
2. Complete Phase 2: Foundational (T005–T022) — CRITICAL, blocks everything
3. Complete Phase 3: User Story 1 (T023–T026)
4. **STOP and VALIDATE**: `flutter run` — splash shows, Home renders
5. This is the MVP — app compiles and runs on both platforms

### Incremental Delivery

1. Setup + Foundational → Infrastructure ready
2. Add US1 → App launches and shows Home (MVP!)
3. Add US2 → Theme switching works correctly
4. Add US3 → Error handling with retry is wired
5. Add US4 → Responsive scaling verified across devices
6. Polish → Zero warnings, formatted, splash generated

---

## Notes

- [P] tasks = different files, no dependencies — safe to implement simultaneously
- [Story] label maps task to specific user story for traceability
- Each task includes exact file paths and explicit code guidance for cheaper LLM execution
- Constitution requires `AutoSizeText` instead of `Text`, `CachedNetworkImage` instead of `Image.network`, ScreenUtil `.w/.h/.sp/.r` for all sizes
- Commit after each completed phase or logical task group
- Run `flutter analyze` frequently to catch issues early
- All generated files (`*.g.dart`) require running `dart run build_runner build --delete-conflicting-outputs`
