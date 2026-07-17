# Feature Specification: Fix Favorites, Download & Preview

**Feature Branch**: `009-fix-favorites-download-preview`
**Created**: 2026-03-26
**Status**: Draft
**Input**: User description: "Fix favorite button and download button functionality in wallpaper detail page. Favorites should save locally and open wallpaper detail from favorites screen. Downloads should save to device gallery. Preview should display wallpaper in a phone wireframe as a live wallpaper."

## Clarifications

### Session 2026-03-26

- Q: When opening wallpaper detail from favorites/downloads screen, should the user swipe through all items or see only the tapped wallpaper? → A: Swipeable list — pass all favorites (or downloads) to the detail page so the user can swipe through them.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Toggle Favorite on Wallpaper Detail (Priority: P1)

A user browsing wallpapers taps the favorite (heart) button on the wallpaper detail page. The wallpaper's URL, thumbnail, and metadata are immediately saved to local storage. The heart icon visually toggles to a filled/active state. If the wallpaper was already favorited, tapping again removes it from local storage and the icon returns to its unfilled/inactive state.

**Why this priority**: Favoriting is the core engagement action — users expect instant, reliable toggling without delays or errors. This is the foundation that the favorites screen depends on.

**Independent Test**: Can be fully tested by opening any wallpaper in detail view, tapping the heart icon, and verifying the icon state changes. Re-opening the same wallpaper confirms the favorite persisted.

**Acceptance Scenarios**:

1. **Given** a wallpaper detail page is displayed and the wallpaper is not favorited, **When** the user taps the favorite button, **Then** the heart icon fills/activates, and the wallpaper is saved to local favorites storage with its ID, URL, thumbnail URL, media type, and timestamp.
2. **Given** a wallpaper detail page is displayed and the wallpaper is already favorited, **When** the user taps the favorite button, **Then** the heart icon empties/deactivates, and the wallpaper is removed from local favorites storage.
3. **Given** the user favorites a wallpaper, **When** the user swipes to a different wallpaper and returns, **Then** the favorite icon correctly reflects the persisted state.
4. **Given** the user favorites a wallpaper, **When** the app is closed and reopened, **Then** the wallpaper still appears as favorited on the detail page.

---

### User Story 2 - View and Navigate from Favorites Screen (Priority: P1)

A user opens the favorites screen and sees a grid of all wallpapers they have favorited. Each item shows the wallpaper thumbnail. Tapping any item navigates to the wallpaper detail page for that specific wallpaper, with the favorite icon already shown as active/filled.

**Why this priority**: Without the ability to view and re-access favorited wallpapers, the favorite button provides no lasting value.

**Independent Test**: Can be tested by favoriting 2-3 wallpapers, navigating to the favorites screen, verifying all appear, and tapping one to confirm it opens in wallpaper detail with the correct favorite state.

**Acceptance Scenarios**:

1. **Given** the user has favorited 3 wallpapers, **When** they navigate to the favorites screen, **Then** all 3 wallpapers appear in a grid with their thumbnails.
2. **Given** the favorites screen is displayed, **When** the user taps a wallpaper thumbnail, **Then** the wallpaper detail page opens showing that wallpaper with the favorite icon in the active/filled state, and the user can swipe horizontally to browse other favorited wallpapers.
3. **Given** the user removes a wallpaper from favorites on the detail page (opened from favorites screen), **When** they navigate back to the favorites screen, **Then** that wallpaper no longer appears in the grid.
4. **Given** the user has no favorited wallpapers, **When** they open the favorites screen, **Then** an empty state is displayed with a message encouraging them to browse and favorite wallpapers.

---

### User Story 3 - Download Wallpaper to Device Gallery (Priority: P1)

A user taps the download button on the wallpaper detail page. The system requests storage/gallery permission if not already granted, downloads the full-resolution image or video, saves it to the device's photo gallery, and records the download locally. A success confirmation is shown. The downloaded wallpaper also appears on the downloads screen.

**Why this priority**: Downloading wallpapers to the device is the primary value proposition of a wallpaper app — users need to actually get the wallpaper onto their device.

**Independent Test**: Can be tested by tapping download on any wallpaper, granting permission, and checking the device gallery for the saved file. Then verifying the wallpaper appears on the downloads screen.

