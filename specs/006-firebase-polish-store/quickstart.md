# Quickstart & Integration Scenarios: Firebase, Polish & Store Readiness

**Feature**: 006-firebase-polish-store | **Date**: 2026-03-25

---

## Integration Scenario 1: Push Notification — Logged-In User

**Goal**: Verify end-to-end notification delivery and navigation for an authenticated user.

### Setup
1. Log in to the app with valid credentials.
2. Ensure the app has notification permissions granted on the test device.

### Steps

**Foreground (app open)**:
1. Keep the app open on the Home screen.
2. Send a test FCM message to the device token with payload `{"route": "/wallpaper/test123"}`.
3. **Expected**: A heads-up notification banner appears at the top of the screen.
4. Tap the banner.
5. **Expected**: App navigates to `/wallpaper/test123`.

**Background (app minimised)**:
1. Press Home to background the app.
2. Send the same FCM message.
3. **Expected**: System tray shows the notification.
4. Tap the notification.
5. **Expected**: App comes to foreground and navigates to `/wallpaper/test123`.

**Terminated (app force-closed)**:
1. Force-close the app from the task manager.
2. Send the same FCM message.
3. **Expected**: Notification appears in system tray.
4. Tap the notification.
5. **Expected**: App launches, completes splash init, then navigates to `/wallpaper/test123`.

---

## Integration Scenario 2: Push Notification — Logged-Out User (Pending Route)

**Goal**: Verify that a logged-out user who taps a deep-link notification lands on the correct screen after login.

### Steps
1. Log out from the app (or clear session).
2. Send a test FCM message with payload `{"route": "/wallpaper/test456"}`.
3. Tap the notification from the system tray.
4. **Expected**: App opens on the Login screen (not home, not wallpaper).
5. Enter valid credentials and tap Login.
6. **Expected**: App navigates directly to `/wallpaper/test456` (not to Home).
7. **Expected**: Subsequent navigation events are unaffected (pending route cleared).

---

## Integration Scenario 3: Notification Permission — Contextual Request

**Goal**: Verify permission is requested after the first download or favorite, not on launch.

### Steps
1. Fresh install or clear app data (permission_requested = false).
2. Launch the app and navigate to the Home screen.
3. **Expected**: No permission dialog shown.
4. Tap a wallpaper to open the detail screen.
5. **Expected**: No permission dialog shown.
6. Tap the Download button and complete the download.
7. **Expected**: OS notification permission dialog appears immediately after download success.
8. Grant permission.
9. **Expected**: Permission dialog does NOT appear again on subsequent downloads or favorites.

---

## Integration Scenario 4: Side Menu Actions

**Goal**: Verify all drawer engagement actions work on both platforms.

### Steps
1. Open the side drawer from the Home screen.
2. Tap **Rate App** → **Expected**: Platform store app opens on the app's store listing page.
3. Return to app, open drawer.
4. Tap **Share App** → **Expected**: OS share sheet appears with a pre-filled link.
5. Dismiss share sheet, open drawer.
6. Tap **Send Feedback** → **Expected**: Default email client opens with `contactEmail` in the To field.
7. Open drawer, tap **About** → **Expected**: In-app page shows app description text.
8. Open drawer, tap **Privacy Policy** → **Expected**: In-app page shows privacy policy text.
9. Open drawer, tap **Terms of Use** → **Expected**: In-app page shows terms text.

---

## Integration Scenario 5: Shimmer & State Coverage

**Goal**: Verify all content screens show shimmer while loading and correct error/empty states.

### Setup
Use Charles Proxy or `flutter_test` network throttle to control network speed.

### Steps (per screen: Home, Categories, Favorites, Downloads, Classification Detail)

**Loading state**:
1. Open the screen with a throttled connection.
2. **Expected**: Shimmer skeleton is visible that matches the content layout shape.
3. Release throttle — content loads.
4. **Expected**: Shimmer transitions smoothly to real content with no white flash.

**Error state**:
1. Block the network entirely.
2. Open (or refresh) the screen.
3. **Expected**: Error widget shows a human-readable message and a "Retry" button.
4. Restore network, tap Retry.
5. **Expected**: Content loads successfully.

**Empty state** (Favorites / Downloads only):
1. Open Favorites or Downloads with no saved items.
2. **Expected**: Lottie animation + "No items yet" message is displayed.

---

## Integration Scenario 6: Responsive Layout

**Goal**: Verify tablet-specific layout on a 10-inch device/emulator.

### Steps
1. Run the app on a 10-inch tablet emulator (e.g., Pixel Tablet).
2. Open Home screen.
3. **Expected**: Wallpaper grid shows 3–4 columns (phone shows 2).
4. Open the side drawer.
5. **Expected**: Drawer width is ≤320dp; it does not stretch across the full tablet width.
6. In system settings, set font size to largest available (200%).
7. Navigate all primary screens.
8. **Expected**: No text overflow, clipping, or layout breaks observed.

---

## Integration Scenario 7: App Icon & Splash

**Goal**: Verify icon and splash display correctly on both platforms.

### Steps
1. Build a release APK (Android) and .ipa (iOS).
2. Install on a real device.
3. Check home screen launcher → **Expected**: Adaptive icon with correct foreground on Android; standard icon on iOS.
4. Cold-launch the app.
5. **Expected**: Native splash screen with branded background and logo appears before the app loads.
6. App navigates past splash.
7. **Expected**: No flash or jump between splash and first content screen.

---

## Test Data

| Scenario | FCM Payload Example |
|----------|---------------------|
| Wallpaper deep link | `{"notification": {"title": "New wallpaper!", "body": "Check this out"}, "data": {"route": "/wallpaper/abc123"}}` |
| Category deep link | `{"notification": {"title": "New category", "body": "Browse now"}, "data": {"route": "/"}}` |
| No deep link | `{"notification": {"title": "Hi!", "body": "Open the app"}}` |

## Known Limitations / Out of Scope

- Notification analytics (open rate, delivery rate) — tracked via Firebase Console, not in-app.
- In-app notification history/inbox — out of scope for this phase.
- Rich notifications (images in notification banner) — out of scope.
- Topic-based FCM subscriptions — future enhancement.
