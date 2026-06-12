# Contract: RewardedAdManager

`lib/core/ads/managers/rewarded_ad_manager.dart` — `@lazySingleton` (manual `sl.registerLazySingleton`).

Gates wallpaper downloads. Reward-or-network-fallback. Replaces `AdHelper.showRewardedInterstitialAd` for downloads.

## Public API

```dart
class RewardedAdManager {
  RewardedAdManager(this._ids, this._gatekeeper, this._analytics);

  /// Preload ahead of need. Safe to call repeatedly (dedupes).
  Future<void> preload();

  /// Show the rewarded ad for a download.
  /// - onRewardGranted: called exactly once when the user earns the reward
  ///   OR when the ad fails for a NETWORK reason (graceful degradation) OR
  ///   when [shouldShowAds] is false (premium). Proceed with download here.
  /// - onDismissedWithoutReward: called when the user dismisses early for a
  ///   NON-network reason, or a non-network failure occurs.
  /// At most one of the two callbacks fires per call.
  Future<void> showRewardedForDownload({
    required VoidCallback onRewardGranted,
    VoidCallback? onDismissedWithoutReward,
  });

  void dispose();
}
```

## Behavioral contract

| Condition | Result |
|---|---|
| `!gatekeeper.shouldShowAds` (premium) | `onRewardGranted()` immediately, no ad |
| Ad ready, user earns reward | `onRewardGranted()` (once) |
| Ad ready, user dismisses before reward (non-network) | `onDismissedWithoutReward()` |
| No ad ready → load within ~5s, network fail/offline | `onRewardGranted()` |
| No ad ready → load within ~5s, non-network fail | `onDismissedWithoutReward()` |
| Show fails, network-related | `onRewardGranted()` |
| Show fails, non-network | `onDismissedWithoutReward()` |
| After any show | dispose ad + `preload()` fresh |

Invariants: single-use ad; reload after show (FR-005); never blocks indefinitely (≤~5s, FR-003); analytics event on load/show/fail/reward/dismiss (FR-021); exactly one callback per call.

## Tests (mocktail)
- premium ⇒ immediate grant, no SDK call.
- network load failure ⇒ grant.
- non-network load failure ⇒ dismiss callback.
- earned reward ⇒ grant once.
- early dismiss (non-network) ⇒ no grant.
- network classification via `AdNetworkError.isNetworkError` (unit).
