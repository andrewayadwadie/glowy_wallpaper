# Implementation Plan: Remove Unnecessary Media Read Permissions (Google Play Policy Fix)

**Branch**: `020-remove-media-read-permissions` | **Date**: 2026-07-25 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/020-remove-media-read-permissions/spec.md`

## Summary

Google Play rejected version code 7 because the app declares `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` / `READ_EXTERNAL_STORAGE` while it only ever *writes* wallpapers it downloaded itself. Verified this session: those entries come **solely from the app's own `android/app/src/main/AndroidManifest.xml`** — `gal`, `gallery_saver_plus`, and `permission_handler_android` all ship empty library manifests and contribute nothing (their permission lists live only in their `example/` apps, which are never merged).

Approach: delete the three read permissions from the app manifest, tighten `WRITE_EXTERNAL_STORAGE` to `maxSdkVersion="28"`, swap the unmaintained `gallery_saver_plus` for `gal ^2.3.2` (whose native `hasAccess()` already returns `true` on API ≥ 30 and on API 29 for non-album saves, and only asks for `WRITE_EXTERNAL_STORAGE` on API 23–28), reduce `GalleryDataSourceImpl`'s permission methods to delegate to `Gal.requestAccess()` / `Gal.hasAccess()`, move the presentation-layer `ph.openAppSettings()` call behind the data layer to satisfy FR-011, update the affected unit tests, and bump `1.0.3+7` → `1.0.4+8`.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: `gal ^2.3.2` (replaces `gallery_saver_plus ^3.2.9`), `permission_handler ^11.3.1` (retained — app-settings deep link only), `dio`, `flutter_bloc`, `dartz`, `get_it`
**Storage**: Hive `downloads` box (unchanged schema); no new persistence. Gallery writes go through Android `MediaStore` via `gal`
**Testing**: `flutter_test` + `mocktail`; existing suites `test/features/downloads/data/datasources/gallery_data_source_test.dart`, `.../repositories/download_repository_impl_test.dart`, `.../presentation/cubit/download_cubit_test.dart`, `test/features/wallpaper_detail/wallpaper_detail_download_test.dart`
**Target Platform**: Android minSdk 24 (7.0) / targetSdk 36 / compileSdk 36 — all inherited from `flutter.*` in `android/app/build.gradle.kts`. iOS unchanged
**Project Type**: Mobile app (Flutter, Clean Architecture, feature-first)
**Performance Goals**: No change to download throughput. `gal` streams through an 8 KB buffer into the MediaStore output stream — equivalent to the current path, no full-file buffering added
**Constraints**: Zero read-media permissions in the merged release manifest; no runtime permission prompt on API ≥ 29; saving must keep working on API 24–28 behind a single `WRITE_EXTERNAL_STORAGE` grant; no change to download engine internals, favorites, notifications, ads, or sharing
**Scale/Scope**: 1 manifest, 1 pubspec, 1 data source, 1 repository, 1 presentation page, ~4 test files. No new screens, no new entities, no schema change

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|---|---|---|
| I. Clean Architecture | Permission logic confined to the data layer; domain untouched | **Improves** — `wallpaper_detail_page.dart:244` currently calls `ph.openAppSettings()` directly from presentation. This plan routes it through `GalleryDataSource.openAppSettings()` (already on the contract, currently uncalled), which is what FR-011 requires |
| II. SOLID & DRY | Single responsibility; no hardcoded strings | **Improves** — the `'permission_permanently_denied'` sentinel is currently hardcoded in both `download_repository_impl.dart:39` and `wallpaper_detail_page.dart:224`. Extract to one constant. Existing `AppStrings.permissionRequired` / `.permissionPermanentlyDenied` / `.permissionDenied` are reused, not duplicated |
| III. Responsive-First (ScreenUtil) | No new sizing values introduced | **PASS** — no layout work in this feature |
| IV. Theming | No new colors or text styles | **PASS** — existing dialog/snackbar styling untouched |
| V. Error Handling (dartz Either) | Repository returns `Either<Failure, T>`; no silent catch | **PASS** — `downloadWallpaper` keeps its `Either` signature and both failure branches; the permanently-denied branch simply becomes unreachable on API ≥ 29 |
| VI. Performance | No main-thread heavy work; no leaks | **PASS** — isolate-backed download engine (branch 018) untouched; `gal` streams via buffer. Verified `gal` copies bytes into the MediaStore URI, so `download_engine.dart:99`'s post-save temp-file delete stays safe |
| VII. Testing | Unit tests for changed data source + repository; `flutter analyze` clean | **Required work** — four existing test files reference the current permission behavior and must be updated, not deleted |
| VIII. Monetization & Firebase | Ads/analytics/notification behavior unchanged | **PASS** — `POST_NOTIFICATIONS` and Firebase permissions are out of scope and stay as-is |
| Package standards | Latest stable at integration time | **PASS** — `gal ^2.3.2` is the latest stable and is already resolved in the local pub cache |
| Forbidden patterns | No `Image.network`, no raw `Text`, no hardcoded strings | **PASS** — no widget-tree changes beyond replacing one direct plugin call with a cubit-routed one |

**Result: PASS.** No violations to justify; two pre-existing debts (presentation-layer permission call, duplicated sentinel string) are corrected as part of satisfying FR-011 and Principle II. Complexity Tracking table is therefore empty and omitted.

## Project Structure

### Documentation (this feature)

```text
specs/020-remove-media-read-permissions/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output — build + verification runbook
├── contracts/
│   ├── gallery-data-source.md   # Dart contract for the gallery/permission boundary
│   └── android-permissions.md   # Declared permission set contract (the store-reviewed artifact)
├── checklists/
│   └── requirements.md  # Spec quality checklist (passing)
└── tasks.md             # Phase 2 output (/speckit.tasks — NOT created here)
```

### Source Code (repository root)

```text
android/app/src/main/
└── AndroidManifest.xml                     # remove READ_MEDIA_IMAGES, READ_MEDIA_VIDEO,
                                            # READ_EXTERNAL_STORAGE; WRITE_EXTERNAL_STORAGE maxSdk 29 -> 28

