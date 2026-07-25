---

description: "Task list for 020-remove-media-read-permissions"
---

# Tasks: Remove Unnecessary Media Read Permissions (Google Play Policy Fix)

**Input**: Design documents from `/specs/020-remove-media-read-permissions/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Test tasks are **mandatory** here — not as TDD, but because Constitution Principle VII requires unit tests for every changed data source, repository, and cubit, and four existing test files assert the permission behavior this feature changes. They must be updated, not deleted.

**Organization**: Grouped by user story so each is independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1 / US2 / US3 from spec.md
- Exact file paths included in every task

## Path Conventions

Flutter mobile app, feature-first Clean Architecture:
- Dart source: `lib/features/<feature>/{domain,data,presentation}/`, `lib/core/`
- Tests: `test/features/<feature>/...`
- Android config: `android/app/src/main/AndroidManifest.xml`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Swap the gallery-saving dependency so every later task compiles against `gal`

- [X] T001 In `pubspec.yaml`, remove `gallery_saver_plus: ^3.2.9` (line 86) and add `gal: ^2.3.2` to `dependencies`
- [X] T002 Run `flutter pub get`, then verify `pubspec.lock` contains a `gal` block and no `gallery_saver_plus` block

**Checkpoint**: `gal` resolved. `lib/features/downloads/data/datasources/gallery_data_source.dart` will not compile until T004–T007 — expected.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared constant consumed by both US1's repository change and US3's denial UX

**⚠️ CRITICAL**: T003 blocks T008 and T024

- [X] T003 In `lib/core/utils/app_strings.dart`, add a `permissionPermanentlyDeniedCode` constant with value `'permission_permanently_denied'`, placed next to the existing `permissionRequired` / `permissionDenied` / `permissionPermanentlyDenied` constants (Principle II — the literal is currently duplicated in `download_repository_impl.dart:39` and `wallpaper_detail_page.dart:224`)

**Checkpoint**: Foundation ready — user story work can begin

---

## Phase 3: User Story 1 - Saving without any permission prompt on modern Android (Priority: P1) 🎯 MVP

**Goal**: On API ≥ 29, wallpapers save to the gallery with zero runtime permission prompts, for both images and videos.

**Independent Test**: Fresh install on an Android 13+ device, download one image and one video wallpaper — both land in the system gallery, no permission dialog appears at any point, and Settings → Apps → Glowy → Permissions shows no "Photos and videos" entry.

### Implementation for User Story 1

- [X] T004 [US1] In `lib/features/downloads/data/datasources/gallery_data_source.dart`, replace the `package:gallery_saver_plus/gallery_saver.dart` import with `package:gal/gal.dart`, and rewrite `saveFile(path, {required isVideo})` to `isVideo ? await Gal.putVideo(path) : await Gal.putImage(path)` — **never pass an `album` argument** (an album flips `gal`'s API-29 gate from always-granted to permission-required; see `contracts/gallery-data-source.md`)
- [X] T005 [US1] In the same file, rewrite `putImageBytes(bytes, {name})` to delegate directly to `Gal.putImageBytes(bytes, name: name ?? 'wallpaper')`, dropping the temp-file round-trip (`gal` accepts image bytes natively)
- [X] T006 [US1] In the same file, rewrite `putVideoBytes(bytes, {name})` to write `bytes` to `<tmpDir>/<name ?? 'wallpaper'>.mp4`, call `await Gal.putVideo(tmpFile.path)`, and delete the temp file in a `finally` block — `gal` has **no** `putVideoBytes`; its bytes API is image-only (research R3)
- [X] T007 [US1] In the same file, rewrite `requestPermission()` to `return Gal.requestAccess();` and `checkPermission()` to `return Gal.hasAccess();`, deleting the `Permission.photos.request()` / `Permission.storage.request()` / `.photos.status` calls. `gal` enforces the API-level split natively (`hasAccess()` returns `true` for API > 29 and for API 29 without an album), so no Dart-side SDK-version branching is needed
- [X] T008 [US1] In `lib/features/downloads/data/repositories/download_repository_impl.dart:39`, replace the `'permission_permanently_denied'` string literal with `AppStrings.permissionPermanentlyDeniedCode` from T003, and replace the `'Storage permission denied'` literal at line 41 with `AppStrings.permissionDenied`. Keep the `Either<Failure, void>` shape and both failure branches intact (Principle V)
- [X] T009 [US1] Confirm `lib/features/downloads/data/services/download_engine.dart` needs **no** change — `gal` copies bytes into the MediaStore URI rather than referencing the path, so the existing save-then-delete-temp-file sequence at line 99 remains correct (research R4). Verify by reading, do not edit

### Tests for User Story 1

- [X] T010 [P] [US1] Update `test/features/downloads/data/datasources/gallery_data_source_test.dart` — correct the stale header comment naming `image_gallery_saver_plus` to `gal`, and keep the interface-contract tests for `putImageBytes` / `putVideoBytes` / `requestPermission` / `isPermanentlyDenied` passing against the unchanged abstract contract
- [X] T011 [P] [US1] Update `test/features/downloads/data/repositories/download_repository_impl_test.dart` — assert the permanently-denied branch returns `CacheFailure(AppStrings.permissionPermanentlyDeniedCode)` and the denied branch returns `CacheFailure(AppStrings.permissionDenied)`, replacing any hardcoded literals
- [X] T012 [P] [US1] Run `flutter test test/features/downloads/presentation/cubit/download_cubit_test.dart` and confirm it still passes unmodified; fix only if it asserts on the changed failure strings

### Verification for User Story 1

- [X] T013 [US1] On an Android 13+ (API 33+) emulator with a fresh profile, download one image and one video wallpaper — both save, no permission dialog appears, both are visible in the system gallery app, and `adb shell dumpsys package <applicationId>` shows no `READ_MEDIA` / `READ_EXTERNAL` requested permissions

**Checkpoint**: US1 fully functional — the no-prompt save path works end to end on modern Android

---

## Phase 4: User Story 2 - Store review passes with no photo/video read access declared (Priority: P1)

**Goal**: The shipped release artifact declares zero photo/video/storage read permissions, and carries a version code above the rejected 7.

**Independent Test**: Produce a release build and inspect the **merged** manifest and the APK's permission dump — neither contains `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_VISUAL_USER_SELECTED`, or `READ_EXTERNAL_STORAGE`.

### Implementation for User Story 2

- [X] T014 [US2] In `android/app/src/main/AndroidManifest.xml`, delete the `READ_EXTERNAL_STORAGE` entry (lines 6–7), the `READ_MEDIA_IMAGES` entry (line 8), and the `READ_MEDIA_VIDEO` entry (line 9). Leave `INTERNET`, `ACCESS_NETWORK_STATE`, `POST_NOTIFICATIONS`, `VIBRATE`, and `RECEIVE_BOOT_COMPLETED` untouched. Do **not** add `tools:node="remove"` overrides — no bundled plugin contributes these permissions (research R1)
- [X] T015 [P] [US2] In `pubspec.yaml:19`, change `version: 1.0.3+7` to `version: 1.0.4+8`. Do not edit `android/app/build.gradle.kts` — it reads `flutter.versionCode` / `flutter.versionName` from this field, and a second source of truth would diverge
- [X] T016 [P] [US2] In `README.md`, correct the gallery-package references at lines 55 and 242 from `gal 2.3.0` to `gal 2.3.2` so the documentation and `pubspec.yaml` agree (FR-007)

### Verification for User Story 2

- [X] T017 [US2] Run `flutter build apk --release`, then grep `build/app/intermediates/merged_manifest/release/AndroidManifest.xml` for `READ_MEDIA_|READ_EXTERNAL_STORAGE|MANAGE_EXTERNAL_STORAGE|ACCESS_MEDIA_LOCATION` — **zero matches required** (SC-001). If the path differs for this Gradle version, regenerate with `cd android; .\gradlew :app:processReleaseManifest`
- [X] T018 [US2] Cross-check the built artifact independently of Gradle intermediates: `aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk` — confirm the same zero matches. Note that `build/app/outputs/apk/release/output-metadata.json` does **not** list permissions and is not a valid check
- [X] T019 [US2] Confirm `versionCode` 8 propagated into the build output metadata (SC-005)

**Checkpoint**: US1 and US2 both hold — the release is permission-clean and version-bumped

---

## Phase 5: User Story 3 - Saving still works on older Android versions (Priority: P2)

**Goal**: API 24–28 devices keep a working save path behind a single `WRITE_EXTERNAL_STORAGE` grant, with clear denial messaging and a route into system settings — and permission handling stops leaking into the presentation layer.

**Independent Test**: On an Android 9 (API 28) emulator, downloading a wallpaper raises exactly one storage-write prompt; allowing saves the file, denying shows a clear message, and denying with "don't ask again" surfaces a dialog whose Open Settings button reaches the app's settings page.

### Implementation for User Story 3

- [X] T020 [US3] In `android/app/src/main/AndroidManifest.xml`, change the `WRITE_EXTERNAL_STORAGE` entry's `android:maxSdkVersion` from `29` to `28` (lines 4–5). Depends on T014 — same file, different lines, so do not run these in parallel
- [X] T021 [US3] In `lib/features/downloads/data/datasources/gallery_data_source.dart`, rewrite `isPermanentlyDenied()` to consult only `ph.Permission.storage.status.isPermanentlyDenied`, dropping the `Permission.photos` check. Per `data-model.md` this state is unreachable on API ≥ 29, so no version guard is needed — `Permission.storage` resolves to nothing requestable there
- [X] T022 [US3] In `lib/features/downloads/domain/repositories/download_repository.dart`, add `Future<void> openGallerySettings();` to the `DownloadRepository` contract, with a doc comment noting it is reachable only on the legacy (API < 29) permanently-denied path
- [X] T023 [US3] Create `lib/features/downloads/domain/usecases/open_gallery_settings.dart` with an `OpenGallerySettings` use case following the shape of the existing `download_wallpaper.dart` / `get_download_history.dart` use cases in that directory
- [X] T024 [US3] In `lib/features/downloads/data/repositories/download_repository_impl.dart`, implement `openGallerySettings()` by delegating to `_galleryDataSource.openAppSettings()`
- [X] T025 [US3] In `lib/core/di/injection_container.dart`, register the `OpenGallerySettings` use case alongside the other downloads use cases, and add it to the `DownloadCubit` construction
- [X] T026 [US3] In `lib/features/downloads/presentation/cubit/download_cubit.dart`, add a `Future<void> openAppSettings()` method that invokes the `OpenGallerySettings` use case, following the existing use-case-injection pattern in the constructor
- [X] T027 [US3] In `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart`, remove the `package:permission_handler/permission_handler.dart` import (line 20), replace the `ph.openAppSettings()` call (line 244) with `context.read<DownloadCubit>().openAppSettings()`, and replace the `'permission_permanently_denied'` literal at line 224 with `AppStrings.permissionPermanentlyDeniedCode`. This satisfies FR-011 — after this task `permission_handler` is imported in exactly one file, `gallery_data_source.dart`

### Tests for User Story 3

- [X] T028 [P] [US3] Update `test/features/wallpaper_detail/wallpaper_detail_download_test.dart` for the cubit-routed settings call — mock `DownloadCubit.openAppSettings()` instead of the direct plugin call, and use the sentinel constant
- [X] T029 [P] [US3] Add a repository test in `test/features/downloads/data/repositories/download_repository_impl_test.dart` asserting `openGallerySettings()` delegates to `GalleryDataSource.openAppSettings()` exactly once

### Verification for User Story 3

- [ ] T030 [US3] On an Android 9 (API 28) emulator with a fresh profile: download raises exactly one storage-write prompt; allow → saves and appears in the gallery; reinstall and deny → clear `AppStrings.permissionDenied` message, no silent failure; reinstall and deny with "don't ask again" → dialog appears and Open Settings reaches the app settings page
- [ ] T031 [US3] On an Android 10 (API 29) emulator — **the boundary case** — download an image and a video with a fresh profile: both save with **no** prompt and both appear in the system gallery. If saves succeed but files never appear (or throw), apply the documented fallback: add `android:requestLegacyExternalStorage="true"` to the `<application>` tag in `android/app/src/main/AndroidManifest.xml`, rebuild, re-run, and re-run T017. That attribute is a storage-behavior opt-out, not a permission — it does not affect the T017 check. **Never** re-add a `READ_*` permission

**Checkpoint**: All three stories independently functional across API 28, 29, and 33+

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T032 Run `dart format .` then `flutter analyze` — **zero warnings required** (Principle VII). Confirm no unused `permission_handler` imports, no `print()`, no leftover TODOs in changed files
- [X] T033 Run the full `flutter test` suite and confirm every test passes, including the four updated files
- [X] T034 Regression sweep on the API 33+ device (SC-007): download progress reporting and cancellation, download history list, favorites add/remove, push notification receipt and tap-through, share sheet — all unchanged
- [X] T035 Walk the Definition of Done table in `specs/020-remove-media-read-permissions/quickstart.md` and confirm all 10 rows pass before the build is handed off for store submission

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — blocks T008 and T027
- **US1 (Phase 3)**: Depends on Setup + Foundational. Delivers the MVP
- **US2 (Phase 4)**: Depends on Setup only for the build to succeed. T014/T015/T016 are editable in parallel with US1 work; T017–T019 require US1 code to compile
- **US3 (Phase 5)**: Depends on Foundational (T003) and shares `AndroidManifest.xml` with US2 (T014 → T020) and `gallery_data_source.dart` with US1 (T004–T007 → T021)
- **Polish (Phase 6)**: Depends on all stories complete

### User Story Dependencies

- **US1 (P1)**: Independently testable once Phase 1–2 complete. No dependency on US2 or US3
- **US2 (P1)**: Config-only edits are independent; its *verification* (T017–T019) needs a compiling build, so it lands after US1's code changes
- **US3 (P2)**: Independently testable on a legacy emulator. Shares two files with US1/US2 — sequence, don't parallelize those

### File-Conflict Warnings

| File | Tasks | Rule |
|---|---|---|
| `android/app/src/main/AndroidManifest.xml` | T014 (US2), T020 (US3), T031 fallback (US3) | Sequential — same file |
| `lib/features/downloads/data/datasources/gallery_data_source.dart` | T004–T007 (US1), T021 (US3) | Sequential — same file, never `[P]` |
| `lib/features/downloads/data/repositories/download_repository_impl.dart` | T008 (US1), T024 (US3) | Sequential — same file |
| `test/.../download_repository_impl_test.dart` | T011 (US1), T029 (US3) | Sequential — same file |

### Parallel Opportunities

- T010, T011, T012 — three different test files, run together
- T015, T016 — `pubspec.yaml` and `README.md`, run together (and alongside T014)
- T028, T029 — different test files, run together
- US2's config edits (T014–T016) can proceed while US1's data-layer work is in flight

---

## Parallel Example: User Story 1

```bash
# After T004-T009 land, run the three test updates together:
Task: "Update gallery_data_source_test.dart for gal (T010)"
Task: "Update download_repository_impl_test.dart for sentinel constants (T011)"
Task: "Verify download_cubit_test.dart still passes (T012)"
```

## Parallel Example: User Story 2

```bash
# Three independent files, no ordering between them:
Task: "Remove three read permissions from AndroidManifest.xml (T014)"
Task: "Bump pubspec version to 1.0.4+8 (T015)"
Task: "Correct gal version in README.md (T016)"
```

---

## Implementation Strategy

### MVP First (US1 + US2)

Both are P1 and together are the shippable fix: US1 makes the app work without the permissions, US2 proves they are gone from the artifact. Neither alone unblocks the release.

1. Phase 1 Setup (T001–T002)
2. Phase 2 Foundational (T003)
3. Phase 3 US1 (T004–T013)
4. Phase 4 US2 (T014–T019)
5. **STOP and VALIDATE** — merged manifest clean, API 33+ saves with no prompt

### Incremental Delivery

1. Setup + Foundational → `gal` wired, shared constant in place
2. US1 → modern-Android save path works with no prompts
3. US2 → artifact is permission-clean and version-bumped (release candidate exists here)
4. US3 → legacy devices keep working and the FR-011 layering leak is closed
5. Polish → analyze/test/regression/quickstart sign-off

### Risk Note

T031 (API 29 boundary) is the one task with a known unresolved outcome. Run it before treating the build as submission-ready; its fallback is documented and does not affect the T017 permission check.

---

## Notes

- `[P]` = different files, no dependencies
- `[Story]` label maps each task to US1/US2/US3 for traceability
- Commit after each task or logical group
- Constitution gate: `flutter analyze` must report zero warnings before any commit (Principle VII)
- Full contracts in `contracts/gallery-data-source.md` and `contracts/android-permissions.md`; verification runbook in `quickstart.md`
