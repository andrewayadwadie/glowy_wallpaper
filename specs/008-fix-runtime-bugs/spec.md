# Feature Specification: Fix Runtime Bugs

**Feature Branch**: `008-fix-runtime-bugs`
**Created**: 2026-03-26
**Status**: Draft
**Input**: User description: "Fix runtime bugs: setState error on category switch, classification network error, invalid navigation params, remove settings from drawer, drawer data from bootstrap API"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Smooth Category Switching (Priority: P1)

A user browses the home screen and taps different categories in the horizontal category carousel. The app switches content grids (images, videos, classifications) without any rendering errors, crashes, or visual glitches.

**Why this priority**: This is the most fundamental interaction — browsing categories is the core UX loop. A rendering crash here makes the app unusable.

**Independent Test**: Can be fully tested by rapidly switching between categories (including video categories) and confirming no errors appear in the console or on screen.

**Acceptance Scenarios**:

1. **Given** the user is on the home screen viewing an image category, **When** they tap a video category, **Then** the content switches smoothly to the video grid with no rendering errors.
2. **Given** the user is on the home screen viewing a video category, **When** they rapidly tap between multiple categories, **Then** no setState errors occur and the correct content displays for the last selected category.
3. **Given** the user is viewing a video grid with auto-playing videos, **When** they switch to a different category, **Then** the old video grid's visibility callbacks do not trigger state changes on a disposed widget.

---

### User Story 2 - Classification Category Displays Data (Priority: P1)

A user taps a category of type IMAGE_CLASSIFICATION in the carousel. The app fetches and displays a grid of classification cards (bento grid) instead of showing an internet connection error with a retry button.

**Why this priority**: Classification categories are a core content type — showing a network error for valid content is a critical functional failure.

**Independent Test**: Can be fully tested by tapping any IMAGE_CLASSIFICATION category and verifying a grid of classification cards appears.

**Acceptance Scenarios**:

1. **Given** the user is on the home screen with an active internet connection, **When** they tap a classification-type category, **Then** classification cards load and display in a bento grid layout.
2. **Given** the user has previously viewed classifications, **When** they navigate back and tap the same classification category, **Then** cached data displays immediately while fresh data loads in the background.

---

### User Story 3 - Wallpaper Detail Navigation Works (Priority: P1)

A user taps any wallpaper thumbnail in any grid (image grid, video grid, or classification detail grid). The app navigates to the wallpaper detail carousel page showing the tapped wallpaper, with swipe navigation through the rest of the items.

**Why this priority**: Viewing wallpaper details is the primary user action after browsing — broken navigation blocks downloads, favorites, and previews.

**Independent Test**: Can be fully tested by tapping a wallpaper in any grid type and confirming the detail page opens with the correct wallpaper displayed.

**Acceptance Scenarios**:

1. **Given** the user is viewing an image grid, **When** they tap a wallpaper thumbnail, **Then** the wallpaper detail page opens showing that wallpaper with swipe navigation through the category's wallpapers.
2. **Given** the user is on a classification detail page, **When** they tap a wallpaper, **Then** the detail page opens correctly (not an "Invalid navigation parameters" error).
3. **Given** the user is viewing a video grid, **When** they tap a video thumbnail, **Then** the detail page opens with the correct video wallpaper.

---

### User Story 4 - Drawer Shows API-Sourced Content (Priority: P2)

A user opens the side drawer and taps About, Privacy Policy, or Terms of Use. The app displays the actual content fetched from the bootstrap API rather than hardcoded placeholder text. Share App, Rate App, and Send Feedback also use the correct links and email from the API.

**Why this priority**: Displaying incorrect or placeholder legal/policy content is a compliance and user trust issue, but doesn't block core functionality.

**Independent Test**: Can be fully tested by opening each drawer menu item and comparing the displayed content to the API response data.

**Acceptance Scenarios**:

