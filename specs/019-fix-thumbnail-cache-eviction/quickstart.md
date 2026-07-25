# Quickstart: Verifying the Thumbnail Cache Fix

## Prerequisites

- Branch `019-fix-thumbnail-cache-eviction` checked out, dependencies fetched
  (`flutter pub get`).
- A device/emulator with a network toggle (or use Android emulator's airplane mode /
  disable Wi-Fi & data).

## 1. Scroll-back instant reload (Home)

1. Launch the app, land on Home.
2. Scroll down through 4+ pages (80+ items) so more than 200 unique thumbnails have been
   requested.
3. Scroll back to the top.
4. **Expect**: first-page thumbnails render immediately — no shimmer replay, no visible
   reload flicker.

## 2. Scroll-back instant reload (Classification Detail)

1. Open any Classification Detail screen.
2. Repeat steps 2–4 above.
3. **Expect**: same instant-reload behavior.

## 3. Offline proof (disk cache, not network)

1. After completing steps 1–2 with network enabled, put the device in airplane mode.
2. Scroll back through the same previously-viewed thumbnails on both Home and
   Classification Detail.
3. **Expect**: all previously-viewed thumbnails still render correctly; only
   never-before-seen thumbnails (new pagination requests) fail to load.

## 4. No grid-cell mismatch during fast scroll

1. Re-enable network.
2. Fast-scroll (multiple screen-heights/second) through 100+ items on Home.
3. **Expect**: every grid cell always shows the wallpaper that belongs to it — no
   flashing/wrong image swap as cells recycle.

## 5. Memory/jank sanity check

1. With Flutter DevTools attached (or `flutter run --profile`), repeat step 4 for ~60
   seconds continuously.
2. **Expect**: no runaway memory growth pattern beyond current (pre-fix) baseline; no
   new dropped-frame spikes attributable to this change.

## 6. Backend header report (manual, no code change)

1. Pick any wallpaper's `thumbUrl` and inspect the HTTP response headers (e.g.
   `curl -I <thumbUrl>`).
2. Note whether `Cache-Control`/`ETag` (or equivalent) are present.
3. Report the finding — this is informational only per spec FR-009; no client code
   changes based on the result.

## Automated checks

```bash
flutter analyze
flutter test test/core/widgets/app_cached_image_test.dart
flutter test test/core/widgets/staggered_wallpaper_card_test.dart
flutter test test/core/services/wallpaper_cache_manager_test.dart
flutter test test/features/wallpapers/presentation/widgets/wallpaper_grid_test.dart
```

All must pass with zero `flutter analyze` warnings before considering the fix complete.
