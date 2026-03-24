# Tasks: Firebase, Polish & Store Readiness

**Input**: Design documents from `/specs/006-firebase-polish-store/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

**Organization**: 5 user stories → 8 phases → 34 tasks

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create new feature folder structure, shared enums, and verify native platform config files before any implementation begins.

- [ ] T001 Add `GoogleService-Info.plist` (downloaded from Firebase Console project `glowywallpaper`) to `ios/Runner/GoogleService-Info.plist` and verify `android/app/google-services.json` exists
- [X] T002 [P] Create `NotificationPayload` Freezed entity in `lib/features/notifications/domain/entities/notification_payload.dart` (fields: title, body, route?, data Map)
- [X] T003 [P] Create `ContentType` enum (`about`, `privacyPolicy`, `termsOfUse`) in `lib/core/enums/content_type.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared UI state widgets and the `NotificationService` foundation that all user stories depend on. MUST be complete before any user story work begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Add `shimmerBase` and `shimmerHighlight` color constants (light and dark variants) to `lib/core/theme/app_colors.dart`
- [X] T005 [P] Create `AppShimmerWidget` in `lib/core/widgets/app_shimmer_widget.dart` — wraps `Shimmer.fromColors` using `AppColors.shimmerBase/shimmerHighlight`; accepts a `child` (the skeleton placeholder)
- [X] T006 [P] Create `AppEmptyStateWidget` in `lib/core/widgets/app_empty_state_widget.dart` — Lottie animation (`assets/animations/empty_state.json`) + `AutoSizeText` title and message; accepts optional `title` and `message` parameters
- [X] T007 [P] Create `AppErrorStateWidget` in `lib/core/widgets/app_error_state_widget.dart` — `AutoSizeText` error message + `ElevatedButton('Retry', onPressed: onRetry)`; accepts `message` and `onRetry` callback
- [X] T008 Create abstract `NotificationService` in `lib/features/notifications/domain/services/notification_service.dart` with methods: `initialize()`, `requestPermission()`, `hasRequestedPermission` getter, `pendingRoute` getter, `clearPendingRoute()`, `onNotificationTap` stream (see `contracts/notification_service_contract.md`)
- [X] T009 Implement `NotificationServiceImpl` in `lib/features/notifications/data/services/notification_service_impl.dart`: initialize `FlutterLocalNotificationsPlugin` with Android `high_importance_channel` (Importance.max), register `FirebaseMessaging.onMessage` listener → call `flutterLocalNotificationsPlugin.show()`, register `FirebaseMessaging.onMessageOpenedApp` listener → set `pendingRoute`, call `getInitialMessage()` in `initialize()` → store route in `pendingRoute` if present; implement `requestPermission()` → `FirebaseMessaging.instance.requestPermission()` + write `permission_requested=true` to Hive `notification_prefs` box; add top-level `_firebaseMessagingBackgroundHandler` with `@pragma('vm:entry-point')` annotation
- [X] T010 Register `NotificationService` as `LazySingleton<NotificationService>(() => NotificationServiceImpl())` and open Hive `notification_prefs` box in `lib/core/di/injection_container.dart`
- [X] T011 Call `await sl<NotificationService>().initialize()` in `lib/main.dart` after `Firebase.initializeApp()` and before `runApp()`

**Checkpoint**: `AppShimmerWidget`, `AppEmptyStateWidget`, `AppErrorStateWidget` usable; `NotificationService` initialized and receiving FCM messages.

---

## Phase 3: User Story 1 — Push Notification Delivery (Priority: P1) 🎯 MVP

**Goal**: FCM delivers notifications in all app states; tapping a deep-link notification routes the user to the correct screen; logged-out users are redirected to login then to the original destination after login.

**Independent Test**: Send a test FCM message with `{"data": {"route": "/wallpaper/test123"}}` while logged in (foreground, background, terminated) and verify navigation. Repeat while logged out and verify login-then-destination flow (see `quickstart.md` Scenarios 1–3).

- [X] T012 [US1] Update `lib/features/splash/presentation/pages/splash_page.dart`: after `checkStatus()` completes, call `sl<NotificationService>().pendingRoute` — if non-null AND user is logged in, call `context.go(pendingRoute)` then `clearPendingRoute()` before navigating to home; if logged out, leave `pendingRoute` intact and navigate to `/login`
- [X] T013 [US1] Update `lib/core/routes/app_router.dart` GoRouter `redirect` callback: after detecting a successful logged-in state, check `sl<NotificationService>().pendingRoute` — if non-null, call `sl<NotificationService>().clearPendingRoute()` and return that route as the redirect target (takes priority over the default home redirect)
- [X] T014 [US1] Update `lib/features/detail/presentation/cubit/wallpaper_detail_cubit.dart`: after `_downloadWallpaper()` or `_toggleFavorite()` returns `Right(...)`, check `sl<NotificationService>().hasRequestedPermission` — if false, call `sl<NotificationService>().requestPermission()` and log `notification_permission_requested` event to `FirebaseAnalytics`

