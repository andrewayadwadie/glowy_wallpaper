# Tasks: FCM Push Notifications & Local Notifications

**Feature**: `017-fcm-notifications` | **Branch**: `017-fcm-notifications`
**Input**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included — Constitution VII mandates unit tests for every use case, repository impl, and Cubit.

## Precondition Gate (BLOCKING — must clear before Phase 1)

- [X] T000 Generate Firebase config: run `flutterfire configure --project=glowywallpaper`; verify `lib/firebase_options.dart` AND `ios/Runner/GoogleService-Info.plist` exist. Leave `android/app/google-services.json` unchanged. NO implementation task may start until both files present (spec Preconditions).

---

## Phase 1: Setup

- [X] T001 Verify mandatory packages present in `pubspec.yaml` (firebase_core, firebase_messaging, flutter_local_notifications, firebase_analytics, flutter_bloc, freezed, get_it, go_router, dartz, hive, mocktail, bloc_test); add only what is missing (FR-019); run `flutter pub get`.
- [X] T002 Add notification accent color resource `#22D3EE` in new `android/app/src/main/res/values/colors.xml` as `<color name="notification_color">#FF22D3EE</color>` (FR-017).

---

## Phase 2: Foundational (blocking prerequisites for all user stories)

- [X] T003 Add static `GlobalKey<NavigatorState> navigatorKey` to `lib/core/routes/app_router.dart` and pass it to `GoRouter(navigatorKey: ...)`; remove the obsolete `pendingRoute` redirect block (lines ~36-51) — nav now handled via navigatorKey (research D3, FR-015).
- [X] T004 [P] Create `NotificationEntity(title, body, deeplink, imageUrl)` Freezed model in `lib/features/notifications/domain/entities/notification_entity.dart`; supersedes `notification_payload.dart` (data-model).
- [X] T005 [P] Define `NotificationRepository` contract (`requestPermission()→Either<Failure,bool>`, `getToken()→Either<Failure,String?>`, `tokenRefreshes` stream, `taps` stream) in `lib/features/notifications/domain/repositories/notification_repository.dart` (contracts).
- [X] T006 Reconcile abstract `NotificationService` in `lib/features/notifications/domain/services/notification_service.dart` to emit `NotificationEntity` (replace `NotificationPayload`); add `initialNotification` getter + `clearInitialNotification()`; replace `pendingRoute`/`clearPendingRoute` (contracts). Depends on T004.
- [X] T007 Run `dart run build_runner build --delete-conflicting-outputs` to generate Freezed for `NotificationEntity`; delete `notification_payload.dart` + `.freezed.dart`. Depends on T004, T006.

**Checkpoint**: Domain skeleton compiles; navigatorKey available.

---

## Phase 3: User Story 1 — Foreground notifications (P1) 🎯 MVP

**Goal**: Push received while app foreground shows visible local notification (title + expandable body, big-picture when image present).
**Independent Test**: Send test push (title+body) with app open → notification appears in tray, body expands; with `imageUrl` → big-picture.

- [X] T008 [US1] Implement `NotificationServiceImpl.initialize()` in `lib/features/notifications/data/services/notification_service_impl.dart`: rename channel to `glowy_high_importance`, name `Glowy High Importance`, importance max; init local notifications with android icon `@mipmap/ic_launcher`; create channel (research D1, FR-002/004). Depends on T006.
- [X] T009 [US1] In same file, implement foreground `FirebaseMessaging.onMessage` handler: build `NotificationEntity` from `RemoteMessage`; render `BigPictureStyleInformation` when `imageUrl` present (download bytes to temp file, off-thread), else `BigTextStyleInformation`; download failure → big-text fallback; tap payload = deeplink; data-only message → show nothing, no crash (FR-003/003a, US1 scenarios 2-3). Depends on T008.
- [X] T010 [US1] Apply notification accent color `@color/notification_color` to `AndroidNotificationDetails` (FR-017). Depends on T009.
- [X] T011 [P] [US1] Unit test `NotificationServiceImpl` foreground display logic (big-picture vs big-text selection, data-only no-op) in `test/features/notifications/notification_service_impl_test.dart` using mocktail.

