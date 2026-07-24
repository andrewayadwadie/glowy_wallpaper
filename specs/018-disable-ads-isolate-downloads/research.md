# Phase 0 Research: Disable Ads & Isolate-Backed Downloads

**Feature**: 018-disable-ads-isolate-downloads
**Date**: 2026-07-24

All Technical Context unknowns are resolved below. No NEEDS CLARIFICATION markers remain.

---

## R1 — How to run the download off the main isolate while still streaming progress

**Decision**: `Isolate.spawn` with a `ReceivePort`, behind a `DownloadRunner` abstraction.

The isolate entrypoint is a top-level function receiving a plain `Map<String, Object?>`
(`url`, `tempPath`, `sendPort`). It streams progress messages back as maps and finishes with a
terminal `done` or `error` message.

**Rationale**: `compute()` and `Isolate.run()` return a single value and cannot report intermediate
progress, which FR-007 requires. `Isolate.spawn` + `SendPort` is the only stdlib option that
streams. Wrapping it behind a `DownloadRunner` interface keeps the engine unit-testable with a
fake runner (constitution VII) — isolates themselves are awkward to assert on in `flutter_test`.

**Alternatives considered**:

- `compute()` / `Isolate.run()` — rejected: no progress channel.
- Keep `dio` on the main isolate and rely on its async I/O — rejected: FR-006 and constitution VI
  explicitly require isolate or streaming for `Dio` download bytes; the current implementation also
  does CPU-visible work (`Uint8List.fromList` copy) on the main isolate.
- `flutter_downloader` / `background_downloader` package — rejected: new dependency, native
  background service, notification channel, and OS-level queueing are all out of scope.

---

## R2 — Plugin access from a background isolate

**Decision**: no plugin channel calls inside the isolate. The isolate uses only `dart:io` and a
`Dio` instance it constructs itself.

Everything that needs a plugin stays on the main isolate:

| Step | Plugin | Isolate |
|---|---|---|
| Permission request | `permission_handler` | main (before spawn) |
| Temp directory path | `path_provider` | main (before spawn, path passed in) |
| Network transfer + file write | none (`dio`, `dart:io`) | **background** |
| Save into gallery | `gallery_saver_plus` | main (after isolate completes) |
| History record | `hive` | main |

**Rationale**: calling a plugin from a spawned isolate requires
`BackgroundIsolateBinaryMessenger.ensureInitialized(RootIsolateToken.instance!)` and the plugin
must be documented as background-isolate-safe. `gallery_saver_plus` makes no such guarantee.
Resolving the temp path on the main isolate before spawning removes the requirement entirely and
leaves the isolate as pure Dart, which also makes it trivially testable.

**Alternatives considered**:

- Pass `RootIsolateToken` and initialize the background messenger — works on Flutter 3.7+, but adds
  a failure mode (null token in some embedder states) for zero benefit here.
- Do the gallery save inside the isolate — rejected: unsupported by the plugin, and the native save
  already runs off the Dart thread.

---

## R3 — Streaming write instead of buffering whole file (FR-019)

**Decision**: inside the isolate, `dio.download(url, tempPath, onReceiveProgress: ...)`, which
consumes the response as a stream and writes through an `IOSink`.

**Rationale**: the current path calls `dio.get<List<int>>(..., responseType: bytes)` and then
`Uint8List.fromList(response.data!)` — the whole file is held twice at peak. A 60 MB video costs
~120 MB, which is the low-memory OOM the spec flags. Streaming keeps peak at the chunk buffer,
independent of file size, satisfying FR-019 and SC-009.

**Alternatives considered**:

- Buffer + hard size cap — explicitly rejected during clarification (no size limit imposed).
- Manual `ResponseType.stream` + hand-rolled `IOSink` loop — equivalent, more code; only needed if
  custom chunk handling were required. `dio.download` already gives byte-accurate progress.

---

## R4 — Keeping a download alive after the user leaves the screen (FR-018)

**Problem found in code**: `DownloadCubit` is registered with `sl.registerFactory` and is created
per route in `app_router.dart:77` (downloads page) and `app_router.dart:102` (detail page). Popping
the detail page closes that cubit. Any isolate owned by the cubit would be orphaned, and the
terminal result would have nowhere to land — FR-018 would fail.

