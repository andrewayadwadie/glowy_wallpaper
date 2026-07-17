# Contract: ConsentManager + AdsInitializer

`lib/core/ads/consent_manager.dart`, `lib/core/ads/ads_initializer.dart`. UMP shipped inside `google_mobile_ads` (no new dependency).

## AdsInitializer API

```dart
class AdsInitializer {
  AdsInitializer(this._consentManager);

  /// Called once from main() before runApp().
  /// 1) gather consent (non-blocking on failure)
  /// 2) MobileAds.instance.initialize()
  /// 3) trigger preloads (rewarded, interstitial, app-open)
  /// Never throws past here — failure must not block launch.
  Future<void> initialize();
}
```

## ConsentManager API

```dart
class ConsentManager {
  /// Request consent info; if a form is required & available, load & show it.
  /// Returns when consent is resolved or determined unnecessary.
  /// Non-blocking semantics: errors are swallowed (logged) and the app proceeds.
  Future<void> gather({ConsentDebugSettings? debug});

  /// Whether ads may currently be requested (UMP canRequestAds()).
  Future<bool> canRequestAds();
}
```

## Behavioral contract

| Condition | Result |
|---|---|
| region requires consent, form available | show form once; persist choice (UMP SDK) (FR-025) |
| consent already obtained / not required | no prompt; proceed (FR-025) |
| offline / error gathering | swallow, proceed at default personalization (FR-026) |
| debug/forced geography set | prompt shown for testing outside EEA (FR-027) |
| any path | never blocks app launch beyond the one-time prompt (FR-026) |

Ordering invariant: consent gathered **before** `MobileAds.initialize()` and before any ad load.

## Native config required
- Android `AndroidManifest.xml`: `com.google.android.gms.ads.APPLICATION_ID` = `ca-app-pub-2083776520196762~1431087691` (real, from constitution VIII).
- iOS `Info.plist`: `GADApplicationIdentifier` (iOS App ID — TODO supply), `SKAdNetworkItems`, `NSUserTrackingUsageDescription`.

## Tests
- `canRequestAds` mocked true/false.
- gather error ⇒ does not throw (proceeds).
- ordering: init not called before gather (verify call order with mocktail).