**Acceptance Scenarios**:

1. **Given** a wallpaper detail page is displayed, **When** the user taps the download button for the first time, **Then** the system requests gallery/storage permission.
2. **Given** gallery permission is granted, **When** the download button is tapped, **Then** a progress indicator is shown during download, the file is saved to the device gallery, a success message is displayed, and a download record is stored locally.
3. **Given** the user downloads a video wallpaper, **When** the download completes, **Then** the video file is saved to the device gallery in a playable format.
4. **Given** a download is in progress, **When** the user views the download button, **Then** a progress indicator or loading state is visible until the download completes.
5. **Given** the device has no network connectivity, **When** the user taps download, **Then** an appropriate error message is displayed.
6. **Given** the user denies gallery permission, **When** the download button is tapped, **Then** a message guides the user to enable the permission in device settings.

---

### User Story 4 - View and Navigate from Downloads Screen (Priority: P2)

A user opens the downloads screen and sees a grid of all wallpapers they have previously downloaded, ordered by most recent first. Tapping any item navigates to the wallpaper detail page for that wallpaper.

**Why this priority**: Complements the download feature by giving users a history of their downloads and quick re-access.

**Independent Test**: Can be tested by downloading 2 wallpapers, opening the downloads screen, verifying both appear in order, and tapping one to confirm it opens in detail view.

**Acceptance Scenarios**:

1. **Given** the user has downloaded 3 wallpapers at different times, **When** they open the downloads screen, **Then** all 3 appear in a grid sorted by most recent download first.
2. **Given** the downloads screen is displayed, **When** the user taps a wallpaper thumbnail, **Then** the wallpaper detail page opens for that item, and the user can swipe horizontally to browse other downloaded wallpapers.
3. **Given** the user has no downloaded wallpapers, **When** they open the downloads screen, **Then** an empty state is displayed with a message encouraging them to download wallpapers.

---

### User Story 5 - Phone Frame Preview (Priority: P2)

A user taps the preview button on the wallpaper detail page. A new screen opens displaying a phone wireframe/mockup. The selected wallpaper is displayed inside the phone frame, giving the user a realistic preview of how the wallpaper will look on their device. For video wallpapers, the video plays inside the frame to simulate a live wallpaper. The user can dismiss the preview to return to the detail page.

**Why this priority**: Preview helps users make download decisions by seeing how the wallpaper looks on a real phone shape, increasing satisfaction and reducing wasted downloads.

**Independent Test**: Can be tested by opening any wallpaper detail, tapping preview, verifying the wallpaper renders inside a phone frame, and dismissing the preview.

**Acceptance Scenarios**:

1. **Given** the user is on a wallpaper detail page for an image, **When** they tap the preview button, **Then** a screen appears showing a phone wireframe with the image displayed inside the frame area.
2. **Given** the user is on a wallpaper detail page for a video, **When** they tap the preview button, **Then** a screen appears showing a phone wireframe with the video playing inside the frame area, simulating a live wallpaper.
3. **Given** the preview screen is displayed, **When** the user taps anywhere outside the phone frame or uses the back gesture, **Then** the preview is dismissed and the user returns to the wallpaper detail page.
4. **Given** a video preview is playing, **When** the user dismisses the preview, **Then** the video playback stops and resources are released.

---

### Edge Cases

