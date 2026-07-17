# Implementation Plan: Firebase, Polish & Store Readiness

**Branch**: `006-firebase-polish-store` | **Date**: 2026-03-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/006-firebase-polish-store/spec.md`

## Summary

Implement the final production-readiness phase for Glowy Wallpapers: Firebase Cloud Messaging push notifications with GoRouter deep-link routing (including a pending-route queue for logged-out users), wire up all placeholder side-menu actions, apply a consistent four-state pattern (shimmer skeleton, error+retry, empty+illustration, success) across every content screen, polish responsive layouts for tablets, configure adaptive app icons and native splash, and prepare complete Play Store / App Store metadata for submission.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: firebase_messaging ^15.2.5, flutter_local_notifications ^18.0.1, firebase_analytics ^11.4.5, url_launcher, share_plus, shimmer, flutter_launcher_icons, flutter_native_splash, permission_handler (existing)
**Storage**: Hive (`notification_prefs` box — new, stores "permission-requested" flag), flutter_secure_storage (tokens — existing)
**Testing**: mocktail, bloc_test, flutter_test
**Target Platform**: Android (min SDK 23) + iOS (min 14)
**Project Type**: mobile-app
**Performance Goals**: Notification delivery ≤5s, tap→navigation ≤2s, shimmer visible for ≥1 frame before any content screen loads
**Constraints**: Offline-capable (all bootstrap content cached), permission request deferred until after first download or favorite action
**Scale/Scope**: ~14 screens to receive shimmer/error/empty state treatment, 1 new notification feature, 2 platform store listings

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture | ✅ PASS | `NotificationService` abstract contract in domain; impl in data; no presentation logic in service |
| II. SOLID & DRY | ✅ PASS | Shared `AppShimmerWidget`, `AppEmptyStateWidget`, `AppErrorStateWidget` in `core/widgets`; no duplication across screens |
| III. Responsive-First (ScreenUtil) | ✅ PASS | All new widgets use `.w/.h/.sp/.r`; adaptive grid already in plan |
| IV. Theming | ✅ PASS | Shimmer and state widgets use `Theme.of(context)` colors; no inlined values |
| V. Error Handling (Either + 4-state) | ✅ PASS | This phase *completes* 4-state pattern for all screens |
| VI. Performance (no leaks) | ✅ PASS | `NotificationService` disposes stream subscription in `close()`; shimmer uses `AnimationController` with dispose |
| VII. Testing (unit tests required) | ✅ PASS | `NotificationService`, pending-route logic, and shimmer widget covered in tests |
| VIII. Monetization & Firebase | ✅ PASS | `flutter_local_notifications` for foreground FCM (constitutionally required); analytics events logged for notification_tapped |

**No violations.** Complexity Tracking table not required.

## Project Structure

### Documentation (this feature)

```text
specs/006-firebase-polish-store/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/
│   ├── notification_service_contract.md
│   └── side_menu_contract.md
└── tasks.md             ← /speckit.tasks output (not created here)
```

### Source Code (additions this phase)

```text
lib/
├── features/
│   └── notifications/                        # NEW feature
│       ├── domain/
│       │   ├── entities/
│       │   │   └── notification_payload.dart  # deep-link entity
│       │   └── services/
│       │       └── notification_service.dart  # abstract contract
│       └── data/
│           └── services/
│               └── notification_service_impl.dart  # FCM + local notif impl
├── core/
│   ├── widgets/
│   │   ├── app_shimmer_widget.dart           # NEW shared shimmer wrapper
│   │   ├── app_empty_state_widget.dart       # NEW (lottie + message)
│   │   └── app_error_state_widget.dart       # UPDATE (ensure consistent API)
│   └── routes/
│       └── app_router.dart                   # UPDATE: pending-route redirect after login
├── features/
│   ├── home/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── home_drawer.dart          # UPDATE: wire Rate/Share/Feedback
│   └── splash/
│       └── presentation/
│           └── pages/
│               └── splash_page.dart          # UPDATE: FCM init + getInitialMessage
└── main.dart                                 # UPDATE: NotificationService.initialize()

android/
├── app/
│   ├── google-services.json                  # EXISTING (already downloaded)
│   └── src/main/res/
│       ├── mipmap-*/                         # UPDATE: adaptive icon layers
│       └── drawable/
│           └── ic_notification.xml           # NEW: notification icon
ios/
└── Runner/
    └── GoogleService-Info.plist              # ADD from Firebase Console

assets/
├── animations/
│   └── empty_state.json                     # ADD Lottie animation for empty states
└── icons/
    └── ic_launcher.png                      # ADD app icon source

store/
├── play_store/
│   ├── description.txt
│   ├── short_description.txt
│   ├── changelogs/
│   │   └── default.txt
│   └── screenshots/                         # phone + 7-inch + 10-inch
└── app_store/
    ├── description.txt
    ├── keywords.txt
    └── screenshots/                         # 6.5-inch + 12.9-inch iPad
