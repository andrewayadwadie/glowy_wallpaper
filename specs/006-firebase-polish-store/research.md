# Research: Firebase, Polish & Store Readiness

**Feature**: 006-firebase-polish-store | **Date**: 2026-03-25

---

## Decision 1: FCM Foreground Notification Display

**Decision**: Use `flutter_local_notifications` to display heads-up notifications when the app is in the foreground.

**Rationale**: `firebase_messaging` does not display a visible notification when the app is in the foreground on its own — it only fires the `onMessage` stream. `flutter_local_notifications` (already in `pubspec.yaml` v18.0.1 and mandated by the project constitution) bridges this gap. The notification's `payload` field carries the deep-link route string so tapping it can navigate.

**Alternatives considered**:
- Custom in-app banner widget: More work, inconsistent with platform OS notification UX. Rejected.
- Ignore foreground notifications: Fails FR-004. Rejected.

**Implementation notes**:
- Initialize `FlutterLocalNotificationsPlugin` once in `NotificationServiceImpl.initialize()`.
- Android channel: `id = 'high_importance_channel'`, importance `Importance.max`, priority `Priority.high`.
- iOS: `DarwinInitializationSettings(requestAlertPermission: false)` — we request permission separately.
- `onMessage.listen()` → call `flutterLocalNotificationsPlugin.show(...)`.

---

## Decision 2: FCM Background & Terminated Deep-Link Routing

**Decision**: Use `FirebaseMessaging.onMessageOpenedApp` for background taps and `FirebaseMessaging.instance.getInitialMessage()` for terminated-state taps. Store the route in `NotificationService.pendingRoute`.

**Rationale**: These are the two official FCM callback channels for non-foreground deep links. The pending-route pattern in the `NotificationService` singleton decouples routing from FCM callbacks and allows the GoRouter auth guard to redirect after login.

**Alternatives considered**:
- Handle routing directly in FCM callbacks: Requires `BuildContext` which is unavailable in background isolates. Rejected.
- Use GoRouter's `redirect` for deep links: Redirect runs on every navigation event — polling a pending route here is clean and well-established.

**Pending-route queue flow**:
```
Notification tapped (background/terminated)
  → NotificationService.pendingRoute = '/wallpaper/abc123'

App init (splash):
  → if logged in:  router.go(pendingRoute); clearPendingRoute()
  → if logged out: router.go('/login')  ← pendingRoute preserved

Login success:
  → GoRouter redirect checks NotificationService.pendingRoute
  → router.go(pendingRoute); clearPendingRoute()
```

---

## Decision 3: Notification Permission Request Timing

**Decision**: Request permission after the user's first successful download or favorite action.

**Rationale**: Contextual permission requests (shown when the user has just experienced value) yield 2–3× higher grant rates than prompting on first launch. The WallpaperDetailCubit already handles both download and favorite outcomes — adding a permission check there requires minimal code. A Hive `notification_prefs` box with a `permission_requested` bool ensures we ask at most once.

**Alternatives considered**:
- On first app launch: Highest denial rate. Rejected per clarification answer.
- After login: Slightly better but user hasn't seen value yet. Rejected.
- Never automatically: Would require a separate settings UI. Over-engineering. Rejected.

**Implementation notes**:
- Hive box key: `notification_prefs`, field: `permission_requested` (bool, default false).
- After `_downloadWallpaper()` or `_toggleFavorite()` returns Right: check flag → call `NotificationService.requestPermission()` → set flag to true.
- `FirebaseMessaging.instance.requestPermission()` returns `NotificationSettings`; log the result to analytics.

---

## Decision 4: Shimmer Skeleton Implementation

**Decision**: Use the `shimmer` package (already in pubspec per constitution) with a shared `AppShimmerWidget` wrapper in `core/widgets`.

**Rationale**: `shimmer` is already listed as a mandatory package in the constitution. A shared wrapper ensures consistent base colors across all screens and avoids duplicating `Shimmer.fromColors()` calls.

**Implementation notes**:
- `AppShimmerWidget({required Widget child})` — wraps `Shimmer.fromColors` with theme-aware base/highlight colors.
- Each screen defines its own skeleton child using `Container` + `BorderRadius` matching the real content layout.
- Skeleton containers use `AppColors.shimmerBase` and `AppColors.shimmerHighlight` for light/dark theme support.

