# Implementation Plan: FCM Push Notifications & Local Notifications

**Branch**: `017-fcm-notifications` | **Date**: 2026-06-20 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/017-fcm-notifications/spec.md`

## Summary

Deliver end-to-end FCM + local notifications for the Flutter app, reconciling the existing
partial implementation to the target design: rename channel to `glowy_high_importance`, switch
deep-link payload field to `deeplink`, add big-picture/big-text rendering, and restructure into
full Clean Architecture (domain entity/repository/use cases, data repository impl + service,
presentation Cubit + Freezed state). Navigation via a static `GlobalKey<NavigatorState>` on
GoRouter. Token exposed locally only (no backend upload — Clarification Q1). Hard precondition:
`firebase_options.dart` and `ios/Runner/GoogleService-Info.plist` must exist before implementation.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: firebase_core, firebase_messaging, flutter_local_notifications,
firebase_analytics, flutter_bloc (Cubit + Freezed), get_it (manual registration), go_router,
dartz (Either), hive (permission-requested flag), http/dio (big-picture image download),
flutter_screenutil, auto_size_text
**Storage**: Hive box `notification_prefs` (existing — stores `permission_requested` flag). No new box.
**Testing**: flutter_test, mocktail, bloc_test (unit tests for use cases, repository impl, Cubit)
**Target Platform**: Android (13+ runtime permission) and iOS (messaging permission request)
**Project Type**: Mobile app (Flutter, feature-first Clean Architecture)
**Performance Goals**: Token obtained within 5s of permitted first launch (SC-005); no startup
crash when Firebase config absent (SC-006, 100%)
**Constraints**: Background handler runs in isolated isolate — MUST NOT touch GetIt/singletons
(FR-012); Firebase initialized exactly once; channel id single source of truth (SC-007)
**Scale/Scope**: Single feature module + manifest/Info.plist config + main.dart + router wiring

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Clean Architecture (3 layers) | PASS | Domain (NotificationEntity, NotificationRepository, GetFcmToken + RequestNotificationPermission use cases), data (repo impl + NotificationService), presentation (NotificationCubit + Freezed state). |
| II. SOLID & DRY, constants | PASS | Channel id, accent color `#22D3EE` (→ AppColors.darkPrimary, exists), routes via AppRoutes. No hardcoded strings. |
| III. ScreenUtil | N/A | Feature is service-layer; no new sized UI widgets. |
| IV. Theming | N/A | No new screens. |
| V. Error handling — Either | PASS | Repository returns `Either<Failure, T>`; use cases return explicit success/failure; Cubit state union includes `error`. No silent swallow except documented Firebase-init tolerance (FR-001). |
| VI. Performance | PASS | Big-picture image download streamed/off-thread; Cubit disposes subscriptions in `close()`. |
| VII. Testing | PASS | Unit tests for use cases, repo impl, Cubit via mocktail; `flutter analyze` zero warnings; temp token log (FR-018) tracked for removal pre-release. |
| VIII. Monetization & Firebase | PASS | flutter_local_notifications for foreground FCM (constitution mandates this); Firebase Analytics events for notification receive/tap; existing `google-services.json` unchanged. |

**Gate result**: PASS. No violations → Complexity Tracking empty.

**Precondition gate (blocking, from spec)**: `lib/firebase_options.dart` and
`ios/Runner/GoogleService-Info.plist` MUST exist before any implementation task runs. Plan
documents target behavior; implementation is hard-gated on these two files.

## Project Structure

### Documentation (this feature)

```text
specs/017-fcm-notifications/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── notification_service.md
└── tasks.md             # Phase 2 (/speckit.tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── main.dart                                   # Firebase.initializeApp + service init (exists; adjust)
├── core/
│   ├── di/injection_container.dart             # manual GetIt registration (extend Phase 6 block)
│   ├── routes/app_router.dart                  # add static navigatorKey; replace redirect-based nav
│   └── theme/colors.dart                       # AppColors.darkPrimary = #22D3EE (exists, reuse)
└── features/notifications/
    ├── domain/
    │   ├── entities/notification_entity.dart            # NEW: title, body, deeplink, imageUrl
    │   ├── repositories/notification_repository.dart    # NEW: contract (Either<Failure,T>)
    │   ├── services/notification_service.dart           # RECONCILE: abstract service iface
    │   └── usecases/
    │       ├── get_fcm_token.dart                       # NEW
    │       └── request_notification_permission.dart     # NEW
    ├── data/
    │   ├── repositories/notification_repository_impl.dart   # NEW
    │   └── services/notification_service_impl.dart          # RECONCILE: channel id, deeplink, big-picture
    └── presentation/
        └── cubit/
            ├── notification_cubit.dart                  # NEW
            └── notification_state.dart                  # NEW: Freezed union

android/app/src/main/AndroidManifest.xml         # add perms + FCM default channel + color/icon meta-data
android/app/src/main/res/values/colors.xml       # NEW: notification accent #22D3EE
ios/Runner/Info.plist                            # notification capability/keys
test/features/notifications/                      # unit tests (use cases, repo impl, cubit)
```

**Structure Decision**: Mobile app, feature-first Clean Architecture. The existing
`lib/features/notifications/` skeleton (mostly `.gitkeep` placeholders + a partial service) is
extended in place. Existing `NotificationPayload` Freezed model is superseded by
`NotificationEntity`; existing `high_importance_channel` / `route` / redirect-based nav are
reconciled to `glowy_high_importance` / `deeplink` / navigatorKey-based nav. DI stays manual GetIt
(no injectable codegen) per repo convention.

## Complexity Tracking

> No constitution violations. Section intentionally empty.
