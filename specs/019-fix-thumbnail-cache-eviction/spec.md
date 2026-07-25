# Feature Specification: Fix Cached Wallpaper Thumbnails Re-Downloading on Scroll-Back

**Feature Branch**: `019-fix-thumbnail-cache-eviction`
**Created**: 2026-07-24
**Status**: Draft
**Input**: User description: "Fix cached wallpaper thumbnails re-downloading on scroll-back in Home and Classification grids due to default cache manager eviction limits, missing global image cache tuning, and missing stable item keys."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Instant thumbnails when scrolling back up (Priority: P1)

A user browses the Home wallpaper grid, scrolling through several pages of thumbnails (well past the first ~200 images). They then scroll back to the top to revisit earlier wallpapers. Thumbnails they already viewed must appear instantly, without a shimmer/loading replay and without a fresh network fetch.

**Why this priority**: This is the core complaint — repeated re-downloading wastes the user's mobile data, drains battery, and makes the app feel broken/slow on an action (scrolling back) that should be free. It is the primary reason this fix exists.

**Independent Test**: Load Home, scroll down through 4+ pages (80+ items) so more than 200 unique thumbnails have been requested, scroll back to the top, and confirm the first page renders immediately with no shimmer placeholder replay.

**Acceptance Scenarios**:

1. **Given** a user has scrolled past 200+ wallpaper thumbnails on Home, **When** they scroll back to previously-viewed items, **Then** those thumbnails render immediately from local cache with no shimmer placeholder and no new network request.
2. **Given** a user has scrolled through several pages of a Classification Detail grid, **When** they scroll back up, **Then** previously-loaded thumbnails render immediately from local cache.
3. **Given** a user viewed wallpaper thumbnails on a previous app session, **When** they reopen the app within a reasonable cache-retention window (30 days) and view the same wallpapers again, **Then** the thumbnails load from local cache rather than re-downloading.

---

### User Story 2 - Thumbnails available without network (Priority: P2)

A user who already scrolled through a set of wallpapers loses network connectivity (e.g., airplane mode) or has a slow connection. Revisiting wallpapers they already viewed must not depend on the network.

**Why this priority**: Confirms the fix is a true persistent cache fix, not a coincidental in-memory or network-timing effect, and protects the experience under poor connectivity.

**Independent Test**: After initial load with network enabled, disable network entirely and scroll back through already-viewed thumbnails; they must still display correctly.

**Acceptance Scenarios**:

1. **Given** a user has viewed a set of thumbnails with network enabled, **When** network is disabled and the user scrolls back to those same thumbnails, **Then** they still render correctly from local cache.

---

### User Story 3 - No performance regression during long scroll sessions (Priority: P3)

A user scrolls quickly and extensively through the wallpaper grid. The fix for re-downloading must not introduce added memory pressure, dropped frames, or visual glitches (e.g., wrong image flashing on a recycled grid cell).

**Why this priority**: Protects existing app quality — the fix must not trade one problem (re-downloading) for another (jank or memory bloat, or images swapping onto the wrong grid cell).

**Independent Test**: Perform fast, extended scrolling (multiple screen-heights per second) through 100+ items on both Home and Classification Detail and observe frame smoothness, memory usage, and that each grid cell always shows the correct wallpaper for its position.

**Acceptance Scenarios**:

1. **Given** a user scrolls quickly through a long, mixed grid of wallpapers, **When** items are recycled off-screen and back on-screen, **Then** each grid cell always displays the wallpaper image that actually belongs to it (no mismatched/flashing images).
2. **Given** a long fast-scroll session across 100+ items, **When** compared to current behavior, **Then** there is no observable increase in dropped frames or app memory growth beyond current levels.

---

### Edge Cases

