# Contract: Ad Disable Convention

**Feature**: 018-disable-ads-isolate-downloads

The rules every ad edit must follow. SC-006 and SC-008 are graded against this document.

---

## The marker

```dart
// TODO(ads-disabled-018): <one-line reason>
```

Exact form, no variation. Fixed by clarification Q1. Search key: `ads-disabled-018`.

Rules:

- Every disabled ad site carries it — no silent deletions, no unmarked comments.
- The reason says what the code *did*, not that it was commented: `rewarded gate removed — download
  no longer ad-dependent`, not `commented out`.
- No emoji (constitution: forbidden in code comments).
- One marker per contiguous block, not per line.

---

## Pattern A — whole-purpose files

For files that exist only to serve ads: `lib/core/ads/**` (9 files) and `test/core/ads/*` (7 files).

```dart
// TODO(ads-disabled-018): entire ad layer paused — restore by removing this
// header and the closing block comment below. See specs/018-disable-ads-isolate-downloads/.
/*
<original file contents, byte-for-byte unchanged>
*/
```

Notes:

- Dart supports **nested block comments**, so inner `/* */` inside the original body will not
  terminate the wrapper early.
- Imports go inside the wrapper along with everything else.
- The file stays in the repo at its original path. Never delete, never rename, never empty it.

---

## Pattern B — call sites inside living files

For the eight files that keep running.

```dart
// TODO(ads-disabled-018): app-open ad after splash — restore with the import above.
// await sl<AppOpenAdManager>().showIfAvailable(
//   source: AppOpenAdManager.sourceSplash,
// );
```

Rules:

- Comment the now-unused **import** too, with its own marker. An unused import is an analyzer
  warning, and constitution VII requires a clean `flutter analyze`.
- Keep surrounding live code untouched — no reformatting, no reindenting of unrelated lines.
- When removing a widget leaves a hole, state the replacement explicitly:

```dart
// TODO(ads-disabled-018): banner removed — restore `isPremium ? null : const AnchoredAdaptiveBanner()`
bottomNavigationBar: null,
```

---

## Site inventory

The complete list. Verified by inspection; SC-006 is checked against it.

### Pattern A — whole file (9 production)

| File |
|---|
| `lib/core/ads/ads_initializer.dart` |
| `lib/core/ads/consent_manager.dart` |
| `lib/core/ads/ad_gatekeeper.dart` |
| `lib/core/ads/ad_ids.dart` |
| `lib/core/ads/ad_network_error.dart` |
| `lib/core/ads/managers/app_open_ad_manager.dart` |
| `lib/core/ads/managers/interstitial_ad_manager.dart` |
| `lib/core/ads/managers/rewarded_ad_manager.dart` |
| `lib/core/ads/widgets/anchored_adaptive_banner.dart` |

### Pattern A — whole file (7 test)

`test/core/ads/`: `ad_gatekeeper_test.dart`, `ad_network_error_test.dart`,
`anchored_adaptive_banner_test.dart`, `app_open_ad_manager_test.dart`, `consent_manager_test.dart`,
`interstitial_ad_manager_test.dart`, `rewarded_ad_manager_test.dart`

### Pattern B — call sites

| File | Lines | What to comment |
|---|---|---|
| `lib/main.dart` | 9, 29–30 | `AdsInitializer` import + `initialize()` call |
| `lib/app.dart` | 5–6, 37–41, 60–63 | imports, resume app-open, `AdGatekeeper` sync in the subscription listener |
| `lib/features/splash/presentation/pages/splash_page.dart` | 7, 158–161 | import + post-splash app-open |
| `lib/features/home/presentation/pages/home_page.dart` | 7–8, 28–33, 99 | imports, category-switch interstitial listener, `bottomNavigationBar` banner |
| `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` | 21, 201–207, 287 | import, `isAdGateActive` overlay branch, interstitial call |
| `lib/core/di/injection_container.dart` | 7, 60–66, 164–183, 299 | `google_mobile_ads` import, 6 ad imports, `MobileAds` + 5 ad registrations, `rewardedAdManager:` cubit arg |
| `lib/features/downloads/presentation/cubit/download_cubit.dart` | 3, 17, 25, 31, 65–79 | import, field, ctor param, initializer, the whole rewarded gate in `download()` |
| `lib/features/downloads/presentation/cubit/download_state.dart` | 16–18 | `isAdGateActive` field + its doc comment |

### Premium visibility (same marker, FR-021)

| File | Lines | Action |
|---|---|---|
| `lib/features/home/presentation/widgets/home_drawer.dart` | 90–111 | already inside an unmarked `/*/ ... */` block — add the marker header |
| `lib/core/routes/app_router.dart` | 144 | comment the `/premium` `GoRoute` so no deep link reaches the purchase screen |

### Explicitly NOT touched

`pubspec.yaml` (`google_mobile_ads`), `android/app/src/main/AndroidManifest.xml`
(`APPLICATION_ID`), `ios/Runner/Info.plist` (`GADApplicationIdentifier`), `lib/core/config/env.dart`
and `env.g.dart` (ad unit ids). Out of Scope — the SDK and its configuration stay so the project
keeps building and restore stays one step.

### Known dead-but-harmless

`lib/features/premium/data/datasources/premium_local_source.dart:74` `canShowAppOpenAd(...)` is
premium-side cooldown bookkeeping whose only caller was the app-open manager. Comment the **call**,
leave the premium storage layer intact — it is not ad code.

---

## Verification

| Check | Command | Expected |
|---|---|---|
| Every site marked | `grep -rn "ads-disabled-018" lib/ test/` | ≥ 18 files, matching the inventory |
| No live ad usage | `grep -rn "google_mobile_ads\|AdManager\|MobileAds" lib/ --include=*.dart \| grep -v "^\s*//"` | only commented lines |
| Analyzer clean | `flutter analyze` | zero warnings (TODO diagnostics are IDE-only, not reported) |
| Tests green | `flutter test` | all pass |
| Builds | `flutter build apk --debug` | success |

## Restoring ads later

1. `grep -rn "ads-disabled-018" lib/ test/`
2. Pattern A files: delete the marker header and the wrapping `/*` … `*/`.
3. Pattern B sites: uncomment the marked lines including imports, and revert the stated replacements
   (for example `bottomNavigationBar` back to the ternary).
4. Restore the premium drawer block and the `/premium` route; decide then whether the standalone
   restore tile stays.
5. `flutter analyze && flutter test`.

No re-implementation is required at any step — that is what SC-008 asserts.