lib/
├── core/
│   └── constants/
│       └── app_strings.dart                # add permanently-denied sentinel constant
├── features/
│   ├── downloads/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── gallery_data_source.dart        # PRIMARY CHANGE: gal + delegated permission gate
│   │   │   ├── repositories/
│   │   │   │   └── download_repository_impl.dart   # sentinel constant; gate semantics unchanged
│   │   │   └── services/
│   │   │       └── download_engine.dart            # UNCHANGED (saveFile contract preserved)
│   │   └── presentation/
│   └── wallpaper_detail/
│       └── presentation/pages/
│           └── wallpaper_detail_page.dart  # drop direct permission_handler import; route via cubit

pubspec.yaml                                # -gallery_saver_plus, +gal ^2.3.2, version 1.0.3+7 -> 1.0.4+8
README.md                                   # correct the gal/gallery_saver_plus documentation mismatch

test/features/
├── downloads/data/datasources/gallery_data_source_test.dart      # update
├── downloads/data/repositories/download_repository_impl_test.dart # update
├── downloads/presentation/cubit/download_cubit_test.dart          # verify unaffected
└── wallpaper_detail/wallpaper_detail_download_test.dart           # update if it asserts the settings call
```

**Structure Decision**: Existing Flutter feature-first Clean Architecture layout (`lib/features/<feature>/{domain,data,presentation}`) is retained unchanged. This feature is a surgical change inside the existing `downloads` feature's data layer plus one Android build-config file; no new directories, layers, or features are introduced.

## Phase 0: Research Summary

Full findings in [research.md](./research.md). Decisions that drive the design:

1. **Offending permissions are app-declared, not plugin-merged** — all three candidate plugins ship empty library manifests. Removing the app-level lines is sufficient; no `tools:node="remove"` override is required (kept as a documented contingency).
2. **`gal` is the correct replacement** — `gal 2.3.2`'s `hasAccess()` returns `true` for API > 29 and for API 29 when not saving to a named album, and only checks `WRITE_EXTERNAL_STORAGE` on API 23–28. This is exactly the FR-002 / FR-003 split, implemented natively.
3. **`gal` has no `putVideoBytes`** — its bytes API is image-only (it format-sniffs with `Imaging.guessFormat`). `GalleryDataSource.putVideoBytes` must write a temp file and call `Gal.putVideo(path)`. This contradicts the original task description and is the one API-shape correction in this plan.
4. **`gal` copies bytes into the MediaStore URI** on both the legacy and scoped branches, so `download_engine`'s existing "save then delete temp file" sequence remains correct on every API level.
5. **API 29 is the residual risk** — `gal`'s legacy branch (`SDK_INT <= 29`) writes via the `DATA` column into the public Pictures/Movies dir. Documented fallback if API 29 testing fails: add `android:requestLegacyExternalStorage="true"` to `<application>` (a storage opt-out flag, not a permission — no policy impact, ignored on API 30+).
6. **`permission_handler` stays** — still needed for the app-settings deep link on the legacy denial path. It contributes no manifest permissions.

## Phase 1: Design Summary

- **[data-model.md](./data-model.md)** — the three conceptual entities (Media Save Request, Permission Gate, Declared Permission Set) mapped to concrete code and config locations, with the API-level state table for the permission gate.
- **[contracts/gallery-data-source.md](./contracts/gallery-data-source.md)** — the `GalleryDataSource` Dart contract: which methods keep their signature, what each must return per API level, and which callers depend on them.
- **[contracts/android-permissions.md](./contracts/android-permissions.md)** — the exact allowed and forbidden entries in the merged release manifest; this is the artifact SC-001 is verified against.
- **[quickstart.md](./quickstart.md)** — build, merged-manifest inspection, and two-emulator verification runbook.

### Post-Design Constitution Re-Check

Re-evaluated after Phase 1 design: **PASS**, unchanged from the pre-research check. The design adds no new abstraction (Principle VI's anti-over-engineering clause), removes one dependency, deletes more code than it adds, and moves one call from presentation into data — every movement is toward the constitution, none away.