**Checkpoint**: Send test FCM notification with deep-link payload; verify foreground banner appears, background system tray tap navigates correctly, terminated cold-start navigates correctly, and logged-out user reaches destination after login.

---

## Phase 4: User Story 2 — Side Menu Engagement Actions (Priority: P2)

**Goal**: All 5 drawer engagement actions (Rate App, Share App, Send Feedback, About, Privacy Policy / Terms of Use) are fully wired and functional on Android and iOS.

**Independent Test**: Open the side drawer and tap each item in sequence; verify the correct external action or in-app page opens (see `quickstart.md` Scenario 4).

- [X] T015 [P] [US2] Create `ContentPage` in `lib/features/home/presentation/pages/content_page.dart`: reads `ContentType` from `GoRouterState.extra`, reads the corresponding text (`about` / `privacyPolicy` / `termsOfUse`) from `context.read<HomeCubit>().state.appConfig`, displays it in a scrollable `SingleChildScrollView` with `AutoSizeText`; shows `AppErrorStateWidget` if `appConfig` is null with a retry that calls `context.read<HomeCubit>().loadAppData()`
- [X] T016 [P] [US2] Update `/about` route in `lib/core/routes/app_router.dart`: change builder to `ContentPage(type: state.extra as ContentType)` so the single page handles About, Privacy Policy, and Terms of Use
- [X] T017 [US2] Update `lib/features/home/presentation/widgets/home_drawer.dart`: wire **Rate App** using `url_launcher` (`market://details?id=${Env.androidPackageId}` with Play Store fallback on Android; `https://apps.apple.com/app/id${Env.appleAppId}` on iOS); wire **Share App** using `share_plus` `Share.share(appConfig.androidShareLink / iphoneShareLink)`; wire **Send Feedback** using `url_launcher` `mailto:${appConfig.contactEmail}?subject=Feedback`; wire **About** as `context.push(AppRoutes.about, extra: ContentType.about)`; wire **Privacy Policy** as `context.push(AppRoutes.about, extra: ContentType.privacyPolicy)`; wire **Terms of Use** as `context.push(AppRoutes.about, extra: ContentType.termsOfUse)`; log analytics event for each action; show `SnackBar` on `url_launcher` failure

**Checkpoint**: Every drawer action opens its destination without errors on both Android and iOS emulators.

---

## Phase 5: User Story 3 — Consistent Loading, Empty & Error States (Priority: P2)

**Goal**: Every content screen shows `AppShimmerWidget` while loading, `AppErrorStateWidget` with retry on failure, and `AppEmptyStateWidget` with illustration when no content is available.

**Independent Test**: Throttle the network and open each content screen — shimmer should be visible. Block network and open a screen — error state with Retry should appear. Open Favorites/Downloads with no saved items — empty state illustration should appear (see `quickstart.md` Scenario 5).

- [X] T018/T019 [P] [US3] Update `lib/features/home/presentation/pages/home_page.dart`: replace the `Status.loading` UI for categories with an `AppShimmerWidget` wrapping a row of skeleton chips; replace the `Status.loading` UI for the content grid with an `AppShimmerWidget` wrapping a 2-column skeleton grid of placeholder `Container` cards; wire the `Status.error` case to `AppErrorStateWidget(message: ..., onRetry: () => cubit.reload())` and the `Status.empty` case to `AppEmptyStateWidget`
- [X] T018/T019 [P] [US3] Update `lib/features/categories/presentation/pages/classification_detail_page.dart` (classification bento grid screen): apply `AppShimmerWidget` for `Status.loading`, `AppErrorStateWidget` for `Status.error`, `AppEmptyStateWidget` for `Status.empty`
- [X] T020 [P] [US3] Update `lib/features/detail/presentation/pages/wallpaper_detail_page.dart`: apply `AppShimmerWidget` skeleton while wallpaper loads into the `PageView`, `AppErrorStateWidget` if the detail data fails to load
- [X] T021 [P] [US3] Update `lib/features/favorites/presentation/pages/favorites_page.dart`: replace any existing loading spinner with `AppShimmerWidget` grid skeleton; wire empty state to `AppEmptyStateWidget(title: 'No favourites yet', message: 'Tap the heart icon on any wallpaper to save it here')`; wire error state to `AppErrorStateWidget`
- [X] T022 [P] [US3] Update `lib/features/downloads/presentation/pages/downloads_page.dart`: apply same pattern as T021 — `AppShimmerWidget` grid skeleton for loading, `AppEmptyStateWidget(title: 'No downloads yet', message: 'Download wallpapers to see them here')` for empty, `AppErrorStateWidget` for error