**Checkpoint**: Foreground notifications fully functional — MVP demonstrable.

---

## Phase 4: User Story 2 — Tap to open deep link (P1)

**Goal**: Tapping notification navigates to deep link (or Home) across foreground, background, terminated states.
**Independent Test**: Send push with `deeplink`, tap from each of 3 states → navigates to route; no/invalid link → Home.

- [X] T012 [US2] In `notification_service_impl.dart`: emit `NotificationEntity` on `onNotificationTap` from `onDidReceiveNotificationResponse` (foreground tap) and `FirebaseMessaging.onMessageOpenedApp` (background tap); read deeplink from `message.data['deeplink']`, validate starts with `/` (research D2, FR-005). Depends on T008.
- [X] T013 [US2] Handle terminated launch: `getInitialMessage()` → store in `initialNotification`, exposed for one-time consume after app init (FR-007). Depends on T012.
- [X] T014 [US2] Add top-level `@pragma('vm:entry-point')` background handler registered via `FirebaseMessaging.onBackgroundMessage`; MUST NOT access GetIt/singletons; calls `Firebase.initializeApp()` if needed (FR-012, research D5). Depends on T008.
- [X] T015 [US2] Wire tap → navigation in `lib/features/notifications/presentation/cubit/notification_cubit.dart`: subscribe to `taps`, call `AppRouter.router.go(deeplink)` when valid else `AppRouter.router.go(AppRoutes.home)`; consume `initialNotification` after first frame (FR-006/015, research D3). Depends on T003, T013.
- [X] T016 [P] [US2] Unit test deeplink extraction/validation + Home fallback (valid `/`, null, malformed) in `test/features/notifications/deeplink_test.dart`.

**Checkpoint**: Deep-link navigation works in all 3 lifecycle states.

---

## Phase 5: User Story 3 — Permission grant/deny (P2)

**Goal**: OS permission requested once; behaves correctly on grant/deny; no redundant re-prompt.
**Independent Test**: Fresh install → prompt once; grant → token delivered; deny → app continues; relaunch → no re-prompt.

- [X] T017 [US3] Implement `requestPermission()` + `hasRequestedPermission` in `notification_service_impl.dart`: iOS/Android via `FirebaseMessaging.requestPermission`; persist `permission_requested=true` in Hive box `notification_prefs`; skip re-prompt when flag set (FR-008/009, research D6, SC-004). Depends on T008.
- [X] T018 [P] [US3] Implement `RequestNotificationPermission` use case (`call()→Future<Either<Failure,bool>>`) in `lib/features/notifications/domain/usecases/request_notification_permission.dart` (contracts).
- [X] T019 [US3] Implement `NotificationRepositoryImpl` in `lib/features/notifications/data/repositories/notification_repository_impl.dart`: delegate to service, wrap in `Either<Failure,T>`, no silent catch (FR-014, Constitution V). Depends on T005, T017.
- [X] T020 [US3] Create `NotificationState` Freezed union (`initial | permissionRequesting | permissionGranted(token) | permissionDenied | error(failure)`) in `lib/features/notifications/presentation/cubit/notification_state.dart` (FR-013, data-model). Run build_runner.
- [X] T021 [US3] Implement `NotificationCubit.initNotifications()` in `notification_cubit.dart`: emit `permissionRequesting` → request → on grant fetch token + emit `permissionGranted`, on deny emit `permissionDenied`, on failure emit `error`; dispose subscriptions in `close()` (FR-013, Constitution VI). Depends on T018, T020.
- [X] T022 [P] [US3] Unit tests (bloc_test) for `NotificationCubit` state transitions + `RequestNotificationPermission` use case + `NotificationRepositoryImpl` in `test/features/notifications/` using mocktail (Constitution VII).

**Checkpoint**: Permission flow complete with full domain/data/presentation stack.

---

## Phase 6: User Story 4 — Device token + refresh (P3)

