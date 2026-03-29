# Feature Specification: Wallpaper Detail, Download & Favorites

**Feature Branch**: `004-detail-download-favorites`
**Created**: 2026-03-24
**Status**: Draft
**Input**: User description: "from plan.md start to implement Phase 4 — Wallpaper Detail, Download & Favorites"

## Clarifications

### Session 2026-03-24

- Q: Can unauthenticated (guest) users favorite and download wallpapers, or do these actions require login? → A: Both actions are available to guests. Downloads work identically. Favorites are local-only for guests (no server sync); sync activates once the user logs in.
- Q: When a user downloads a wallpaper they've already downloaded before, how should the download history behave? → A: Update the existing Download Record's timestamp (no duplicate entries); the wallpaper moves to the top of the My Downloads list with the most recent download time.
- Q: When a user taps a similar wallpaper from the bottom sheet, should the carousel context change? → A: Yes — replace the current carousel with the similar wallpapers list so the user can swipe through all similar items, creating a discovery chain.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Full-Screen Wallpaper Detail Carousel (Priority: P1)

A user taps a wallpaper thumbnail from any grid (image, video, or classification detail) and enters a full-screen detail view. The detail screen displays the wallpaper at full resolution, filling the entire screen. The user can swipe left/right to navigate through other wallpapers from the same category or classification they were browsing. An overlay action bar at the bottom provides quick-access buttons for download, favorite, and phone frame preview. The action bar semi-transparently overlays the wallpaper so the image remains the focal point.

**Why this priority**: The detail screen is the central experience — without it, users cannot view wallpapers at full resolution or take any action on them (download, favorite, preview). Every other Phase 4 feature depends on this screen existing.

**Independent Test**: Tap a wallpaper thumbnail from any grid → verify full-screen wallpaper loads → swipe left/right → verify navigation to adjacent wallpapers → verify overlay action bar is visible with download, favorite, and preview buttons → verify tapping the back button returns to the previous grid.

**Acceptance Scenarios**:

1. **Given** a user on any wallpaper grid, **When** they tap a wallpaper thumbnail, **Then** the wallpaper detail screen opens showing that wallpaper at full resolution in a full-screen view.
2. **Given** a user on the detail screen, **When** they swipe left, **Then** the next wallpaper from the same source list is displayed with a smooth horizontal transition.
3. **Given** a user on the detail screen, **When** they swipe right, **Then** the previous wallpaper from the same source list is displayed.
4. **Given** a user on the detail screen, **When** the wallpaper loads, **Then** a semi-transparent overlay action bar is shown at the bottom with download, favorite, and preview buttons.
5. **Given** a user on the detail screen viewing a video wallpaper, **When** the detail loads, **Then** the video plays in a muted loop at full screen with a tap-to-toggle sound control.
6. **Given** a user on the detail screen at the last wallpaper in the list, **When** they swipe left, **Then** no navigation occurs (the carousel stops at the end).
7. **Given** a user on the detail screen, **When** they tap the back button or swipe down, **Then** they return to the grid they came from, scrolled to the same position.

---

### User Story 2 - Download Wallpaper to Device Gallery (Priority: P2)

A user views a wallpaper in the detail screen and taps the download button. The system requests storage/photo library permissions if not already granted. Once permitted, the wallpaper image (or video) is downloaded and saved to the device's photo gallery. A success notification (toast) confirms the download. The download metadata is tracked locally so the user can view their download history later. For free users, a rewarded ad gate is shown before the download proceeds (actual ad integration in Phase 5 — this phase implements the gate hook with a placeholder that auto-proceeds).

**Why this priority**: Downloading wallpapers to set them on the device is the primary value proposition of the app. Users install wallpaper apps specifically to download and use wallpapers.

**Independent Test**: Open wallpaper detail → tap download → grant permissions if prompted → verify wallpaper saves to device gallery → verify success toast appears → verify download is recorded in local history.

**Acceptance Scenarios**:

1. **Given** a user on the detail screen, **When** they tap the download button, **Then** the system checks for required device permissions (photo library / storage access).
2. **Given** a user who has not granted permissions, **When** the permission dialog appears, **Then** the user can grant access and the download proceeds.
3. **Given** a user who has not granted permissions, **When** they deny the permission, **Then** a user-friendly message explains why permissions are needed and offers a way to open device settings.
4. **Given** a user with permissions granted, **When** the download starts, **Then** a loading/progress indicator is shown on the download button.
5. **Given** a successful download, **When** the file is saved to the device gallery, **Then** a success toast message confirms "Wallpaper saved to gallery."
6. **Given** a successful download, **When** the save completes, **Then** the download metadata (wallpaper ID, thumbnail URL, download timestamp) is recorded locally.
7. **Given** a network failure during download, **When** the download fails, **Then** an error message is displayed with a retry option.
8. **Given** a free user, **When** they tap download, **Then** a rewarded ad gate placeholder is triggered before the download proceeds (auto-proceeds in this phase; actual ad wired in Phase 5).

---

### User Story 3 - Favorite / Unfavorite Wallpapers (Priority: P3)

A user taps the favorite (heart) button on the detail screen to save a wallpaper to their favorites. The heart icon fills immediately (optimistic update) and the favorite is persisted locally first, then synced to the server in the background. Tapping the heart again removes the wallpaper from favorites (optimistic unfavorite). The favorite state is visible on the detail screen action bar — a filled heart for favorited wallpapers and an outlined heart for non-favorited ones.

**Why this priority**: Favorites allow users to curate a personal collection of wallpapers they love. This drives engagement and return visits. The local-first approach ensures the experience feels instant.

**Independent Test**: Open wallpaper detail → tap favorite heart → verify heart fills immediately → close and reopen the detail → verify heart is still filled → tap heart again → verify heart outlines → verify server sync occurs in background.

**Acceptance Scenarios**:

1. **Given** a user on the detail screen for a non-favorited wallpaper, **When** they tap the favorite button, **Then** the heart icon fills immediately (optimistic update).
2. **Given** a user who favorited a wallpaper, **When** they tap the favorite button again, **Then** the heart icon outlines immediately (optimistic unfavorite).
3. **Given** a user who favorited a wallpaper, **When** the favorite is saved locally, **Then** the system syncs the favorite to the server in the background.
4. **Given** a user who unfavorited a wallpaper, **When** the unfavorite is saved locally, **Then** the system syncs the removal to the server in the background.
5. **Given** a background sync failure, **When** the server call fails, **Then** the local state is preserved and a retry is queued for the next opportunity.
6. **Given** a user who returns to the detail screen for a previously favorited wallpaper, **When** the screen loads, **Then** the heart icon is filled, reflecting the persisted favorite state.

---

### User Story 4 - Favorites Page (Priority: P4)

A user navigates to the Favorites page (via the drawer menu or profile) and sees a grid of all wallpapers they have favorited. The grid uses the same responsive layout as the main wallpaper grids. Tapping a wallpaper opens the detail screen. If the user has no favorites, an empty state is shown with an illustration and a message encouraging them to explore wallpapers.

**Why this priority**: The Favorites page completes the favorites loop — users need a dedicated place to access their curated collection, not just the ability to toggle the heart.

**Independent Test**: Favorite several wallpapers → navigate to Favorites page via drawer → verify all favorited wallpapers appear in a grid → tap a wallpaper → verify detail screen opens → unfavorite a wallpaper from detail → return to Favorites page → verify it's removed → remove all favorites → verify empty state.

**Acceptance Scenarios**:

1. **Given** a user who has favorited wallpapers, **When** they navigate to the Favorites page, **Then** a grid of all favorited wallpapers is displayed using the same responsive column layout as the main grids.
2. **Given** a user on the Favorites page, **When** they tap a wallpaper thumbnail, **Then** the detail screen opens for that wallpaper.
3. **Given** a user who unfavorites a wallpaper from the detail screen, **When** they return to the Favorites page, **Then** the unfavorited wallpaper is no longer in the grid.
4. **Given** a user with no favorites, **When** they navigate to the Favorites page, **Then** an empty state is shown with an illustration and a message like "No favorites yet — explore wallpapers and tap the heart to save your favorites."
5. **Given** a user on the Favorites page, **When** the data loads, **Then** favorites are read from local storage first (instant display), then refreshed from the server if online.

