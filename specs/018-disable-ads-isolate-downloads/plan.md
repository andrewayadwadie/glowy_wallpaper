# Implementation Plan: Disable Ads (Traceable) & Isolate-Backed Downloads

**Branch**: `018-disable-ads-isolate-downloads` | **Date**: 2026-07-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/018-disable-ads-isolate-downloads/spec.md`

## Summary

Pause the entire ad layer without deleting it, free the download from its rewarded-ad gate, and move
the heavy transfer off the main isolate.

Three moves, in dependency order:

1. **Decouple the download.** Strip the rewarded-ad gate from `DownloadCubit` so a tap on Download
   goes straight to the transfer.
2. **Re-engineer the download path.** A session-scoped `DownloadEngine` singleton owns a spawned
   isolate that streams bytes to a `.part` file and reports throttled progress over a `SendPort`.
   The engine outlives the per-route cubit, so a download survives the screen closing. Plugins stay
   on the main isolate; the isolate is pure `dart:io` + `dio`.
3. **Comment out the ad layer.** Nine production ad files and seven ad test files get wrapped in
   block comments; every call site in the eight living files gets line-commented. Everything carries
   `// TODO(ads-disabled-018): <reason>`, so one grep finds all of it and reversal restores it.

Plus one consequence of the clarified premium decision: the purchase entry point is hidden (mostly
already is), the `/premium` route is closed off, and a **Restore Purchases** drawer item is added so
existing subscribers can still recover entitlements.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: `dio` (isolate-side transfer), `dart:isolate` (new usage, stdlib),
`gallery_saver_plus`, `path_provider`, `permission_handler`, `hive`, `flutter_bloc`, `dartz`,
`get_it`, `go_router`. `google_mobile_ads` stays in `pubspec.yaml` but every use is commented out.
**Storage**: Hive `downloads` box (unchanged schema); `flutter_secure_storage` for tokens (untouched)
**Testing**: `flutter_test`, `mocktail`, `bloc_test`
**Target Platform**: Android (primary), iOS
**Project Type**: Mobile app — Flutter, clean architecture, feature-first
**Performance Goals**: no main-isolate frame stall over 100 ms during a download (SC-003); download
starts within 1 s of tap (SC-001); peak memory flat regardless of file size (SC-009)
**Constraints**: no new packages; ads commented, never deleted; one marker tag project-wide;
existing download outcomes (messages, history, analytics, permission handling) all preserved
**Scale/Scope**: 16 files to comment (9 production ad files + 7 ad test files), 8 living files with
call sites to edit, 1 download path re-engineered, 1 new drawer item

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design.*

| # | Principle | Verdict | Note |
|---|---|---|---|
| I | Clean Architecture — feature-first | **PASS** | `DownloadEngine` sits in `data/services`; `DownloadEvent` and the new `WatchDownloadEvents` use case are pure-Dart domain; no layer inversion |
| II | SOLID & DRY | **PASS** | Engine has one job (own the active job + broadcast events); runner abstracted for testing; restore-tile label goes in `AppStrings` |
| III | Responsive-first ScreenUtil | **PASS** | Only new UI is a drawer tile reusing `_buildMenuItem`, already ScreenUtil-based |
| IV | Theming | **PASS** | No new colors or styles; theme-driven tile |
| V | Either + no silent failures + four states | **PASS** | Repository still returns `Either<Failure, T>`; isolate errors map to `NetworkFailure`/`CacheFailure`; `finally` cleanup never swallows |
| VI | Performance — nothing heavy on main thread | **STRENGTHENS** | Directly implements "Dio download bytes MUST run in an isolate or be streamed"; removes the double byte buffer; engine closes its port and subscription |
| VII | Testing + zero-warning analyze | **PARTIAL — justified** | Unit tests added/rewritten and analyze stays clean, but "no TODOs in merged code" is deliberately violated — see Complexity Tracking |
| VIII | Monetization — centralized, guarded ads | **PARTIAL — justified** | Zero ads shown is compatible with "premium sees zero ads", but pausing revenue and hiding the purchase entry runs against the principle's intent — see Complexity Tracking |

**Gate result: PASS with two documented violations.** Both are direct consequences of explicit user
decisions recorded in the spec's Clarifications, not incidental design drift.