**Checkpoint**: All five screens show shimmer → content, shimmer → error+retry, and (where applicable) empty state with illustration.

---

## Phase 6: User Story 4 — Responsive Layout & Visual Polish (Priority: P3)

**Goal**: App displays correctly on tablets — 3–4 grid columns, constrained drawer width — and at 200% system font size with no overflow.

**Independent Test**: Run the app on a 10-inch tablet emulator; verify grid columns ≥3 and drawer ≤320dp. Set system font to largest size; navigate all screens and confirm no text overflow (see `quickstart.md` Scenario 6).

- [X] T023 [P] [US4] Update the wallpaper grid component (used in `home_page.dart`, `classification_detail_page.dart`, `favorites_page.dart`, `downloads_page.dart`) to return 2 columns when `ScreenUtil().screenWidth < 600`, 3 columns when `600 ≤ width < 900`, and 4 columns when `width ≥ 900`; use `ScreenUtil().screenWidth` for breakpoint detection
- [X] T024 [P] [US4] Update `lib/features/home/presentation/widgets/home_drawer.dart`: wrap the `Drawer` widget in a `ConstrainedBox(constraints: BoxConstraints(maxWidth: 320.w))` so it does not stretch full-width on tablets
- [X] T025 [US4] Audit all primary screens (`home_page.dart`, `wallpaper_detail_page.dart`, `favorites_page.dart`, `downloads_page.dart`, `classification_detail_page.dart`) to ensure every `Text(...)` is `AutoSizeText(...)` (per constitution), every size value uses ScreenUtil extensions, and no `maxLines` cutoffs cause text clipping at 200% font scale; fix any violations found

**Checkpoint**: Run on Pixel Tablet emulator — grid shows ≥3 columns, drawer ≤320dp. Run at font size Largest — no overflow on any primary screen.

---

## Phase 7: User Story 5 — App Icon, Splash & Store Listing Readiness (Priority: P3)

**Goal**: App has a polished adaptive icon on Android, standard icon on iOS, verified native splash branding, and complete store metadata files ready for submission.

**Independent Test**: Build a release APK/IPA; verify launcher icon display. Run through the store submission checklist (see `quickstart.md` Scenario 7).

- [X] T026 [P] [US5] Add app icon assets: place `ic_launcher.png` (1024×1024 standard) and `ic_launcher_foreground.png` (foreground layer) in `assets/icons/`; add `flutter_launcher_icons` config to `pubspec.yaml` under `flutter_icons:` with `android: "launcher_icon"`, `ios: true`, `image_path: "assets/icons/ic_launcher.png"`, `adaptive_icon_foreground: "assets/icons/ic_launcher_foreground.png"`, `adaptive_icon_background: "#1A1A2E"`, `min_sdk_android: 21`
- [X] T027 [P] [US5] Verify `flutter_native_splash` config in `pubspec.yaml` uses brand primary color (`#1A1A2E`) and a centered logo asset; run `dart run flutter_native_splash:create` to regenerate splash assets for both platforms
- [X] T028 [US5] Run `dart run flutter_launcher_icons` to generate Android adaptive icon layers in `android/app/src/main/res/mipmap-*/` and iOS icon set in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- [X] T029 [P] [US5] Create Play Store metadata: `store/play_store/en-US/title.txt` (≤30 chars), `store/play_store/en-US/short_description.txt` (≤80 chars), `store/play_store/en-US/full_description.txt` (≤4000 chars, includes features, premium CTA, privacy policy URL), `store/play_store/en-US/changelogs/default.txt`
- [X] T030 [P] [US5] Create App Store metadata: `store/app_store/en-US/name.txt` (≤30 chars), `store/app_store/en-US/description.txt` (≤4000 chars), `store/app_store/en-US/keywords.txt` (≤100 chars, comma-separated), `store/app_store/en-US/release_notes.txt` (≤4000 chars)

