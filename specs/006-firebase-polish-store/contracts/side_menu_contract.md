# Contract: Side Menu Actions

**Layer**: Presentation (`lib/features/home/presentation/widgets/home_drawer.dart`)
**Type**: Widget behavior contract
**Scope**: All 5 engagement actions in the app side drawer

---

## Action Contracts

### Rate App

**Trigger**: User taps "Rate App" in the drawer.

**Behavior**:
1. Determine platform.
2. Android: attempt `launchUrl(Uri.parse('market://details?id=${Env.androidPackageId}'))`.
3. If Android launch fails (store app not installed): fallback to `launchUrl(Uri.parse(appConfig.androidShareLink))`.
4. iOS: `launchUrl(Uri.parse('https://apps.apple.com/app/id${Env.appleAppId}'))`.
5. Log `rate_app_tapped` event to `FirebaseAnalytics`.

**Error handling**: If `launchUrl` throws, show a `SnackBar` with "Could not open store. Please search for Glowy Wallpapers manually."

**Data source**: `Env.androidPackageId`, `Env.appleAppId` from `envied` environment config.

---

### Share App

**Trigger**: User taps "Share App" in the drawer.

**Behavior**:
1. Determine platform.
2. Android: call `Share.share(appConfig.androidShareLink, subject: 'Check out Glowy Wallpapers!')`.
3. iOS: call `Share.share(appConfig.iphoneShareLink, subject: 'Check out Glowy Wallpapers!')`.
4. Log `share_app_tapped` event to `FirebaseAnalytics`.

**Data source**: `HomeCubit.state.appConfig.androidShareLink` / `iphoneShareLink`.

**Pre-condition**: `appConfig` must be non-null (home data loaded). If null, show "Share link not available yet." SnackBar.

---

### Send Feedback

**Trigger**: User taps "Send Feedback" in the drawer.

**Behavior**:
1. Construct URI: `mailto:${appConfig.contactEmail}?subject=Feedback%20-%20Glowy%20Wallpapers`.
2. Call `launchUrl(uri, mode: LaunchMode.externalApplication)`.
3. Log `send_feedback_tapped` event to `FirebaseAnalytics`.

**Error handling**: If `canLaunchUrl` returns false, show SnackBar: "No email app found. Please email us at ${appConfig.contactEmail}".

---

### About / Privacy Policy / Terms of Use

**Trigger**: User taps "About", "Privacy Policy", or "Terms of Use" in the drawer.

**Behavior**:
1. Call `context.push(AppRoutes.about, extra: ContentType.about)` (or `.privacyPolicy` / `.termsOfUse`).
2. `ContentPage` renders the corresponding `appConfig` field as scrollable text.

**Data source**: `HomeCubit.state.appConfig.about`, `.privacyPolicy`, `.termsOfUse`.

**Pre-condition**: If `appConfig` is null, `ContentPage` shows an error state with retry (retries home data fetch).

---

## Shared Rules

- All drawer item taps MUST close the drawer before launching external actions.
- All analytics events MUST be logged with `FirebaseAnalytics.logEvent`.
- No hardcoded email addresses, package IDs, or share links in `home_drawer.dart` — all from `appConfig` or `Env`.

---

## Test Contract

| Action | Expected |
|--------|----------|
| Rate App tapped on Android | `launchUrl('market://...')` called; analytics event logged |
| Rate App tapped on iOS | `launchUrl('https://apps.apple.com/...')` called |
| Rate App store URL unavailable | Fallback URL attempted; SnackBar shown if both fail |
| Share App tapped | `Share.share(link)` called with platform-appropriate link |
| Send Feedback tapped | `launchUrl('mailto:...')` called with pre-filled address |
| About tapped | Navigate to `/about` with `ContentType.about` extra |
| Privacy Policy tapped | Navigate to `/about` with `ContentType.privacyPolicy` extra |
| Terms tapped | Navigate to `/about` with `ContentType.termsOfUse` extra |