Also noted: principle VIII still names `AdHelper` as the mandatory ad entry point. That class no
longer exists — feature 016 replaced it with `core/ads/**`. The constitution text is already stale
here; this feature does not depend on resolving that, but it is worth an amendment later.

## Project Structure

### Documentation (this feature)

```text
specs/018-disable-ads-isolate-downloads/
├── plan.md              # This file
├── spec.md              # Feature spec (clarified)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── download-engine.md
│   ├── isolate-protocol.md
│   └── ad-disable-convention.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 — created by /speckit.tasks, NOT by this command
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── ads/                                   # ALL commented out, marker-wrapped
│   │   ├── ads_initializer.dart
│   │   ├── consent_manager.dart
│   │   ├── ad_gatekeeper.dart
│   │   ├── ad_ids.dart
│   │   ├── ad_network_error.dart
│   │   ├── managers/{app_open,interstitial,rewarded}_ad_manager.dart
│   │   └── widgets/anchored_adaptive_banner.dart
│   ├── di/injection_container.dart            # ad registrations out, DownloadEngine in
│   ├── routes/app_router.dart                 # /premium route commented
│   └── utils/app_strings.dart                 # + restore-purchases label
├── features/
│   ├── downloads/
│   │   ├── domain/
│   │   │   ├── entities/download_event.dart          # NEW — sealed event type
│   │   │   ├── repositories/download_repository.dart # + events stream
│   │   │   └── usecases/watch_download_events.dart   # NEW
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   ├── download_engine.dart              # NEW — session-scoped job owner
│   │   │   │   ├── download_runner.dart              # NEW — isolate abstraction
│   │   │   │   └── download_isolate_entry.dart       # NEW — top-level isolate entrypoint
│   │   │   ├── datasources/download_local_data_source.dart  # idempotent saveRecord
│   │   │   └── repositories/download_repository_impl.dart   # delegates to engine
│   │   └── presentation/cubit/
│   │       ├── download_cubit.dart            # ad gate removed, event-driven
│   │       └── download_state.dart            # isAdGateActive commented
│   ├── home/presentation/
│   │   ├── pages/home_page.dart               # banner + interstitial commented
│   │   └── widgets/home_drawer.dart           # marker on premium block, + restore tile
│   ├── splash/presentation/pages/splash_page.dart          # app-open commented
│   └── wallpaper_detail/presentation/pages/wallpaper_detail_page.dart  # ad gate + interstitial
├── app.dart                                   # resume app-open + gatekeeper sync commented
└── main.dart                                  # AdsInitializer commented

test/
├── core/ads/                                  # 7 files, all commented out with marker
└── features/downloads/
    ├── data/services/download_engine_test.dart            # NEW
    ├── data/repositories/download_repository_impl_test.dart  # NEW/updated
    └── presentation/cubit/download_cubit_test.dart        # rewritten, no ads
```

**Structure Decision**: the existing feature-first clean architecture is kept exactly as-is. The one
structural addition is `lib/features/downloads/data/services/`, holding the engine, the runner
abstraction, and the isolate entrypoint. Services belong in the data layer because they touch I/O
and platform concerns; the domain layer gains only the pure-Dart `DownloadEvent` type, the extended
repository contract, and one use case.

## Phase 1 Design Decisions

### Download flow after the change

```text
DownloadCubit.download(wallpaper)
  ├─ guard: already downloading? → ignore                            (FR-015)
  ├─ NetworkInfo.isConnected? → no → error message, stop             (existing)
  └─ DownloadWallpaper use case → DownloadRepositoryImpl
       ├─ GalleryDataSource.requestPermission()          [main isolate]
       ├─ path_provider temp dir → "<tmp>/wallpaper_<id>.<ext>.part" [main isolate]
       └─ DownloadEngine.start(...)
            ├─ single-flight guard: same id in flight → join, don't restart
            ├─ DownloadRunner.run(url, partPath) → Isolate.spawn
            │    └─ isolate: dio.download(url, partPath, onReceiveProgress)
            │         ├─ throttled progress → SendPort
            │         └─ done | error → SendPort
            ├─ progress events → broadcast stream → cubit → UI
            ├─ on done  [main isolate]
            │    ├─ rename .part → final
            │    ├─ GallerySaver.saveImage/saveVideo(final)
            │    ├─ delete temp file
            │    ├─ DownloadLocalDataSource.saveRecord (idempotent by wallpaperId)
            │    └─ emit DownloadCompleted
            └─ on error / any failure
                 ├─ delete .part in finally                          (FR-020)
                 ├─ no history entry                                 (FR-020)
                 └─ emit DownloadFailed(Failure)
```

