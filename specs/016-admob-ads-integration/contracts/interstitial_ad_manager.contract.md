# Contract: InterstitialAdManager

`lib/core/ads/managers/interstitial_ad_manager.dart` — `@lazySingleton` (manual registration).

Shows a frequency-capped interstitial on category navigation. New (no existing category interstitial).

## Public API

```dart
class InterstitialAdManager {
  InterstitialAdManager(this._ids, this._gatekeeper, this._analytics);

  /// Preload (dedupes).
  Future<void> preload();

  /// Notify a category switch happened. Increments the switch counter and,
  /// if cap + cooldown + load + shouldShowAds are all satisfied, shows the
  /// interstitial. Never blocks navigation; silent if conditions unmet.
  void onCategorySwitched();

  void dispose();
}
```

## Behavioral contract

| Condition | Result |
|---|---|
| `!shouldShowAds` (premium) | never show |
| `switchesSinceLastShow < N (=4)` | no show, just count |
| cooldown not elapsed (`< 60s` since last show) | no show |
| no ad loaded | no show; `preload()` |
| cap met AND cooldown elapsed AND loaded | show; reset counter; set `_lastShownAt`; on dismiss → dispose + `preload()` |

Invariants: in-memory per-session cap/cooldown (R9, Q1); reset counter to 0 after show; preload + reload-after-show (FR-017); never blocks navigation (FR-014/016); analytics on load/show/fail/dismiss.

## Tests
- premium ⇒ never show.
- switches < N ⇒ no show.
- switches ≥ N but cooldown not elapsed ⇒ no show.
- cap + cooldown + loaded ⇒ show, counter resets (inject clock).
- no ad loaded at trigger ⇒ silent + preload requested.
