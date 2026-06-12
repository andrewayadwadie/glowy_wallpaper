# Contract: AppOpenAdManager

`lib/core/ads/managers/app_open_ad_manager.dart` — `@lazySingleton` (manual registration).

Shows an App Open ad after splash and on foreground resume. Replaces `AdHelper.loadAppOpenAd`/`showAppOpenAd`.

## Public API

```dart
class AppOpenAdManager {
  AppOpenAdManager(this._ids, this._gatekeeper, this._analytics);

  /// Preload an app-open ad (records load time). Dedupes concurrent loads.
  Future<void> loadAd();

  /// Show if a fresh ad is available and no full-screen ad is showing.
  /// Non-blocking: returns immediately if not available.
  /// [source] = 'splash' | 'resume' for analytics + resume cooldown.
  Future<void> showIfAvailable({required String source});

  bool get isShowingAd;

  void dispose();
}
```

## Behavioral contract

| Condition | Result |
|---|---|
| `!shouldShowAds` (premium) | no show |
| ad null OR age ≥ 4h | no show; discard stale; `loadAd()` |
| `isShowingAd` already true | no show (FR-009) |
| source=`resume` AND `now - _lastShownAt < 4min` | no show (FR-010a cap) |
| source=`resume` AND first foreground after cold start | no show (splash owns it) |
| available & eligible | show once; on dismiss/fail → null + `loadAd()` (FR-010) |

Invariants: 4h staleness (FR-008); no stacked full-screen (FR-009); reload after dismissal/failure (FR-010); resume cap ≥4min (FR-010a); analytics on load/show/fail/dismiss.

## Lifecycle wiring
A small app-root observer (`WidgetsBindingObserver`) calls `showIfAvailable(source:'resume')` on `AppLifecycleState.resumed`; observer removed on dispose. Splash calls `showIfAvailable(source:'splash')` after subscription resolves (guest only).

## Tests
- premium ⇒ no show.
- stale ad (>4h) ⇒ discarded, not shown.
- isShowingAd guard ⇒ second show suppressed.
- resume within 4min ⇒ suppressed; after ⇒ allowed (inject clock).
