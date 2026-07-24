# glowy_wallpaper Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-07-24

## Active Technologies
- Dart 3.11.3 / Flutter 3.41.5 + flutter_bloc, freezed, injectable + get_it, dio + retrofit, go_router, flutter_secure_storage, auto_size_text, flutter_screenutil, dartz, equatable (002-auth-user-profile)
- flutter_secure_storage (auth token), Hive (cached user data) (002-auth-user-profile)
- Dart 3.11.3 / Flutter 3.41.5 + flutter_bloc, freezed, injectable + get_it, dio + retrofit, go_router, hive + hive_flutter, cached_network_image, auto_size_text, flutter_screenutil, dartz, equatable, video_player (NEW), visibility_detector (NEW) (003-home-categories-grids)
- Hive (category cache, wallpaper page cache) (003-home-categories-grids)
- Dart 3.11.3 / Flutter 3.41.5 + flutter_bloc (Cubit), freezed, injectable + get_it, dio + retrofit, go_router, hive + hive_flutter, cached_network_image, video_player, visibility_detector, dartz, equatable, flutter_screenutil, auto_size_text, gal (NEW — gallery saver), permission_handler (NEW), lottie (existing — for empty state animations) (004-detail-download-favorites)
- Hive (favorites local box, downloads local box), flutter_secure_storage (auth tokens — existing) (004-detail-download-favorites)
- Dart 3.11.3 / Flutter 3.41.5 + google_mobile_ads ^5.3.0 (existing), in_app_purchase ^3.2.0 (NEW), flutter_bloc, freezed, injectable + get_it, dio + retrofit, firebase_analytics (existing) (005-admob-iap-monetization)
- Hive (subscription_cache box, ad_frequency box — NEW), flutter_secure_storage (auth tokens — existing) (005-admob-iap-monetization)
- Dart 3.11.3 / Flutter 3.41.5 + firebase_messaging ^15.2.5, flutter_local_notifications ^18.0.1, firebase_analytics ^11.4.5, url_launcher, share_plus, shimmer, flutter_launcher_icons, flutter_native_splash, permission_handler (existing) (006-firebase-polish-store)
- Hive (`notification_prefs` box — new, stores "permission-requested" flag), flutter_secure_storage (tokens — existing) (006-firebase-polish-store)
- Dart 3.11.3 / Flutter 3.41.5 + flutter_bloc (Cubit + Freezed), injectable + get_it, dio (public Dio instance), hive + hive_flutter, dartz Either, mocktail + bloc_test (tests) (007-api-integration)
- Hive box `app_bootstrap` (new) for `AppMetadataModel` JSON cache; existing `categories_cache` box superseded (007-api-integration)
- Dart 3.11.3 / Flutter 3.41.5 + flutter_bloc (Cubit + Freezed), go_router, dio, hive, injectable + get_it, cached_network_image, auto_size_text, flutter_screenutil, share_plus, url_launcher (008-fix-runtime-bugs)
- Hive (app_bootstrap box for AppMetadataModel cache) (008-fix-runtime-bugs)
- Dart 3.11.3 / Flutter 3.41.5 + flutter_bloc (Cubit + Freezed), go_router, dio, hive + hive_flutter, cached_network_image, video_player, gal, permission_handler, injectable + get_it, dartz, flutter_screenutil, auto_size_text (009-fix-favorites-download-preview)
- Hive (favorites box, downloads box) — local device storage (009-fix-favorites-download-preview)
- Dart 3.11.3 / Flutter 3.41.5 + google_mobile_ads (existing), flutter_bloc (Cubit + Freezed), get_it + injectable, firebase_analytics (010-admob-ad-units-setup)
- Hive (ad_frequency box for cooldown tracking), flutter_secure_storage (tokens) (010-admob-ad-units-setup)
- Dart 3.11.3 / Flutter 3.41.5 + flutter_bloc (Cubit + Freezed), dio, dartz, get_it, permission_handler, internet_connection_checker, connectivity_plus, google_mobile_ads, firebase_analytics, image_gallery_saver_plus (NEW), flutter_screenutil (011-download-connectivity-ux)
- Hive (downloads box, app_bootstrap), flutter_secure_storage (auth tokens) (011-download-connectivity-ux)
- Dart 3.11.3 / Flutter 3.41.5 + `flutter_staggered_grid_view ^0.7.0` (new), `cached_network_image` (existing), `shimmer` (existing), `flutter_screenutil` (existing), `flutter_bloc` (existing) (015-pinterest-staggered-grid)
- No new storage — aspect ratios are decoded in-memory per card widget lifetime; no persistence needed (015-pinterest-staggered-grid)
- Dart 3.11.3 / Flutter 3.41.5 + `google_mobile_ads ^5.3.0` (already present; includes UMP `ConsentInformation`/`ConsentForm`), `flutter_bloc`, `get_it` (manual registration — no injectable codegen in this repo), `firebase_analytics`, `flutter_screenutil`, `loader_overlay` + `flutter_spinkit` (loading overlays), `auto_size_text`, `envied` (prod config) (016-admob-ads-integration)
- None new. Interstitial frequency/cooldown state is **in-memory per session** (Clarification Q1). Existing `ad_frequency` Hive box is NOT used by the new managers. Consent state is persisted by the UMP SDK itself. (016-admob-ads-integration)
- Dart 3.11.3 / Flutter 3.41.5 + firebase_core, firebase_messaging, flutter_local_notifications, (017-fcm-notifications)
- Hive box `notification_prefs` (existing — stores `permission_requested` flag). No new box. (017-fcm-notifications)
- Dart 3.11.3 / Flutter 3.41.5 + `dio` (isolate-side transfer), `dart:isolate` (new usage, stdlib), (018-disable-ads-isolate-downloads)
- Hive `downloads` box (unchanged schema); `flutter_secure_storage` for tokens (untouched) (018-disable-ads-isolate-downloads)

- Dart 3.11.3 / Flutter 3.41.5 + flutter_bloc, freezed, injectable + get_it, dio + retrofit, go_router, hive + flutter_secure_storage, flutter_screenutil, envied, dartz, google_fonts (Poppins), cached_network_image, auto_size_text, loader_overlay + flutter_spinkit, easy_localization (001-phase1-foundation)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Dart 3.11.3 / Flutter 3.41.5

## Code Style

Dart 3.11.3 / Flutter 3.41.5: Follow standard conventions

## Recent Changes
- 018-disable-ads-isolate-downloads: Added Dart 3.11.3 / Flutter 3.41.5 + `dio` (isolate-side transfer), `dart:isolate` (new usage, stdlib),
- 017-fcm-notifications: Added Dart 3.11.3 / Flutter 3.41.5 + firebase_core, firebase_messaging, flutter_local_notifications,
- 016-admob-ads-integration: Added Dart 3.11.3 / Flutter 3.41.5 + `google_mobile_ads ^5.3.0` (already present; includes UMP `ConsentInformation`/`ConsentForm`), `flutter_bloc`, `get_it` (manual registration — no injectable codegen in this repo), `firebase_analytics`, `flutter_screenutil`, `loader_overlay` + `flutter_spinkit` (loading overlays), `auto_size_text`, `envied` (prod config)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