- What happens when the user rapidly toggles the favorite button multiple times? The system should debounce or serialize the operations to prevent data inconsistency.
- What happens when local storage is full or corrupted? The system should handle storage errors gracefully and display a user-friendly error message.
- What happens when the wallpaper URL is no longer valid (404)? The download should fail gracefully with an informative error, and the favorite should still retain the cached thumbnail.
- What happens when the user navigates to wallpaper detail from favorites for a wallpaper whose original category data is unavailable? The detail page should still function with the data stored in the favorite record.
- What happens during a download if the app is backgrounded or the network drops mid-transfer? The download should fail gracefully with an error message; partial files should be cleaned up.
- What happens when previewing a very large video file? The preview should load the video progressively and show a loading indicator until playback is ready.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST persist favorite wallpapers locally on the device using the wallpaper's ID, full URL, thumbnail URL, media type, and the timestamp of when it was favorited.
- **FR-002**: System MUST toggle the favorite icon state (active/inactive) immediately upon tap, reflecting the current persisted state.
- **FR-003**: System MUST correctly reflect the favorite status when a wallpaper is opened in detail view — whether navigated from the home grid, favorites screen, or downloads screen.
- **FR-004**: System MUST display all locally-saved favorites in a grid on the favorites screen, each showing the wallpaper thumbnail.
- **FR-005**: System MUST navigate from a favorites grid item tap to the wallpaper detail page, passing the full list of favorited wallpapers so the user can swipe between them, with the tapped item as the initial wallpaper and the favorite icon in the active state.
- **FR-006**: System MUST request device gallery/storage permission before attempting the first download, and guide the user to settings if permission is denied.
- **FR-007**: System MUST download the full-resolution image or video file from the wallpaper URL and save it to the device's photo gallery.
- **FR-008**: System MUST display a progress indicator during download and a success or error message upon completion.
- **FR-009**: System MUST record each successful download locally with the wallpaper's ID, URL, thumbnail URL, media type, and download timestamp.
- **FR-010**: System MUST display all download records in a grid on the downloads screen, sorted by most recent first.
- **FR-011**: System MUST navigate from a downloads grid item tap to the wallpaper detail page, passing the full list of downloaded wallpapers so the user can swipe between them, with the tapped item as the initial wallpaper.
- **FR-012**: System MUST display the selected wallpaper inside a phone wireframe on the preview screen when the user taps the preview button.
- **FR-013**: System MUST play video wallpapers inside the phone wireframe on the preview screen, simulating a live wallpaper experience.
- **FR-014**: System MUST allow the user to dismiss the preview screen and return to the wallpaper detail page, releasing any video playback resources.
- **FR-015**: System MUST show an appropriate empty state on both the favorites and downloads screens when no items exist.
- **FR-016**: System MUST handle network errors during download by displaying a user-friendly error message without crashing.

### Key Entities

- **Favorite Record**: Represents a wallpaper the user has marked as a favorite. Contains the wallpaper identifier, media URL, thumbnail URL, media type (image or video), and the date/time it was favorited. Linked to the wallpaper it references.
- **Download Record**: Represents a wallpaper the user has downloaded to their device. Contains the wallpaper identifier, media URL, thumbnail URL, media type, file title, and the date/time it was downloaded. Linked to the wallpaper it references.
- **Wallpaper**: The core content item. Has an identifier, full-resolution URL, thumbnail URL, media type (image or video), and optional classification metadata.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can favorite and unfavorite a wallpaper in under 1 second with immediate visual feedback on every tap.
- **SC-002**: 100% of favorited wallpapers appear on the favorites screen after favoriting, and 100% are removed after unfavoriting.
- **SC-003**: Tapping any item on the favorites screen opens the correct wallpaper in detail view with the favorite icon shown as active.
- **SC-004**: Image wallpapers download and save to the device gallery successfully in under 10 seconds on a standard mobile connection.
- **SC-005**: Video wallpapers download and save to the device gallery in a playable format.
- **SC-006**: 100% of successful downloads are recorded and visible on the downloads screen.
- **SC-007**: The phone frame preview displays the wallpaper within 2 seconds of tapping the preview button.
- **SC-008**: Video wallpapers play inside the phone frame preview without user-visible lag or buffering on a standard connection.
- **SC-009**: All error scenarios (network failure, permission denied, storage error) display a user-friendly message without app crashes.
- **SC-010**: Favorite and download states persist across app restarts — no data loss on cold start.

## Assumptions

- The app already has a wallpaper detail page with favorite, download, and preview action buttons wired up.
- Local storage (Hive) is already initialized and available for favorites and downloads boxes.
- The `gal` package is available for saving files to the device gallery.
- A phone frame asset image exists at `assets/images/phone_frame.png`.
- The `video_player` package is available for video playback in the preview.
- Gallery/storage permissions are handled via the `permission_handler` package.
- Favorites are local-first (saved on device) with optional server sync when authenticated — this spec focuses on the local-first behavior.
- Downloads screen shows locally-tracked download history, not files queried from the gallery.