- What happens when the on-device thumbnail cache reaches its new, larger capacity limit? (Oldest/least-recently-used entries should be evicted first, same as today — only the limit changes.)
- What happens to a thumbnail cached more than 30 days ago? (Treated as stale; app fetches a fresh copy from network on next view.)
- What happens if a wallpaper's image is updated/replaced server-side after it was already cached locally? (Out of scope for this fix — no cache-busting/versioning behavior is being added; existing behavior is unchanged.)
- What happens when device storage is low and the larger cache can't be fully populated? (Cache manager falls back to its existing storage-pressure handling; no new low-storage behavior is introduced.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST retain previously-viewed wallpaper thumbnails in a local, persistent cache large enough to cover typical extended browsing sessions (at minimum 1000 unique thumbnails) before the oldest ones are evicted.
- **FR-002**: The app MUST serve previously-viewed thumbnails from local cache — with no shimmer/placeholder replay and no network request — when a user scrolls back to them within the cache's retention window.
- **FR-003**: The local thumbnail cache MUST retain entries for at least 30 days from when they were last cached, before being treated as stale.
- **FR-004**: The app's short-term (in-memory) image cache MUST be sized to reduce redundant decode/re-render work during a single long scroll session, without being unbounded.
- **FR-005**: Every wallpaper grid (Home, Classification Detail, and the similar-wallpapers picker) MUST ensure each visible grid position always displays the wallpaper that actually belongs to it, including after items are scrolled off-screen and back on, and during pagination.
- **FR-006**: This fix MUST apply uniformly to both the Home grid and the Classification Detail grid (and the similar-wallpapers picker), so the improvement is not limited to one screen.
- **FR-007**: The fix MUST NOT change what wallpapers are shown, in what order, or how pagination/loading-more behaves — only how already-shown thumbnails are retained for reuse.
- **FR-008**: The fix MUST NOT visibly change existing image transitions (e.g., detail-view hero/shared-element transitions) or accessibility labeling of images.
- **FR-009**: The system MUST report (as a follow-up finding, not a code change) whether the backend/CDN thumbnail responses include standard cache-friendliness signals (e.g., cache-control/expiry and a change-detection identifier), since their absence would limit how effective any client-side cache can be.

### Key Entities

- **Wallpaper Thumbnail**: The small preview image representing a wallpaper in a grid; identified by the wallpaper's unique id; has a source URL and a cached local copy.
- **Local Thumbnail Cache**: The on-device persistent store of previously-downloaded thumbnail files, with a maximum item count and a maximum retention age.
- **Grid Item Identity**: The stable association between a wallpaper's unique id and its on-screen grid cell, which must be preserved as the grid scrolls, recycles, and paginates.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After viewing 200+ wallpaper thumbnails in one session, scrolling back to any previously-viewed thumbnail displays it in under 100ms with no visible reload/shimmer, on both Home and Classification Detail grids.
- **SC-002**: With network fully disabled, 100% of thumbnails viewed earlier in the same session (within the retention window) still display correctly when scrolled back to.
- **SC-003**: Repeated network requests for the same thumbnail URL within a 30-day window drop to effectively zero (only the first view per thumbnail triggers a download).
- **SC-004**: During fast, extended scrolling through 100+ items, zero instances of a grid cell showing a wallpaper that doesn't belong to it, and no measurable regression in dropped-frame rate or memory usage versus current behavior.

---

## Addendum (2026-07-24): Eliminate scroll-back shimmer/resize replay

**Why**: After the disk + in-memory cache work (FR-001–FR-008) was verified, the reporter confirmed the network re-download is gone (fast, no data used) but a **grey shimmer flash still replays** on scroll-back. Root cause is a separate render-layer issue the original scope never touched: `StaggeredWallpaperCard` is a `StatefulWidget` whose element is destroyed when scrolled past the grid's cache-extent and rebuilt fresh on scroll-back. On rebuild it (a) resets `_aspectRatio = null` → shows the shimmer skeleton, (b) re-probes the image stream for width/height, and (c) replays the 300 ms 3:4→ratio resize tween — every time, even on a fully warm cache. The 500 ms image fade-in compounds the effect.

This addendum makes previously-viewed thumbnails render like a static asset on scroll-back: no shimmer skeleton, no re-probe, no resize animation, no fade.

### Additional Functional Requirements

- **FR-010**: A wallpaper card that has already decoded its aspect ratio earlier in the session MUST render its final proportional layout on the first frame when rebuilt (e.g. on scroll-back) — no shimmer skeleton, no aspect-ratio re-probe, and no resize animation.
- **FR-011**: Decoded aspect ratios MUST be memoized in a bounded in-memory store keyed by image URL, shared across all cards, so the memo survives individual card disposal. The store MUST NOT grow without bound over long sessions.
- **FR-012**: On rebuild of an already-cached thumbnail, the image MUST swap in instantly (no multi-hundred-ms fade). The change MUST be scoped to grid cards only — other `AppCachedImage` call sites (e.g. the detail hero) keep their existing transition.

### Additional Success Criteria

- **SC-005**: Scrolling back to any previously-viewed thumbnail shows the correct image at its correct proportions on the first rendered frame, with no shimmer skeleton, no size "pop"/resize animation, and no fade-in.