**Alternatives considered**:
- Individual Shimmer calls per screen: Produces inconsistent colors. Rejected.
- `skeletonizer` package: Additional dependency not in constitution. Rejected.

---

## Decision 5: Shared AppEmptyStateWidget & AppErrorStateWidget

**Decision**: Create `AppEmptyStateWidget` and standardise the existing (or create) `AppErrorStateWidget` as reusable widgets in `core/widgets`.

**Rationale**: Constitution principle II (DRY) and principle V (4-state pattern) require these to exist once and be reused. Empty state uses a Lottie animation (package already present) for visual quality.

**Implementation notes**:
- `AppEmptyStateWidget({String? title, String? message, String? lottieAsset})` — defaults to a generic empty-state animation.
- `AppErrorStateWidget({required String message, required VoidCallback onRetry})` — shows message + elevated "Retry" button.
- Both use `AppTextStyles` and `AppColors`; no inlined values.

---

## Decision 6: Flutter Launcher Icons & Native Splash

**Decision**: Use `flutter_launcher_icons` for icon generation and `flutter_native_splash` for splash (already in `pubspec.yaml`).

**Rationale**: Both packages are already listed as mandatory in the constitution. `flutter_launcher_icons` supports adaptive icons (Android 8+) via `adaptive_icon_foreground` + `adaptive_icon_background` PNG assets.

**pubspec.yaml additions**:
```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/ic_launcher.png"
  adaptive_icon_foreground: "assets/icons/ic_launcher_foreground.png"
  adaptive_icon_background: "#1A1A2E"
  min_sdk_android: 21
  web:
    generate: false
```

**Run**: `dart run flutter_launcher_icons` after adding assets.

---

## Decision 7: GoRouter Auth Guard + Pending Route

**Decision**: Extend the existing GoRouter `redirect` in `app_router.dart` to check `NotificationService.pendingRoute` after successful login.

**Rationale**: The GoRouter redirect already handles auth state via `SubscriptionCubit`. Adding a `pendingRoute` check there is minimal: after login, if `NotificationService.instance.pendingRoute != null`, redirect to that route and clear it.

**Alternatives considered**:
- Auth cubit emits pending route: Crosses feature boundaries. Rejected.
- Deep links via app scheme (URI): Adds build configuration complexity not needed for FCM-only deep links. Rejected.

---

## Decision 8: Side Menu Action Wiring

**Decision**: Use `url_launcher` for Rate App, Store Subscription Management, and Send Feedback. Use `share_plus` for Share App. Both packages are already in `pubspec.yaml`.

**Data source**: App bootstrap data (`AppConfigModel`) already contains `androidShareLink`, `iphoneShareLink`, and `contactEmail` fields cached in the home cubit. The drawer can access these via `context.read<HomeCubit>().state.appConfig`.

**Rate App URL format**:
- Android: `market://details?id=<package_name>` with fallback to `https://play.google.com/store/apps/details?id=<package_name>`
- iOS: `https://apps.apple.com/app/id<APP_ID>`

App IDs are stored in environment config via `envied` (existing pattern).

---

## Decision 9: About / Privacy Policy / Terms Pages

**Decision**: Route `/about` receives a `ContentType` enum as route extra to render the appropriate bootstrap field (`about`, `privacyPolicy`, `termsOfUse`).

**Rationale**: All three pages display rich text from the bootstrap API. A single `ContentPage` parameterised by content type is DRY and avoids three near-identical pages.

**Implementation**:
- `enum ContentType { about, privacyPolicy, termsOfUse }`
- Route: `GoRoute(path: AppRoutes.about, builder: (ctx, state) => ContentPage(type: state.extra as ContentType))`
- `ContentPage` reads `HomeCubit.state.appConfig` for the text.

---

## Decision 10: Store Metadata Structure

**Decision**: Store metadata in `store/play_store/` and `store/app_store/` directories as plain text files following Fastlane's Supply/Deliver conventions.

**Rationale**: The constitution mandates Fastlane CI/CD. Fastlane's Supply (Android) and Deliver (iOS) tools consume store metadata from standardised directory structures, enabling automated store updates.

**Play Store**: `store/play_store/en-US/` with `title.txt`, `short_description.txt`, `full_description.txt`, `changelogs/default.txt`.
**App Store**: `store/app_store/en-US/` with `name.txt`, `description.txt`, `keywords.txt`, `release_notes.txt`.
