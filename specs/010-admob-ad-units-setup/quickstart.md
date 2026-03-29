# Quickstart: AdMob Ad Units Integration

**Feature**: 010-admob-ad-units-setup | **Date**: 2026-03-27

## Prerequisites

- Flutter 3.41.5 / Dart 3.11.3 installed
- `google_mobile_ads` package already in pubspec.yaml
- AdMob account active with 4 ad units created
- Firebase configured (`google-services.json` in place)

## Setup Steps

### 1. Update Environment Config

Update `.env.dev` with production ad unit IDs:

```
ADMOB_APP_ID=ca-app-pub-2083776520196762~1431087691
ADMOB_APP_OPEN_ID=ca-app-pub-2083776520196762/2548207750
ADMOB_BANNER_ID=ca-app-pub-2083776520196762/8536132654
ADMOB_REWARDED_INTERSTITIAL_ID=ca-app-pub-2083776520196762/2641508848
ADMOB_INTERSTITIAL_ID=ca-app-pub-2083776520196762/1519998865
```

### 2. Update Env Dart Config

Add new fields to `lib/core/config/env.dart`:

```dart
@EnviedField(varName: 'ADMOB_REWARDED_INTERSTITIAL_ID')
static String adMobRewardedInterstitialId = _Env.adMobRewardedInterstitialId;

@EnviedField(varName: 'ADMOB_INTERSTITIAL_ID')
static String adMobInterstitialId = _Env.adMobInterstitialId;
```

Remove the old `ADMOB_REWARDED_ID` field.

### 3. Regenerate Env

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Verify

Run the app on a physical device (AdMob test ads don't render on emulators reliably):

```bash
flutter run
```

Check:
- [ ] App Open ad appears on splash (cold start)
- [ ] Banner ad visible at Home bottom
- [ ] Tap Download → Rewarded Interstitial plays → download starts after reward
- [ ] Tap Favorite (add) → Interstitial shows → favorite added after dismiss
- [ ] Tap Favorite (remove) → No ad, immediate removal
- [ ] Tap Favorite twice within 60s → Second favorite has no ad (cooldown)
- [ ] Preview button → No ad gate, opens directly
- [ ] Premium user → Zero ads anywhere

## Key Files

| File | Purpose |
|------|---------|
| `.env.dev` | Production ad unit IDs |
| `lib/core/config/env.dart` | Envied config class |
| `lib/core/services/ad_helper.dart` | Central ad management singleton |
| `lib/core/widgets/ad_gate_placeholder.dart` | Blocking ad gate for downloads |
| `lib/core/widgets/banner_ad_widget.dart` | Real AdMob banner widget |
| `lib/features/splash/presentation/pages/splash_page.dart` | App Open ad trigger |
| `lib/features/home/presentation/pages/home_page.dart` | Banner ad display |
| `lib/features/downloads/presentation/cubit/download_cubit.dart` | Download ad gate |
| `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` | Favorite ad gate + preview (no gate) |