**Goal**: Token retrieved on permitted launch; refreshes observable. Local only (no backend upload).
**Independent Test**: First launch w/ permission → token in debug log within 5s; simulate refresh → new token on stream.

- [X] T023 [US4] Implement `getFcmToken()` + `onTokenRefresh` stream in `notification_service_impl.dart` (local only, no backend — research D7, FR-010/011/011a). Depends on T008.
- [X] T024 [P] [US4] Implement `GetFcmToken` use case (`call()→Future<Either<Failure,String?>>`) in `lib/features/notifications/domain/usecases/get_fcm_token.dart`; wire into `NotificationRepositoryImpl`. Depends on T019.
- [X] T025 [US4] Add temporary, removable `debugPrint` of token on first launch in `lib/main.dart` (FR-018, SC-005); tag with `// TODO remove before release`.
- [X] T026 [P] [US4] Unit test `GetFcmToken` use case + token-refresh stream emission in `test/features/notifications/get_fcm_token_test.dart`.

**Checkpoint**: Token targeting infrastructure ready.

---

## Phase 7: Polish & Cross-Cutting

- [X] T027 Update `android/app/src/main/AndroidManifest.xml`: add `POST_NOTIFICATIONS`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED` uses-permission; add FCM meta-data `default_notification_channel_id=glowy_high_importance`, `default_notification_icon=@mipmap/ic_launcher`, `default_notification_color=@color/notification_color` (FR-016/004, SC-007).
- [X] T028 Update `ios/Runner/Info.plist` + Xcode capabilities: Push Notifications + Background Modes (remote-notification) (FR-016).
- [X] T029 Update `lib/main.dart`: `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` once, wrapped in try/catch so failure does not block `runApp`; init `NotificationService`; trigger `NotificationCubit.initNotifications()` (FR-001, SC-006, research D8). Depends on T021, T029-deps.
- [X] T030 Register in `lib/core/di/injection_container.dart` Phase 6 block (manual GetIt): `NotificationService`, `NotificationRepository`, `RequestNotificationPermission`, `GetFcmToken`, `NotificationCubit` (research D9, FR-014).
- [X] T031 Log Firebase Analytics events for notification receive + tap (Constitution VIII).
- [X] T032 Run `flutter analyze` (zero warnings) + `dart format .`; remove unused `notification_payload` refs, no `print()`, no leftover TODOs except tagged token log; run full `flutter test test/features/notifications/` (Constitution VII).
- [ ] T033 Execute quickstart.md manual acceptance matrix (SC-001..007); confirm channel id identical in code + manifest (SC-007).

---

## Dependencies & Execution Order

```text
T000 (gate) → Phase 1 (T001-T002) → Phase 2 (T003-T007)
   → Phase 3 US1 (T008-T011)   ← MVP
   → Phase 4 US2 (T012-T016)   depends T003,T008
   → Phase 5 US3 (T017-T022)   depends T008
   → Phase 6 US4 (T023-T026)   depends T008,T019
   → Phase 7 Polish (T027-T033)
```

- **US1** (P1): only needs Phase 2 + T008 chain → MVP.
- **US2/US3/US4** all build on the shared `NotificationServiceImpl` (T008); within each story, use case/repo/cubit/test layers are largely independent.
- Phase 7 integration (T029/T030) depends on all Cubit/use-case tasks.

## Parallel Opportunities

- Phase 2: T004, T005 parallel (different files).
- Test tasks T011, T016, T022, T026 [P] — independent files, run alongside their story's impl once deps met.
- US3 use case T018 parallel with service work; US4 use case T024 parallel after repo (T019).

## Implementation Strategy

- **MVP**: T000 → Phase 1 → Phase 2 → Phase 3 (US1). Foreground notifications demonstrable.
- **Increment 2**: US2 (deep-link nav) — core push value.
- **Increment 3**: US3 (permission) — enabling gate, full Clean Arch stack.
- **Increment 4**: US4 (token) + Phase 7 polish + manifest/iOS config + DI wiring.