`DownloadCubit` subscribes to `WatchDownloadEvents` in its constructor and cancels in `close()`.
Because the engine is a lazy singleton and the cubit is a factory, closing the detail page never
touches the job — satisfying FR-018. Reopening the wallpaper builds a fresh cubit that immediately
receives the replayed last event, so progress appears to continue seamlessly.

### Ad disable — mechanics

Marker, fixed by clarification: `// TODO(ads-disabled-018): <reason>`

- **Whole-purpose file**: marker header at the top, entire body wrapped in one `/* ... */`. Dart
  allows nested block comments, so inner block comments are safe.
- **Call site in a living file**: the statements *and* their now-unused imports get line-commented,
  with one marker line above each block saying what it did.
- **Never touched**: `pubspec.yaml`, `AndroidManifest.xml`, `Info.plist`, `env.dart`/`env.g.dart`.

Two call sites need slightly more than commenting:

- `home_page.dart:99` — `bottomNavigationBar: isPremium ? null : const AnchoredAdaptiveBanner()`
  becomes `bottomNavigationBar: null` with the original preserved in a marked comment. The banner
  reserved layout space, so removing it must leave no gap (FR-005, US2 scenario 2).
- `download_state.dart` — `isAdGateActive` is commented out, which means every reader in
  `wallpaper_detail_page.dart` must be commented in the same pass or the build breaks. These two
  edits ship together.

### Premium entry point

`home_drawer.dart:90–111` is already inside an unmarked `/*/ ... */` block — it gets the marker
added. `app_router.dart:144` (`/premium` route) is commented with the marker so no deep link can
reach the purchase screen. A new **Restore Purchases** tile in the drawer's info section calls
`PremiumCubit.restore()` directly, never opening the purchase page. That is the only net-new UI.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| Constitution VII — "no TODOs in merged code" | FR-010 makes `// TODO(ads-disabled-018):` the contractual traceability mechanism, and SC-006/SC-008 grade reversibility on a single grep finding every site. Without the markers the pause becomes effectively permanent. | A separate `docs/ads-disabled.md` index was considered: it drifts from the code the moment a file moves, and gives no signal at the edit site. The markers are scoped, uniformly tagged, and removed wholesale when ads return. `flutter analyze` does not report TODO diagnostics, so the zero-warning gate still holds. |
| Constitution VIII — monetization intent | The user directed a full ad pause, and chose (clarification Q5) to hide the purchase entry point rather than only remove ad-free copy. Ad revenue and new subscription revenue both go to zero for the duration. | Keeping ads or keeping the paywall visible would contradict explicit user decisions. Selling a subscription whose headline benefit is inert is also a refund and store-review risk. Mitigations retained: ad code is preserved for one-step restore, and existing subscriber entitlements plus the restore path stay fully functional (FR-022). |
| New `data/services/` layer in the downloads feature | The isolate job must outlive the per-route cubit (FR-018) and be single-flight across the app (FR-015). Neither is expressible in a `registerFactory` cubit or in a stateless repository. | Making `DownloadCubit` a singleton was rejected — history, error, and success state would bleed between the downloads page and the detail page, breaking the per-screen four-state pattern (constitution V). |

## Phase 0 & 1 Outputs

- [x] `research.md` — 11 decisions, all NEEDS CLARIFICATION resolved
- [x] `data-model.md` — `DownloadEvent`, engine job state, isolate message shapes
- [x] `contracts/download-engine.md` — engine + repository + use case surface
- [x] `contracts/isolate-protocol.md` — message wire format both directions
- [x] `contracts/ad-disable-convention.md` — marker format, per-file patterns, full site inventory
- [x] `quickstart.md` — implementation order, verification commands, rollback
- [x] Agent context updated

**Post-design constitution re-check**: unchanged — PASS with the three justified entries above. The
Phase 1 design introduced no new violations; the `data/services/` addition was already anticipated
and is justified in the table.

## Next Command

`/speckit.tasks` — generate the dependency-ordered task list.
