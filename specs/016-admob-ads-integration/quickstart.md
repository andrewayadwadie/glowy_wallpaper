# Quickstart: AdMob Ads Integration

How to wire, build, and verify the four placements. For implementers + QA.

## Prerequisites / manual steps

1. **Android App ID** (already known from constitution VIII):
   `android/app/src/main/AndroidManifest.xml` inside `<application>`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-2083776520196762~1431087691"/>
   ```
2. **iOS** `ios/Runner/Info.plist` (TODO: supply real iOS App ID):
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-2083776520196762~XXXXXXXXXX</string> <!-- TODO iOS App ID -->
   <key>NSUserTrackingUsageDescription</key>
   <string>This identifier will be used to deliver personalized ads to you.</string>
   <key>SKAdNetworkItems</key>
   <array>
     <dict><key>SKAdNetworkIdentifier</key><string>cstr6suwn9.skadnetwork</string></dict>
     <!-- + the full Google SKAdNetwork list -->
   </array>
   ```
3. **iOS production ad unit IDs** (per format) — TODO: obtain from AdMob and place in `.env.prod` iOS fields. Until then iOS serves test ids.
4. **.env.prod** — add `ADMOB_REWARDED_ID=ca-app-pub-2083776520196762/6581955872`. Confirm existing `ADMOB_APP_OPEN_ID`, `ADMOB_BANNER_ID`, `ADMOB_INTERSTITIAL_ID`.
5. **Test device**: register your device id (logged by the SDK on first ad request) in `AdsInitializer` `RequestConfiguration(testDeviceIds: [...])` for safe live testing.

## Codegen (envied changed)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
(Only needed because `Env` gained fields. DI is manual — no codegen for managers.)

## Wiring summary

| Where | Change |
|---|---|
| `lib/main.dart` | `await sl<AdsInitializer>().initialize();` before `runApp` (replaces `AdHelper.instance.initialize()`). |
| `injection_container.dart` | register `AdIds`, `AdGatekeeper`, `ConsentManager`, `AdsInitializer`, `RewardedAdManager`, `AppOpenAdManager`, `InterstitialAdManager`. |
| app root (e.g. `app.dart`) | listen to `SubscriptionCubit` → `AdGatekeeper.shouldShowAds = !isPremium`; add `WidgetsBindingObserver` → `AppOpenAdManager.showIfAvailable(source:'resume')`. |
| `splash_page.dart` | replace `AdHelper.instance.showAppOpenAd()` with `sl<AppOpenAdManager>().showIfAvailable(source:'splash')` (guest only). |
| `download_cubit.dart` | inject `RewardedAdManager`; run the actual download inside `onRewardGranted`; drop direct `AdHelper` call. |
| `home_page.dart` | swap `BannerAdWidget` → `AnchoredAdaptiveBanner`; add `BlocListener<HomeCubit,HomeState>` (listenWhen on `selectedCategoryIndex` change) → `sl<InterstitialAdManager>().onCategorySwitched()`. |
| remove | `lib/core/services/ad_helper.dart`, `lib/core/widgets/banner_ad_widget.dart` after migration + test fixups. |

## Build & run

```bash
flutter pub get
flutter analyze            # must be zero warnings (constitution VII)
dart format .
flutter test               # manager unit tests green
flutter run                # debug ⇒ TEST ads automatically (kReleaseMode=false)
flutter build apk --release   # release ⇒ PROD ids
```

## Verification checklist (maps to acceptance scenarios)

### US1 Rewarded download (P1)
- [ ] Online, tap Download → rewarded ad shows → on complete, download saves. (AS1)
- [ ] Airplane mode, tap Download → `networkUnavailable` is the only gate; with connectivity-but-no-fill, ~5s spinner then download proceeds, no ad error. (AS2, AS3)
- [ ] Close ad early (online, non-network) → no download. (AS4)
- [ ] After a show → next tap has an ad ready. (AS5)
- [ ] Premium → no ad, direct download. (AS6)

### US2 App-open (P2)
- [ ] Cold start with preloaded ad → ad once → Home. (AS1)
- [ ] No ad ready → straight to Home, no wait. (AS2)
- [ ] >4h old ad → discarded. (AS3)
- [ ] Background→foreground after ≥4min → app-open shows; within 4min → not. (AS7/AS8)
- [ ] Premium → never. (AS6)

### US3 Banner (P2)
- [ ] Home shows bottom adaptive banner, grid not covered/clipped. (AS1)
- [ ] Force load failure → slot collapses, no grey box. (AS2)
- [ ] Leave Home → banner disposed. (AS3)
- [ ] Premium → no slot. (AS4)

### US4 Category interstitial (P3)
- [ ] Switch categories rapidly → interstitial at most once / 4 switches AND ≥60s apart. (AS1, AS2)
- [ ] No ad loaded at trigger → switch proceeds, preload kicks in. (AS3)
- [ ] After show → fresh preload. (AS4)
- [ ] Premium → never. (AS5)

### Consent (FR-025–027)
- [ ] Forced-geography debug → consent form appears first launch, once. (SC-010)
- [ ] Offline first launch → app proceeds, no block. (FR-026)

### Cross-cutting
- [ ] `flutter analyze` zero warnings; no `print`. (VII)
- [ ] Debug build requests only test ids; release requests prod ids. (SC-008)
- [ ] Analytics events fire for load/show/fail/reward/dismiss. (SC-007)