1. **Given** the app has loaded bootstrap data, **When** the user taps "About" in the drawer, **Then** the about content from the bootstrap API is displayed.
2. **Given** the app has loaded bootstrap data, **When** the user taps "Privacy Policy" or "Terms of Use", **Then** the respective content from the bootstrap API is displayed.
3. **Given** the app has loaded bootstrap data, **When** the user taps "Share App", **Then** the share dialog uses the platform-appropriate share link from the bootstrap API.
4. **Given** the app has loaded bootstrap data, **When** the user taps "Send Feedback", **Then** the email client opens with the contact email from the bootstrap API.
5. **Given** the app has loaded bootstrap data, **When** the user taps "Rate App", **Then** the app store opens using the appropriate link from the bootstrap API.

---

### User Story 5 - Settings Removed from Drawer (Priority: P3)

The user opens the side drawer. The Settings menu item is no longer present since there is no settings functionality implemented.

**Why this priority**: A non-functional menu item is a minor UX issue — removing it is a quick cleanup.

**Independent Test**: Can be fully tested by opening the drawer and confirming the Settings item is absent.

**Acceptance Scenarios**:

1. **Given** the user is on the home screen, **When** they open the drawer, **Then** no "Settings" menu item is displayed.

---

### Edge Cases

- What happens when the bootstrap API fails and drawer content is unavailable? The drawer should display graceful fallback text or the last cached content.
- What happens when the user switches categories while a video is loading? The video loading should be canceled and no stale callbacks should fire.
- What happens when wallpaper data is empty for a category? The navigation should still work correctly — passing an empty list should show an appropriate empty state, not crash.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST handle category switching without rendering errors, even when switching from a video grid category to another category type.
- **FR-002**: The app MUST properly cancel or ignore stale visibility callbacks from video grid widgets when the category changes.
- **FR-003**: Classification-type categories MUST successfully fetch and display classification data from the server.
- **FR-004**: Tapping any wallpaper item in any grid type MUST navigate to the wallpaper detail page with the correct wallpaper displayed and a list of wallpapers for swipe navigation.
- **FR-005**: The navigation to wallpaper detail MUST pass the expected data format (wallpaper list and initial index) from all grid types.
- **FR-006**: The drawer MUST NOT contain a "Settings" menu item.
- **FR-007**: The drawer's About page MUST display the `about` content from the bootstrap API response.
- **FR-008**: The drawer's Privacy Policy page MUST display the `privacyPolicy` content from the bootstrap API response.
- **FR-009**: The drawer's Terms of Use page MUST display the `termsOfUse` content from the bootstrap API response.
- **FR-010**: The Share App action MUST use the platform-appropriate share link (`androidShareLink` or `iphoneShareLink`) from the bootstrap API.
- **FR-011**: The Send Feedback action MUST use the `contactEmail` from the bootstrap API.
- **FR-012**: The Rate App action MUST use the platform-appropriate store link from the bootstrap API.

### Key Entities

- **AppMetadataEntity**: Contains app metadata from bootstrap API — name, about, privacyPolicy, termsOfUse, androidShareLink, iphoneShareLink, contactEmail. Used by the drawer for content pages and actions.
- **CategoryEntity**: Contains category info including type (IMAGES, VIDEOS, IMAGE_CLASSIFICATION) that determines which grid and data source to use.
- **WallpaperEntity**: The core content item navigated to from any grid; passed as a list with an index to the detail page.

## Assumptions

- The bootstrap API at `/api/v1/mobile/apps/{appId}` reliably returns all drawer-related fields (about, privacyPolicy, termsOfUse, share links, contactEmail).
- The classification endpoint uses the same authentication level as other category content endpoints.
- The wallpaper detail page's expected navigation format (Map with `wallpapers` list and `initialIndex`) is the correct standard that all navigation sources should conform to.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can switch between all category types (images, videos, classifications) without any rendering errors — 0 setState/build errors in console.
- **SC-002**: Classification categories display their classification cards within 3 seconds on a standard connection — no false network error screens.
- **SC-003**: 100% of wallpaper tap interactions from any grid type successfully navigate to the detail page with correct data.
- **SC-004**: All drawer content pages (About, Privacy Policy, Terms of Use) display content sourced from the bootstrap API, not hardcoded text.
- **SC-005**: The drawer contains no non-functional menu items — Settings is removed.
