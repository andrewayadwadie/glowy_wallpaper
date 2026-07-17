# Quickstart: FCM Push Notifications

## Precondition gate (BLOCKING — do before any code task)

1. Generate Firebase config:
   ```bash
   flutterfire configure --project=glowywallpaper
   ```
   Confirm both files exist:
   - `lib/firebase_options.dart`
   - `ios/Runner/GoogleService-Info.plist`
2. `android/app/google-services.json` already present — leave unchanged.

Implementation MUST NOT proceed until both missing files exist.

## Build & verify

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Freezed: NotificationEntity, NotificationState
flutter analyze                                             # MUST be zero warnings
flutter test test/features/notifications/                   # use cases, repo impl, cubit
flutter run
```

## Manual acceptance (maps to Success Criteria)

| Check | How | Expected |
|---|---|---|
| SC-001 foreground display | Send test push (title+body) with app open | Visible notification, expandable body |
| Big-picture (Q2) | Send push with `data.imageUrl` | Notification shows image (big-picture) |
| SC-002 deep-link tap | Send `data.deeplink=/...`, tap from FG / BG / terminated | Navigates to route 3/3 |
| SC-003 no/invalid link | Tap notification with no `deeplink` | Opens Home, no crash |
| SC-004 permission once | Fresh install → launch | OS prompt once; not again on relaunch |
| SC-005 token <5s | Permitted first launch | Token in debug log within 5s |
| SC-006 no-config startup | Remove/rename firebase config → launch | App reaches first screen, no crash |
| SC-007 channel id | grep code + manifest | Both = `glowy_high_importance` |

## Send a test push (FCM HTTP v1 / console)

Data payload fields the app reads:
- `deeplink` — app route string starting with `/` (optional; missing → Home)
- `imageUrl` — image URL for big-picture (optional)
- `notification.title`, `notification.body` — shown text

## Pre-release cleanup

- Remove the temporary FCM-token `debugPrint` (FR-018) before release.