**Decision**: introduce a session-scoped `DownloadEngine` registered as `registerLazySingleton`.
It owns the runner, the active job, and a broadcast event stream. `DownloadRepositoryImpl`
delegates to it. `DownloadCubit` becomes a subscriber: it starts jobs and listens, and `close()`
cancels only its own subscription — never the job.

Late subscribers must not miss state, so the engine's `events` getter replays the last event before
forwarding the live stream:

```dart
Stream<DownloadEvent> get events async* {
  final last = _last;
  if (last != null) yield last;
  yield* _controller.stream;
}
```

**Rationale**: smallest change that decouples job lifetime from widget lifetime. Manual replay
avoids adding `rxdart` (not in the constitution's mandated package list).

**Alternatives considered**:

- Register `DownloadCubit` as a lazy singleton — rejected: history/error/success state would bleed
  between the downloads page and the detail page, and the four-state pattern per screen
  (constitution V) would break.
- Persist a "resume on next launch" record — rejected: that is background/resumable downloading,
  explicitly out of scope.

---

## R5 — Progress emission rate

**Decision**: the isolate throttles progress messages — emit only when the percentage advances by
at least 1 point or at least 100 ms has elapsed, plus a guaranteed final 100% message.

**Rationale**: `dio` fires `onReceiveProgress` per chunk; on a fast connection that is hundreds of
messages per second, each causing a cubit emit and a widget rebuild. Throttling at the source keeps
the port traffic and the rebuild count bounded, protecting SC-003 (no frame stall over 100 ms).

---

## R6 — Partial-file cleanup and atomic completion (FR-020)

**Decision**: download to `<tmpDir>/wallpaper_<id>.<ext>.part`. On success, rename to
`wallpaper_<id>.<ext>`, hand that path to the gallery saver, then delete it. On any failure or
error, delete the `.part` file in a `finally` block and record no history entry.

**Rationale**: the `.part` suffix makes an interrupted transfer unmistakable, and rename-on-success
means the gallery saver never sees a truncated file. FR-020 requires no history entry on failure,
so the Hive write stays strictly after a successful gallery save.

---

## R7 — Commenting strategy for the ad layer

**Decision**: two patterns, both anchored by the marker `// TODO(ads-disabled-018): <reason>`.

1. **Whole-purpose files** (`lib/core/ads/**`, the seven `test/core/ads/*` files): a marker header
   at the top of the file, then the entire remaining body wrapped in a single `/* ... */` block.
   Dart supports nested block comments, so inner `/* */` occurrences do not terminate the wrapper
   early.
2. **Call sites inside living files**: line comments on the ad statements *and* their now-unused
   imports, with one marker line directly above each commented block explaining what it did.

Commenting an import is mandatory, not optional — an unused import is an analyzer warning and
constitution VII requires `flutter analyze` to be clean.

**Rationale**: FR-009 requires disabling without deleting, and SC-008 requires restoration to be
pure reversal. A single grep for `ads-disabled-018` must surface every site (SC-006).

**Note on `flutter analyze`**: the analyzer's TODO diagnostic is an IDE-only hint; `dart analyze`
and `flutter analyze` do not report it. The markers therefore do not break the zero-warning gate.
This is verified as an explicit implementation step rather than assumed.

---

## R8 — Complete ad call-site inventory

Verified by direct inspection. This is the checklist SC-006 is graded against.

**Whole-purpose files (9 production, 7 test)**

| File | Contents |
|---|---|
| `lib/core/ads/ads_initializer.dart` | consent → MobileAds init → preloads |
| `lib/core/ads/consent_manager.dart` | UMP consent form |
| `lib/core/ads/ad_gatekeeper.dart` | `shouldShowAds` flag |
| `lib/core/ads/ad_ids.dart` | per-platform unit ids |
| `lib/core/ads/ad_network_error.dart` | error classification |
| `lib/core/ads/managers/app_open_ad_manager.dart` | app-open |
| `lib/core/ads/managers/interstitial_ad_manager.dart` | interstitial |
| `lib/core/ads/managers/rewarded_ad_manager.dart` | rewarded |
| `lib/core/ads/widgets/anchored_adaptive_banner.dart` | banner widget |
| `test/core/ads/*.dart` (7 files) | ad unit tests |

**Call sites inside files that stay alive**

| File | Lines | What |
|---|---|---|
| `lib/main.dart` | 9, 29–30 | import + `AdsInitializer.initialize()` |
| `lib/app.dart` | 5–6, 37–41, 60–63 | imports, resume app-open, gatekeeper sync |
| `lib/features/splash/presentation/pages/splash_page.dart` | 7, 158–161 | import + post-splash app-open |
| `lib/features/home/presentation/pages/home_page.dart` | 7–8, 28–33, 99 | imports, category interstitial, `bottomNavigationBar` banner |
| `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` | 21, 201–207, 287 | import, ad-gate overlay branch, interstitial |
| `lib/core/di/injection_container.dart` | 7, 60–66, 164–183, 299 | `MobileAds` + 6 ad registrations + cubit param |
| `lib/features/downloads/presentation/cubit/download_cubit.dart` | 3, 17, 25, 31, 56, 65–79 | rewarded gate |
| `lib/features/downloads/presentation/cubit/download_state.dart` | 16–18 | `isAdGateActive` field |

**Deliberately left untouched** (Out of Scope): `pubspec.yaml` `google_mobile_ads`,
`android/app/src/main/AndroidManifest.xml` `APPLICATION_ID`, `ios/Runner/Info.plist`
`GADApplicationIdentifier`, `lib/core/config/env.dart` + `env.g.dart` ad id fields. The envied ad
fields become unreferenced, which is not an analyzer warning for public static constants.

**False positive**: `lib/features/premium/data/datasources/premium_local_source.dart:74`
`canShowAppOpenAd(...)` is premium-side cooldown bookkeeping, not an ad operation. Its only caller
is the app-open manager, so it becomes dead but harmless — comment its call, not the premium
storage layer.

---

## R9 — Premium purchase entry point (FR-021 / FR-022)

**Finding**: the premium drawer entry is **already commented out** at
`lib/features/home/presentation/widgets/home_drawer.dart:90–111`, inside an unmarked `/*/ ... */`
block that also covers the "manage subscription" item. `grep` confirms `AppRoutes.premium` has
exactly one navigation site — that commented one. FR-021 is therefore already satisfied in
substance; what is missing is the marker and the verification.

**Consequence for FR-022**: with that block commented, `get_premium_page.dart` — which hosts the
restore button — is unreachable from the UI. An existing subscriber reinstalling on a new device
currently has no way to recover their entitlement. This is a live gap the spec now forbids.

**Decision**:

1. Re-comment the existing `/*/` block using the standard marker so it is traceable and reversible
   with everything else.
2. Comment out the `/premium` `GoRoute` registration (`app_router.dart:144`) with the marker, so no
   deep link or notification payload can surface the purchase screen while ads are paused.
3. Add one **Restore Purchases** item to the drawer's info section, calling
   `PremiumCubit.restore()` directly. It never opens the purchase page, so FR-021 holds while
   FR-022 is satisfied.

The restore tile is the only net-new UI in this feature. It reuses the existing `_buildMenuItem`
helper, the existing `RestorePurchases` use case, and the existing `PremiumCubit.restore()` success
and failure messaging. Its label goes in `AppStrings` (constitution II — no hardcoded strings).

**Alternatives considered**:

- Leave `/premium` routed and reachable only by deep link — rejected: a notification payload could
  expose the purchase screen, breaking FR-021.
- Route the restore tile to `get_premium_page` — rejected: that page sells subscriptions.
- Add no restore path at all — rejected: FR-022, and store policy expects a restore path for
  non-consumable/subscription purchases.

---

## R10 — Download history idempotency

**Decision**: verify and, if needed, make `DownloadLocalDataSource.saveRecord` idempotent per
`wallpaperId` before wiring FR-018.

**Rationale**: FR-018 forbids a duplicate history entry when a download completes after its screen
closed and the user then reopens the wallpaper. The dedupe belongs in the local data source, not in
the engine, so both the new flow and the existing one benefit.

---

## R11 — Test approach

| Target | Test | Note |
|---|---|---|
| `DownloadEngine` | new unit test with a fake `DownloadRunner` | scripted progress/terminal events; asserts single-flight, replay, cleanup |
| `DownloadRepositoryImpl` | unit test with mocked engine, gallery source, local source | asserts no history write on failure (FR-020) |
| `DownloadCubit` | rewrite existing test | no ad collaborator; event-driven progress; survives close |
| Detail page | widget test | no ad gate overlay, download button reachable immediately |
| Ad tests | commented out with marker | FR-013 |

`mocktail` for mocks, `bloc_test` for the cubit — both already in the project.