```

**Structure Decision**: Feature-first Clean Architecture. The `notifications` feature is a new top-level feature with its own domain contract and data implementation. Shared UI state widgets (shimmer, empty, error) live in `core/widgets` since every feature reuses them.

## Phase 0: Research

*See [research.md](research.md) for full findings. Key decisions summarized:*

1. **Foreground FCM → flutter_local_notifications**: Use `FirebaseMessaging.onMessage` stream → call `FlutterLocalNotificationsPlugin.show()` to display a heads-up notification. The notification `payload` field carries the deep-link route string.

2. **Background / terminated FCM → GoRouter**:
   - Background: `FirebaseMessaging.onMessageOpenedApp` → call `router.go(route)`
   - Terminated: `FirebaseMessaging.instance.getInitialMessage()` in splash → store route, navigate after init
   - Pending route is stored in `NotificationService.pendingRoute` (in-memory nullable String)

3. **Logged-out deep-link queue**: When `onMessageOpenedApp` fires and user is not logged in, store the deep-link route in `NotificationService.pendingRoute`. The GoRouter redirect guard reads `pendingRoute` after login completes and navigates there, then clears it.

4. **Notification permission timing**: After the user's first successful download or favorite action. Detected in `WallpaperDetailCubit` (already handles both actions). A Hive `notification_prefs` box stores a `permission_requested` bool to ensure we only ask once.

5. **shimmer package**: Wrap `Shimmer.fromColors()` around placeholder `Container` widgets sized to match the real content layout. `AppShimmerWidget` accepts a `child` (the placeholder skeleton) and handles colors via `Theme.of(context)`.

6. **flutter_launcher_icons**: Configured in `pubspec.yaml` under `flutter_icons:` with `adaptive_icon_foreground` and `adaptive_icon_background` for Android; `ios: true` with a single 1024×1024 source PNG.

## Phase 1: Design & Contracts

*See [data-model.md](data-model.md) for entities and [contracts/](contracts/) for interface contracts.*

### Key Design Decisions

#### NotificationService Architecture
```
abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Stream<NotificationPayload> get onNotificationTap;
  String? get pendingRoute;
  void clearPendingRoute();
}
```
Implementation (`NotificationServiceImpl`) uses `firebase_messaging` + `flutter_local_notifications`. Registered as a `LazySingleton` in GetIt. Initialized in `main()` before `runApp()`.

#### Pending Route Flow
```
FCM tap (background/terminated)
  └─► NotificationServiceImpl.pendingRoute = route
        └─► Splash checks pendingRoute after init
              ├─► Logged in → router.go(pendingRoute) immediately
              └─► Logged out → router.go('/login') with pendingRoute preserved
                    └─► Login success → router.go(pendingRoute); clearPendingRoute()
```

#### Shimmer Pattern
Every screen that already has a `Status.loading` state replaces its current loading widget (likely `AppLoading`) with an `AppShimmerWidget` containing a skeleton matching the layout. The `AppLoading` spinner is kept only for full-page blocking operations (download, purchase).

#### Side Menu Wiring (home_drawer.dart)
- **Rate App**: `launchUrl(Uri.parse(Platform.isIOS ? appData.iphoneShareLink : appData.androidShareLink))` using the store review URL from bootstrap
- **Share App**: `Share.share(shareLink)` via `share_plus`
- **Send Feedback**: `launchUrl(Uri.parse('mailto:${appData.contactEmail}'))`
- **About / Privacy Policy / Terms**: Already route to `/about` — update to pass content type as route extra

#### Notification Permission Request
Triggered from `WallpaperDetailCubit` after `_toggleFavorite()` or `_downloadWallpaper()` succeeds, if `NotificationService.hasRequestedPermission == false`. Uses `FirebaseMessaging.instance.requestPermission()`.

### File Change Summary

| File | Change Type | Purpose |
|------|-------------|---------|
| `lib/features/notifications/domain/entities/notification_payload.dart` | CREATE | Deep-link payload entity |
| `lib/features/notifications/domain/services/notification_service.dart` | CREATE | Abstract service contract |
| `lib/features/notifications/data/services/notification_service_impl.dart` | CREATE | FCM + local notif impl |
| `lib/core/widgets/app_shimmer_widget.dart` | CREATE | Shared shimmer wrapper |
| `lib/core/widgets/app_empty_state_widget.dart` | CREATE | Shared empty state |
| `lib/core/di/injection_container.dart` | UPDATE | Register NotificationService |
| `lib/main.dart` | UPDATE | NotificationService.initialize() |
| `lib/core/routes/app_router.dart` | UPDATE | Pending-route redirect logic |
| `lib/features/splash/presentation/pages/splash_page.dart` | UPDATE | getInitialMessage(), pendingRoute |
| `lib/features/home/presentation/widgets/home_drawer.dart` | UPDATE | Wire Rate/Share/Feedback |
| `lib/features/detail/presentation/cubit/wallpaper_detail_cubit.dart` | UPDATE | Notification permission trigger |
| *(all content screens)* | UPDATE | Replace loading with shimmer, standardise empty/error |
| `pubspec.yaml` | UPDATE | flutter_launcher_icons config |
| `android/app/src/main/…` | UPDATE | Adaptive icon assets |
| `ios/Runner/GoogleService-Info.plist` | ADD | iOS Firebase config |
| `store/play_store/`, `store/app_store/` | CREATE | Store metadata files |
