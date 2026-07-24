# Quickstart: Disable Ads & Isolate-Backed Downloads

**Feature**: 018-disable-ads-isolate-downloads
**Branch**: `018-disable-ads-isolate-downloads`

---

## Implementation order

Ordered so the tree compiles and tests pass after every stage.

### Stage 1 — Download engine (no ad changes yet)

1. `domain/entities/download_event.dart` — sealed `DownloadEvent`.
2. `data/services/download_runner.dart` — `DownloadRunner` + `RunnerMessage` types.
3. `data/services/download_isolate_entry.dart` — top-level entrypoint, throttled progress.
4. `data/services/download_engine.dart` — single-flight, replay, gallery save, cleanup.
5. `download_repository.dart` + `_impl.dart` — add `events`, delegate to the engine, resolve
   permission and paths before spawn.
6. `domain/usecases/watch_download_events.dart`.
7. `download_local_data_source.dart` — make `saveRecord` idempotent per `wallpaperId`.
8. DI: register `DownloadRunner`, `DownloadEngine`, `WatchDownloadEvents` as lazy singletons.

Checkpoint: `flutter analyze && flutter test` clean. Ads still fully live.

### Stage 2 — Cut the ad gate out of the download

9. `download_cubit.dart` — drop the rewarded gate, subscribe to events, cancel in `close()`.
10. `download_state.dart` — comment `isAdGateActive`.
11. `wallpaper_detail_page.dart` — comment its `isAdGateActive` readers (must ship with step 10).
12. Rewrite `download_cubit_test.dart` for the no-ad path.

Checkpoint: download works end to end with no ad. US1 testable here.

### Stage 3 — Comment out the ad layer

13. Pattern A on the 9 `lib/core/ads/**` files.
14. Pattern B on `main.dart`, `app.dart`, `splash_page.dart`, `home_page.dart`,
    `wallpaper_detail_page.dart`, `injection_container.dart`.
15. Pattern A on the 7 `test/core/ads/*` files.
16. `premium_local_source.dart:74` — comment the `canShowAppOpenAd` call site only.

Checkpoint: no ad executes anywhere; `flutter analyze` clean; app builds.

### Stage 4 — Premium visibility

17. `home_drawer.dart:90–111` — add the marker to the existing commented block.
18. `app_router.dart:144` — comment the `/premium` route.
19. Add the **Restore Purchases** drawer tile calling `PremiumCubit.restore()`; label into
    `AppStrings`.

Checkpoint: no purchase entry reachable; restore works; existing subscriber still resolves premium.

### Stage 5 — Verify

20. Full test suite, analyzer, device pass against the checks below.

---

## Verification commands

```bash
# every disabled site is marked (expect >= 18 files)
grep -rn "ads-disabled-018" lib/ test/

# no live ad usage outside comments
grep -rn "google_mobile_ads\|AdManager\|MobileAds\|AnchoredAdaptiveBanner" lib/ --include=*.dart | grep -v "^\s*//"

# no live navigation to the purchase screen
grep -rn "AppRoutes.premium" lib/ --include=*.dart

flutter analyze          # zero warnings
flutter test             # all green
flutter build apk --debug
```

---

## Manual device pass

| # | Check | Requirement |
|---|---|---|
| 1 | Fresh install, first launch — no consent form, no app-open ad | FR-003, FR-004 |
| 2 | Home — no bottom banner, no empty band where it was | FR-002, FR-005 |
| 3 | Switch categories 10× — no interstitial | FR-002 |
| 4 | Background/resume 3× — no app-open ad | FR-002 |
| 5 | Tap Download — saving starts within 1 s, no ad | FR-001, SC-001 |
| 6 | Download the largest video while scrolling — stays fluid, progress advances | FR-006, FR-007, SC-003 |
| 7 | Leave the screen mid-download, return — file saved, one history entry | FR-018 |
| 8 | Airplane mode → tap Download — existing offline message, no ad state | FR-008 |
| 9 | Deny gallery permission → existing denial dialog and settings path | FR-008 |
| 10 | Kill Wi-Fi mid-download — failure message, no partial file in gallery, no history entry | FR-016, FR-020 |
| 11 | Navigate the whole app — no purchase entry anywhere | FR-021, SC-010 |
| 12 | Restore Purchases with an active subscription — entitlement returns | FR-022 |
| 13 | Existing subscriber — still resolves as premium | FR-014 |

Memory check for SC-009: watch the memory graph while downloading the largest video. Peak should
stay flat rather than tracking file size — that is the buffered-to-streaming change proving out.

---

## Rollback

Whole feature: `git checkout main`.

Ads only, keeping the download work: follow the restore steps in
[`contracts/ad-disable-convention.md`](./contracts/ad-disable-convention.md#restoring-ads-later) —
uncomment by marker, revert the two stated replacements, restore the premium block and route.

---

## Traps

- **Do not send `Dio` into the isolate.** Non-sendable. Build a fresh one inside.
- **Do not call plugins inside the isolate.** Resolve the temp path before spawning; do the gallery
  save after the isolate finishes.
- **Do not use `ResponseType.bytes`.** That is the memory bug being fixed — `dio.download` streams.
- **Comment the imports too.** Unused imports are analyzer warnings and break the constitution VII
  gate.
- **`isAdGateActive` and its readers ship together.** Commenting the field alone breaks the build.
- **Do not make `DownloadCubit` a singleton.** State would bleed between the downloads page and the
  detail page; the engine is the singleton, not the cubit.
- **Close the `ReceivePort` on every path.** A leaked port keeps the isolate alive.
