# Research: 011-download-connectivity-ux

**Date**: 2026-04-02

## R1: Connectivity Check Approach

**Decision**: Use the existing `NetworkInfo` abstraction (backed by `internet_connection_checker ^3.0.1`) to verify real internet reachability before download. Extend `NetworkInfo` with `connectivity_plus` (already in pubspec) to detect connection type and provide a richer "stability" signal.

**Rationale**: `internet_connection_checker` already performs DNS lookups to check actual internet reachability (not just WiFi connected) — it handles captive portals and dead connections. The project already has both `internet_connection_checker` and `connectivity_plus` in pubspec.yaml and a `NetworkInfo` abstraction at `lib/core/network/network_info.dart` registered in the DI container. No new package is needed.

**Alternatives considered**:
- `connectivity_plus` alone — only checks connection type (WiFi/cellular/none), does not verify actual internet access. Insufficient.
- Custom HTTP ping to a known endpoint — works but reinvents `internet_connection_checker`.
- Both packages combined — `connectivity_plus` for instant "has radio" check + `internet_connection_checker` for reachability. Best option: fail fast when no radio at all, then verify reachability.

## R2: Gallery Save with `image_gallery_saver_plus`

**Decision**: Replace the current `gal` package with `image_gallery_saver_plus` for saving wallpapers to the device photo gallery. The user explicitly requested this package.

**Rationale**: The user specifically asked to use `image_gallery_saver_plus` in the download process. The current codebase uses `gal ^2.3.0` for gallery saving via `GalleryDataSource`. The migration is contained to replacing the `gal`-specific calls in `GalleryDataSourceImpl` with equivalent `image_gallery_saver_plus` API calls. The abstract `GalleryDataSource` interface remains unchanged — only the implementation swaps.

**Alternatives considered**:
- Keep `gal` — rejected, user explicitly requested `image_gallery_saver_plus`.
- `image_gallery_saver` (without "plus") — less maintained fork. The "plus" version is the actively maintained one.

**Migration notes**:
- `gal.putImageBytes()` → `ImageGallerySaverPlus.saveImage()`
- `gal.putVideo()` → `ImageGallerySaverPlus.saveFile()` (for video temp file path)
- `gal.hasAccess()` / `gal.requestAccess()` → rely on `permission_handler` (already in the project) since `image_gallery_saver_plus` doesn't have its own permission API.
- Remove `gal: ^2.3.0` from pubspec, add `image_gallery_saver_plus`.

## R3: Ad Gate Graceful Fallback

**Decision**: Modify `adGatePlaceholder` to catch ad load/display failures and return `true` (proceed) instead of `false` (blocked). The download cubit also needs restructuring so the download logic runs regardless of ad outcome.

**Rationale**: Currently, `adGatePlaceholder` pushes a new route (`AdGateWidget`) that shows a full-screen dark overlay with `CircularProgressIndicator`. When the ad fails, it pops with `false`, blocking the download. The fix requires:
1. When `showRewardedInterstitialAd` returns `false` (ad failed), `AdGateWidget` should still call `onProceed()` and pop with `true`.
2. The download cubit should restructure so the download is not nested inside the `adGatePlaceholder` `onProceed` callback — instead, the cubit should first check connectivity, then attempt the ad gate, then proceed with download regardless of ad outcome (only blocked by connectivity).

**Alternatives considered**:
- Only modify the cubit, not the AdGateWidget — this won't fix the black screen issue since `AdGateWidget` is what creates the overlay.
- Remove `AdGateWidget` route entirely and show the ad inline — larger refactor than needed. Better to keep the ad gate but make its error path non-blocking.

## R4: Non-Blocking Progress UI (Animated Download Button)

**Decision**: Replace the full-screen `AdGateWidget` overlay + `CircularProgressIndicator` with an animated download button that shows fill progress inline in the `DetailActionBar`.

**Rationale**: The current `DetailActionBar._ActionButton` already conditionally shows a small `CircularProgressIndicator` inside the download button when `isDownloading` is true. This is close to the desired behavior but:
1. The `AdGateWidget` overlay (dark scrim + centered spinner) is the primary UX problem — it blocks the entire screen during ad loading. This must be removed/bypassed.
2. The existing small `CircularProgressIndicator` in the button can be enhanced to show a linear fill or percentage text instead, to indicate actual download progress.
3. Constitution principle V says `loader_overlay` + `flutter_spinkit` MUST be used for loading overlays and raw `CircularProgressIndicator` is forbidden. However, for an inline button progress indicator (not a full-screen overlay), a custom animated widget or a determinate progress indicator is more appropriate. The constitution's prohibition is about full-screen loading overlays, not about inline progress elements in buttons.

**Approach**: Refactor `DetailActionBar` download button to:
- When `isDownloading`: show a circular progress with percentage text (using `downloadProgress` value)
- Remove the full-screen `AdGateWidget` navigation. Instead, show the ad without a blocking route overlay.

## R5: Analytics Failure Logging

**Decision**: Add failure event logging alongside the existing success event in `DownloadCubit`.

**Rationale**: Currently `_analytics?.logEvent(name: 'download_wallpaper', ...)` is only called on success. Add `_analytics?.logEvent(name: 'download_wallpaper_failed', parameters: {'reason': ...})` for each failure path: no connectivity, gallery permission denied, download error, storage full.

**Alternatives considered**:
- Single event with a `status` parameter (success/failure + reason) — cleaner than separate event names but the existing success event uses `download_wallpaper` with no status field. Adding a separate failure event avoids breaking existing analytics dashboards.