---

### User Story 5 - My Downloads Page (Priority: P5)

A user navigates to the My Downloads page (via the drawer menu) and sees a grid of all wallpapers they have previously downloaded. The grid is built from locally stored download metadata (wallpaper ID, thumbnail URL, timestamp). Tapping a wallpaper opens the detail screen. If no downloads exist, an empty state is shown.

**Why this priority**: Users want to revisit wallpapers they've already downloaded — for re-downloading, re-sharing, or simply browsing their history.

**Independent Test**: Download several wallpapers → navigate to My Downloads → verify downloaded wallpapers appear in a grid sorted by most recent → tap a wallpaper → verify detail screen opens → verify empty state when no downloads exist.

**Acceptance Scenarios**:

1. **Given** a user who has downloaded wallpapers, **When** they navigate to the My Downloads page, **Then** a grid of downloaded wallpapers is displayed, sorted by download date (most recent first).
2. **Given** a user on the My Downloads page, **When** they tap a wallpaper thumbnail, **Then** the detail screen opens for that wallpaper.
3. **Given** a user with no downloads, **When** they navigate to the My Downloads page, **Then** an empty state is shown with an illustration and a message like "No downloads yet — browse wallpapers and tap the download button."
4. **Given** a user who downloads a new wallpaper, **When** they return to the My Downloads page, **Then** the newly downloaded wallpaper appears at the top of the grid.

---

### User Story 6 - Phone Frame Preview (Priority: P6)

A user taps the preview button on the detail screen action bar and sees the wallpaper displayed inside a phone frame mockup, showing how it would look as a device wallpaper. The preview appears as a full-screen overlay on top of the detail screen. Tapping anywhere on the overlay dismisses it. For free users, a rewarded ad gate is shown before the preview (placeholder in this phase).

**Why this priority**: The phone frame preview helps users visualize how a wallpaper will look on their actual device before downloading, reducing download regret and increasing satisfaction.

**Independent Test**: Open wallpaper detail → tap preview button → verify phone frame overlay appears with wallpaper inside → tap anywhere → verify overlay dismisses → verify returning to detail screen.

**Acceptance Scenarios**:

1. **Given** a user on the detail screen, **When** they tap the preview button, **Then** a full-screen overlay appears showing the wallpaper inside a phone frame mockup.
2. **Given** a user viewing the phone frame preview, **When** they tap anywhere on the overlay, **Then** the overlay dismisses and the user returns to the detail screen.
3. **Given** a phone frame preview, **When** it displays, **Then** the wallpaper is scaled and positioned correctly within the phone frame (no stretching, cropped to fit the screen area of the frame).
4. **Given** a free user, **When** they tap the preview button, **Then** a rewarded ad gate placeholder is triggered before the preview displays (auto-proceeds in this phase).

---

### User Story 7 - Similar Wallpapers (Priority: P7)

A user on the wallpaper detail screen can pull up a bottom sheet showing wallpapers similar to the one currently being viewed. The sheet is draggable — it can be pulled up to reveal more thumbnails or pushed down to dismiss. Tapping a wallpaper in the similar list navigates the detail carousel to that wallpaper. The similar wallpapers are fetched from the server.

**Why this priority**: Similar wallpapers drive content discovery and increase engagement. Once a user finds a wallpaper they like, they naturally want to see more in the same style.

**Independent Test**: Open wallpaper detail → pull up the bottom sheet → verify similar wallpapers load as thumbnails → tap a similar wallpaper → verify the detail carousel navigates to it → dismiss the sheet → verify detail screen returns to normal.

**Acceptance Scenarios**:

1. **Given** a user on the detail screen, **When** they pull up from the bottom or tap a "Similar" affordance, **Then** a draggable bottom sheet appears with a grid of similar wallpaper thumbnails.
2. **Given** a user viewing the similar wallpapers sheet, **When** similar wallpapers load, **Then** thumbnails are displayed in a scrollable grid within the sheet.
3. **Given** a user viewing the similar wallpapers sheet, **When** they tap a thumbnail, **Then** the carousel's source list is replaced with the similar wallpapers list and the detail view navigates to the tapped wallpaper (user can swipe through all similar items).
4. **Given** a user viewing the similar wallpapers sheet, **When** they drag it down, **Then** the sheet dismisses.
5. **Given** a wallpaper with no similar wallpapers, **When** the sheet opens, **Then** an empty state message is shown: "No similar wallpapers found."
6. **Given** a network failure when fetching similar wallpapers, **When** the request fails, **Then** an error state with a retry button is shown inside the sheet.

---

### Edge Cases

- What happens when the user tries to download a wallpaper without network connectivity? → Show an error message "No internet connection. Please try again later." with a retry option.
- What happens when the device runs out of storage during a download? → Show an error message "Not enough storage space. Free up space and try again."
- What happens when the user revokes storage permissions after previously granting them? → Re-prompt for permissions on the next download attempt; show the settings redirect message if denied again.
- What happens when a wallpaper image fails to load on the detail screen? → Show a placeholder error image with a retry button to reload.
- What happens when the user favorites a wallpaper while offline? → Save the favorite locally; sync to server when connectivity is restored.
- What happens when the favorites local and server states conflict (e.g., favorited on another device)? → Server state wins during sync; local state is updated to match.
- What happens when a user navigates to the detail screen from Favorites and unfavorites the wallpaper? → The wallpaper remains visible in the carousel for the current session but is removed from the Favorites page grid on return.
- What happens when the user taps download multiple times rapidly? → Ignore subsequent taps while a download is in progress (debounce).
- What happens when similar wallpapers returns an error? → Show error state inside the bottom sheet with a retry button; the main detail screen remains unaffected.
- What happens when a video wallpaper download occurs? → The video file is saved to the device gallery in a supported format.
- What happens when a guest user with local favorites logs in? → Local favorites are merged with the server-side favorites for that account; duplicates are deduplicated by wallpaper ID.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display wallpapers in a full-screen detail view when a user taps a thumbnail from any grid.
- **FR-002**: The detail screen MUST support horizontal swipe navigation (carousel) through wallpapers from the same source list the user was browsing.
- **FR-003**: The detail screen MUST display a semi-transparent overlay action bar with download, favorite, and preview buttons.
- **FR-004**: Video wallpapers MUST play in a muted loop on the detail screen, with a tap-to-toggle sound control.
- **FR-005**: Users MUST be able to download wallpaper images to their device's photo gallery.
- **FR-006**: Users MUST be able to download wallpaper videos to their device's gallery in a supported format.
- **FR-007**: The system MUST request and handle device permissions for photo library / storage access before downloading.
- **FR-008**: If the user denies permissions, the system MUST display a message explaining the need and offer a way to open device settings.
- **FR-009**: A loading indicator MUST be shown on the download button while a download is in progress.
- **FR-010**: A success toast MUST be shown after a wallpaper is successfully saved to the gallery.
- **FR-011**: Download metadata (wallpaper ID, thumbnail URL, download timestamp) MUST be stored locally for download history. Re-downloading the same wallpaper MUST update the existing record's timestamp rather than creating a duplicate entry.
- **FR-012**: Users MUST be able to toggle the favorite state of a wallpaper from the detail screen via a heart icon.
- **FR-013**: Favoriting MUST use optimistic updates — the UI MUST reflect the change immediately before server confirmation.
- **FR-014**: Favorites MUST be persisted locally first, then synced to the server in the background for authenticated users. For guest (unauthenticated) users, favorites MUST be stored locally only with no server sync.
- **FR-015**: If server sync for favorites fails (authenticated users), the local state MUST be preserved and a retry MUST be queued.
- **FR-016**: When local and server favorite states conflict during sync, server state MUST take precedence.
- **FR-032**: When a guest user logs in, locally stored favorites MUST be merged with their server-side favorites.
- **FR-017**: The Favorites page MUST display all favorited wallpapers in a responsive grid layout.
- **FR-018**: The Favorites page MUST show an empty state with illustration and message when no favorites exist.
- **FR-019**: The Favorites page MUST load favorites from local storage first (instant display), then refresh from the server.
- **FR-020**: The My Downloads page MUST display all previously downloaded wallpapers in a grid, sorted by download date (most recent first).
- **FR-021**: The My Downloads page MUST show an empty state with illustration and message when no downloads exist.
- **FR-022**: The My Downloads page MUST be built entirely from local download metadata (no server call required).
- **FR-023**: Users MUST be able to preview a wallpaper inside a phone frame mockup via a full-screen overlay.
- **FR-024**: The phone frame preview MUST scale and position the wallpaper correctly within the frame (no stretching).
- **FR-025**: The phone frame preview overlay MUST dismiss when the user taps anywhere.
- **FR-026**: The detail screen MUST provide access to a draggable bottom sheet showing similar wallpapers.
- **FR-027**: Tapping a similar wallpaper thumbnail MUST replace the current carousel's source list with the similar wallpapers list and navigate to the tapped wallpaper within that new list, allowing the user to swipe through all similar items.
- **FR-028**: For free users, download and preview actions MUST pass through a rewarded ad gate hook (placeholder in this phase that auto-proceeds; actual ad integration in Phase 5).
- **FR-029**: Duplicate downloads of the same wallpaper MUST be prevented while a download is in progress (debounce).
- **FR-030**: Navigating back from the detail screen MUST return the user to the previous grid at the same scroll position.
- **FR-031**: All screens (detail, favorites, downloads) MUST implement the four-state pattern: loading, error (with retry), empty (with illustration), success.

