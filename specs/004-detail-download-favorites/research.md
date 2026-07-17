# Research: Wallpaper Detail, Download & Favorites

**Feature**: 004-detail-download-favorites
**Date**: 2026-03-24

## R1: Gallery Save — Package Selection

**Decision**: Use `gal` package for saving images/videos to device gallery.

**Rationale**: `gal` is the most maintained Flutter gallery saver package (actively maintained, supports Android 13+ scoped storage, iOS photo library). It provides `putImageBytes()` and `putVideoBytes()` which align with the download flow (Dio streams bytes → save to gallery). Other packages like `image_gallery_saver` and `gallery_saver` are less actively maintained and have known issues with Android 13+ permissions.

**Alternatives considered**:
- `image_gallery_saver` — less maintained, manual permission handling on Android 13+
- `gallery_saver` — deprecated, no Android 13+ scoped storage support
- Manual `MediaStore` / `PHPhotoLibrary` via platform channels — unnecessary complexity

## R2: Permission Handling — Package Selection

**Decision**: Use `permission_handler` package for runtime permission requests.

**Rationale**: `permission_handler` is the standard Flutter package for requesting and checking permissions across Android and iOS. It handles the nuances of Android 13+ granular media permissions (`Permission.photos`, `Permission.videos`) vs. older Android (`Permission.storage`) and iOS (`Permission.photos`). It also provides `openAppSettings()` for the denied-permission flow (FR-008).

**Alternatives considered**:
- `gal` built-in permission prompts — insufficient for custom UX (need to show explanatory message before requesting)
- Manual platform channels — unnecessary when `permission_handler` covers all cases

## R3: Favorites Local Storage — Hive Box Design

**Decision**: Use a dedicated Hive box `favorites` keyed by wallpaper ID. Each entry stores a `FavoriteModel` JSON with wallpaper data, timestamp, and sync status.

**Rationale**: Hive is already used for categories cache and user data (established pattern). Keying by wallpaper ID ensures uniqueness (no duplicates) and O(1) lookups for `isFavorite` checks — critical for the detail screen action bar which needs to check favorite state on every page swipe. The sync status field (`synced`, `pending`, `local-only`) enables the local-first + background sync strategy.

**Alternatives considered**:
- SQLite via `sqflite` — overkill for a key-value lookup pattern; adds dependency
- SharedPreferences — not suitable for structured data or large datasets
- Separate Hive boxes per user — unnecessary complexity; user ID is stored per entry

## R4: Downloads Local Storage — Hive Box Design

**Decision**: Use a dedicated Hive box `downloads` keyed by wallpaper ID. Each entry stores a `DownloadRecordModel` JSON with thumbnail URL, title, timestamp, and file type.

**Rationale**: Same Hive pattern as favorites. Keying by wallpaper ID enforces the "no duplicate records" requirement (FR-011) — re-downloads update the existing entry's timestamp. Sorted retrieval (most recent first) is achieved by reading all values and sorting by timestamp in the repository.

**Alternatives considered**:
- Append-only list in a single Hive key — would require manual deduplication
- File-based tracking — less reliable than structured storage

## R5: Download Bytes Strategy — Non-blocking UI

**Decision**: Use Dio's `download` method with `ResponseType.bytes` and `onReceiveProgress` callback for progress tracking. The byte writing to gallery (via `gal.putImageBytes`) runs on the main isolate since it's a quick native call.

**Rationale**: Constitution Principle VI requires that download operations not block the UI thread. Dio's download is already async and doesn't block. The `gal.putImageBytes()` call delegates to native platform code which runs on a background thread internally. No manual isolate is needed.

**Alternatives considered**:
- Manual isolate for download — unnecessary; Dio is already non-blocking
- `flutter_downloader` — heavyweight, brings its own notification system and background task manager; overkill for direct-to-gallery saves

## R6: Favorites Sync Strategy — Background Sync

**Decision**: Fire-and-forget background sync after each local toggle. On failure, mark the entry as `pending` and retry on next app launch or next successful API call. The Favorites page refresh (load from server) also reconciles any pending syncs.

**Rationale**: Simple and reliable. The optimistic local update ensures instant UX (FR-013). The pending state prevents data loss. The server-wins conflict resolution (FR-016) is applied during the Favorites page server refresh — server response overwrites local state, and any remaining local `pending` entries are re-synced.

**Alternatives considered**:
- Dedicated sync queue with exponential backoff — over-engineering for a toggle operation
- Periodic background sync via WorkManager — overkill; sync on user-initiated refresh is sufficient

## R7: Carousel Source List Management

**Decision**: The detail screen cubit holds a mutable `wallpapers` list representing the current carousel context. Initially populated from the calling grid's wallpaper list. When a user taps a similar wallpaper, the list is replaced with the similar wallpapers list and the index jumps to the tapped item.

**Rationale**: This creates the "discovery chain" behavior specified in the clarification. The carousel context switch is a simple list replacement in the cubit state. Back navigation returns to the previous grid (not the previous carousel state) via GoRouter pop.

**Alternatives considered**:
- Navigation stack (push new detail screen per similar tap) — creates deep back-stack, memory-heavy
- Persistent original list with similar items appended — breaks mental model of "browsing similar wallpapers"

## R8: Phone Frame Preview — Asset Strategy

**Decision**: Bundle a single phone frame PNG asset (`assets/images/phone_frame.png`) — a generic modern smartphone bezel. The wallpaper is rendered inside the frame's screen area using a positioned/clipped container.

**Rationale**: The spec assumption states "phone frame mockup is a static asset bundled with the app." A single generic frame keeps the asset size small and avoids the complexity of supporting multiple device frames. The frame should be a transparent PNG with a cut-out screen area.

**Alternatives considered**:
- Multiple device frames (iPhone, Samsung, Pixel) — scope creep; can be added later
- `device_frame` package — adds dependency for a single overlay; simpler to use a custom asset
- Dynamically generated frame — unnecessary complexity

## R9: Hero Animation — Thumbnail to Detail Transition

**Decision**: Wrap wallpaper thumbnails (in grids) and the detail page image in `Hero` widgets with the wallpaper ID as the hero tag.

**Rationale**: Constitution development workflow gate requires "Hero animations MUST be used on wallpaper thumbnail → detail screen transitions." This is a built-in Flutter feature requiring no additional packages — just matching hero tags between the grid thumbnail and the detail page.

**Alternatives considered**:
- Custom page transition without Hero — violates constitution requirement
- `animations` package (Flutter team) — Hero is simpler and more appropriate for this use case

## R10: Ad Gate Placeholder Design

**Decision**: Create a simple `AdGatePlaceholder` utility that checks `SubscriptionCubit` state. If free user, it invokes a callback (future Phase 5 will replace with actual rewarded ad). In this phase, the callback immediately proceeds (auto-grant).

**Rationale**: This provides the hook point for Phase 5 integration (FR-028) without introducing ad SDK complexity now. The placeholder is a simple function/widget that can be swapped with the real ad gate later.

**Alternatives considered**:
- Skip entirely and add in Phase 5 — would require restructuring download/preview flows later
- Full ad SDK integration now — explicitly deferred to Phase 5 per spec

## New Dependencies Summary

| Package | Version | Purpose |
|---------|---------|---------|
| `gal` | ^2.3.0 | Save images/videos to device gallery |
| `permission_handler` | ^11.3.1 | Runtime permission requests (storage, photos) |

Both are well-maintained, widely used Flutter packages. No other new dependencies required — all other needs are met by existing packages.