**Checkpoint**: `flutter run --release` on Android shows adaptive icon on home screen; `flutter run --release` on iOS shows standard icon; both store metadata files are complete.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Code generation, static analysis, formatting, and a unit test for the core new service — required by the project constitution before any commit.

- [X] T031 Run `dart run build_runner build --delete-conflicting-outputs` to generate Freezed code for `NotificationPayload`; verify `notification_payload.freezed.dart` is generated in `lib/features/notifications/domain/entities/`
- [X] T032 [P] Write unit test for `NotificationServiceImpl` in `test/features/notifications/data/services/notification_service_impl_test.dart`: mock `FirebaseMessaging` and `FlutterLocalNotificationsPlugin`; test that `pendingRoute` is set from a valid FCM data payload, remains null for a payload with no `route` key, and that `clearPendingRoute()` sets it to null; test that `requestPermission()` sets `hasRequestedPermission = true`
- [X] T033 [P] Run `flutter analyze` and fix all reported issues to achieve zero warnings; remove any `print()` calls, `// TODO` comments, and unused imports introduced in this phase
- [X] T034 Run `dart format .` to apply consistent code formatting across all modified files

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — BLOCKS all user story phases
- **Phase 3 (US1 Notifications)**: Depends on Phase 2 (needs NotificationService)
- **Phase 4 (US2 Side Menu)**: Depends on Phase 2 (needs ContentType enum); independent of Phase 3
- **Phase 5 (US3 State Widgets)**: Depends on Phase 2 (needs AppShimmerWidget, AppEmptyStateWidget, AppErrorStateWidget); independent of Phases 3–4
- **Phase 6 (US4 Responsive)**: Depends on Phase 5 (updates same screen files); independent of Phases 3–4
- **Phase 7 (US5 Icons/Store)**: Depends on Phase 1 only — fully independent of Phases 3–6
- **Phase 8 (Polish)**: Depends on all phases complete

### User Story Dependencies

- **US1 (P1 Notifications)**: Depends on Foundational (Phase 2) — no other story dependency
- **US2 (P2 Side Menu)**: Depends on Foundational (Phase 2) — no other story dependency
- **US3 (P2 States)**: Depends on Foundational (Phase 2) — no other story dependency
- **US4 (P3 Responsive)**: Depends on US3 (Phase 5) — same files, sequential required
- **US5 (P3 Store)**: Depends on Phase 1 setup only — can run in parallel with US1/US2/US3

### Within Each User Story

- T005/T006/T007 can run in parallel (different files)
- T008 → T009 → T010 → T011 must be sequential (notification service chain)
- US3 tasks T018–T022 are all parallel (different screen files)
- US5 tasks T026/T027/T029/T030 are parallel; T028 depends on T026

### Parallel Opportunities

```
Phase 1: T002 ║ T003            (different files)
Phase 2: T005 ║ T006 ║ T007     (different widget files, after T004)
              T008 → T009 → T010 → T011  (sequential chain)
Phase 3+: US1 can start as soon as Phase 2 done
          US2 can start as soon as Phase 2 done (parallel with US1)
          US5 can start as soon as Phase 1 done (parallel with everything)
Phase 5: T018 ║ T019 ║ T020 ║ T021 ║ T022  (all different screen files)
Phase 8: T032 ║ T033             (different files)
```

---

## Implementation Strategy

### MVP First (Push Notifications Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational (T004–T011)
3. Complete Phase 3: US1 Push Notifications (T012–T014)
4. **STOP and VALIDATE**: Send test FCM, verify all 3 app-state delivery paths + logged-out pending route
5. Proceed to remaining stories

### Incremental Delivery

1. Phase 1 + Phase 2 → Foundation ready
2. Phase 3 (US1) → Push notifications working ← MVP
3. Phase 4 (US2) → Side menu complete
4. Phase 5 (US3) → All screens have consistent states
5. Phase 6 (US4) → Responsive polish
6. Phase 7 (US5) → App icon, splash, store metadata ready
7. Phase 8 → Polish, analyze clean, store submission ready

---

## Notes

- `[P]` = different files, no blocking dependencies — can run in parallel
- `[US#]` = maps to the spec user story for traceability
- T001 requires a manual download from the Firebase Console (iOS `GoogleService-Info.plist`) — verify before T009/T011
- T028 (`dart run flutter_launcher_icons`) requires icon asset files to be in place (T026 must be done first)
- Constitution requires `flutter analyze` zero warnings before commit — T033 is not optional
- Store screenshots are captured from device/emulator separately; screenshot file creation is out of scope for tasks (placeholder directories created by T029/T030)