### Key Entities

- **Wallpaper**: A single wallpaper item. Key attributes: unique identifier, image URL, video URL (if video type), thumbnail URL, title, is premium flag, category ID, type (image/video).
- **Favorite**: A user's favorited wallpaper reference. Key attributes: wallpaper ID, user ID (null for guests), timestamp of favoriting, sync status (synced/pending/local-only).
- **Download Record**: Local metadata for a downloaded wallpaper. Key attributes: wallpaper ID (unique key — no duplicates), thumbnail URL, wallpaper title, download timestamp (updated on re-download), file type (image/video).
- **Similar Wallpaper**: A wallpaper returned by the similar wallpapers endpoint. Same attributes as Wallpaper, contextually related to the source wallpaper.

## Assumptions

- The server API provides endpoints for: fetching similar wallpapers by wallpaper ID, toggling favorites (add/remove), fetching the user's favorites list.
- The similar wallpapers endpoint returns a flat list (not paginated) since the count is expected to be limited (10-20 items).
- The phone frame mockup is a static asset bundled with the app (not fetched from the server).
- Permission handling follows platform conventions: Android 13+ uses granular media permissions; earlier Android uses broad storage permissions; iOS uses photo library access.
- Downloads save to the device's default photo gallery / camera roll location.
- The wallpaper detail screen receives the list of wallpapers from the calling grid (category wallpapers, classification wallpapers, or favorites) so the carousel can navigate through them.
- Download metadata is purely local and not synced across devices — it reflects downloads made on the current device only.
- The rewarded ad gate in this phase is a pass-through placeholder that immediately proceeds; the actual ad display is wired in Phase 5.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can swipe through wallpapers in the detail carousel with smooth, lag-free transitions.
- **SC-002**: Wallpaper downloads complete and appear in the device gallery within 5 seconds on a standard connection.
- **SC-003**: Favorite toggling reflects in the UI within 200 milliseconds of user tap (optimistic update).
- **SC-004**: The Favorites page displays all favorited wallpapers within 1 second, using local-first loading.
- **SC-005**: The My Downloads page loads instantly from local metadata with no network dependency.
- **SC-006**: The phone frame preview renders correctly without wallpaper distortion or stretching.
- **SC-007**: Similar wallpapers load and display in the bottom sheet within 2 seconds.
- **SC-008**: Users can navigate from any grid to detail, perform actions (download, favorite, preview), and return to the grid at their previous scroll position.
- **SC-009**: All screens handle offline, error, empty, and loading states without crashes or blank screens.
- **SC-010**: Free users encounter the ad gate placeholder before download and preview actions (gate auto-proceeds in this phase).
