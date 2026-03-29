# Feature Specification: Home, Categories & Content Grids

**Feature Branch**: `003-home-categories-grids`
**Created**: 2026-03-22
**Status**: Draft
**Input**: User description: "from plan.md implement Phase 3 — Home, Categories & Content Grids"

## Clarifications

### Session 2026-03-22

- Q: How many videos should auto-play simultaneously in the grid? → A: Limit to 2-3 concurrent auto-plays; remaining visible video cells show a static thumbnail with a play icon overlay.
- Q: What is the bento grid layout pattern for classifications? → A: Repeating pattern — 1 large card (2-column span) followed by 2-3 small cards (1-column each), then repeat.
- Q: How do categories appear in the horizontal selector? → A: Text-only chips with label and selected highlight color (no thumbnails/icons).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Categories and Image Wallpapers (Priority: P1)

A user (guest or premium) opens the app and lands on the Home screen. The Home screen displays a horizontal, scrollable list of categories at the top. By default, the first category is selected. Below the category bar, a grid of wallpaper thumbnails appears for the selected category. The user taps a different category and the grid updates to show wallpapers from that category. The user scrolls down and more wallpapers load automatically (infinite scroll pagination). Tapping a wallpaper thumbnail navigates to the wallpaper detail screen.

**Why this priority**: The image wallpaper grid is the primary content experience — the core reason users download the app. Without browsable categories and a paginated image grid, the app has no content to show.

**Independent Test**: Launch app → verify categories load horizontally at the top → verify first category is auto-selected → verify image thumbnails load in a responsive grid → tap a different category → verify grid updates → scroll to bottom → verify more wallpapers load (pagination) → tap a thumbnail → verify navigation to detail screen.

**Acceptance Scenarios**:

1. **Given** a user on the Home screen, **When** categories load, **Then** a horizontal scrollable list of categories is displayed at the top with the first category selected by default.
2. **Given** a user on the Home screen with a category selected, **When** the content loads, **Then** wallpaper thumbnails are displayed in a responsive grid (2 columns on phone, 3 on large phone, 4 on tablet).
3. **Given** a user viewing image wallpapers, **When** they scroll to the bottom of the current page, **Then** the next page of wallpapers loads automatically without a full-screen loader.
4. **Given** a user viewing image wallpapers, **When** they tap a thumbnail, **Then** they are navigated to the wallpaper detail screen for that wallpaper.
5. **Given** a user on the Home screen, **When** they tap a different category, **Then** the grid resets and displays wallpapers from the newly selected category.
6. **Given** a guest user, **When** content loads, **Then** premium-only wallpapers are hidden from the grid entirely.
7. **Given** a premium user, **When** content loads, **Then** all wallpapers including premium items are visible.

---

### User Story 2 - Home Screen Layout with Drawer (Priority: P2)

The Home screen has a polished layout: an AppBar with the app logo/name on the left and a profile icon on the right, and a side drawer accessible via the hamburger menu icon. The drawer contains navigation links to key app sections: Home, Favorites, My Downloads, Get Premium, Settings, About, Rate App, Share App, and Send Feedback. The profile icon behavior (guest vs premium) is already implemented from Phase 2.

**Why this priority**: The drawer provides navigation to all major app sections. Without it, users cannot reach Favorites, Downloads, Settings, or premium features from the Home screen.

**Independent Test**: Open Home → verify AppBar has app name and profile icon → tap hamburger menu → verify drawer opens with all menu items → tap each menu item → verify navigation to the correct screen (or placeholder).

**Acceptance Scenarios**:

1. **Given** a user on the Home screen, **When** the page loads, **Then** the AppBar shows the app name/logo on the left and a profile icon on the right.
2. **Given** a user on the Home screen, **When** they tap the hamburger menu icon (or swipe from left), **Then** a navigation drawer opens.
3. **Given** a user with the drawer open, **When** they view the drawer contents, **Then** they see menu items for: Home, Favorites, My Downloads, Get Premium, Settings, About, Rate App, Share App, and Send Feedback.
4. **Given** a user with the drawer open, **When** they tap a menu item, **Then** the drawer closes and they are navigated to the corresponding screen.

---

### User Story 3 - Video Wallpaper Grid (Priority: P3)

When a user selects a category that contains video wallpapers, the grid switches to display video thumbnails. To conserve device resources, a maximum of 2-3 video cells auto-play muted looping previews simultaneously; remaining visible video cells show a static thumbnail with a play icon overlay. Videos pause when scrolled off-screen. Tapping a video thumbnail navigates to the wallpaper detail screen. Pagination works the same as image grids.

**Why this priority**: Video wallpapers are a key differentiator for the app. Showing looping video previews in the grid creates an engaging, premium browsing experience that sets the app apart from static wallpaper apps.

**Independent Test**: Select a video-type category → verify video thumbnails appear in the grid → verify visible videos auto-play muted loops → scroll a video off-screen → verify it pauses → scroll back → verify it resumes → tap a video → verify navigation to detail.

**Acceptance Scenarios**:

1. **Given** a user who selects a video-type category, **When** the content loads, **Then** the grid displays video thumbnail cells instead of static image thumbnails.
2. **Given** a video cell that is visible on screen, **When** it enters the viewport, **Then** it auto-plays a muted looping preview of the video.
3. **Given** a video cell that was playing, **When** the user scrolls it off-screen, **Then** it pauses playback to conserve resources.
4. **Given** a user viewing video wallpapers, **When** they tap a video cell, **Then** they are navigated to the wallpaper detail screen.
5. **Given** a user viewing video wallpapers, **When** they scroll to the bottom, **Then** the next page loads automatically (pagination).

---

### User Story 4 - Classification Bento Grid (Priority: P4)

When a user selects a category of type "classification," the grid switches to a bento-style layout with a repeating pattern: 1 large card spanning 2 columns followed by 2-3 small single-column cards, then repeating. Each card shows a thumbnail image with the classification name overlaid on a gradient. Tapping a classification card navigates to a Classification Detail screen that displays all wallpapers within that classification in a standard paginated grid.

**Why this priority**: Classifications provide thematic grouping (e.g., "Nature," "Abstract," "Dark") that helps users discover content by mood or theme. The bento layout visually distinguishes classifications from regular wallpaper grids.

**Independent Test**: Select a classification-type category → verify bento grid with mixed-size cards appears → verify each card shows thumbnail + name overlay with gradient → tap a card → verify Classification Detail page opens → verify wallpapers within that classification load in a paginated grid.

**Acceptance Scenarios**:

1. **Given** a user who selects a classification-type category, **When** the content loads, **Then** a bento-style grid of mixed-size cards is displayed.
2. **Given** a classification card, **When** it renders, **Then** it shows a thumbnail image with the classification name overlaid on a gradient at the bottom.
3. **Given** a user viewing classification cards, **When** they tap a card, **Then** they are navigated to the Classification Detail screen for that classification.
4. **Given** a user on the Classification Detail screen, **When** the page loads, **Then** wallpapers from that classification are shown in a standard paginated grid.
5. **Given** a user on the Classification Detail screen, **When** they scroll to the bottom, **Then** more wallpapers load (pagination).

---

### User Story 5 - Dynamic Content Switching (Priority: P5)

The grid area on the Home screen dynamically switches between three content types based on the selected category's type: image grid for image categories, video grid for video categories, and bento grid for classification categories. The transition between grid types is seamless — when the user taps a different category, the content area updates to the appropriate grid type.

**Why this priority**: This is the integration story that ties US1, US3, and US4 together. Without it, each grid type would exist in isolation.

**Independent Test**: Select an image category → verify image grid → select a video category → verify video grid appears → select a classification category → verify bento grid appears → switch back to image category → verify image grid returns.

**Acceptance Scenarios**:

1. **Given** a user on the Home screen, **When** they select a category of type "image", **Then** the content area shows an image thumbnail grid.
2. **Given** a user on the Home screen, **When** they select a category of type "video", **Then** the content area switches to a video preview grid.
3. **Given** a user on the Home screen, **When** they select a category of type "classification", **Then** the content area switches to a bento-style classification grid.
4. **Given** a user who switches from one category type to another, **When** the grid type changes, **Then** the previous content is cleared and new content loads with a loading indicator.

---

### Edge Cases

- What happens when the categories list is empty? → Show an empty state with a "No categories available" message and a retry button.
- What happens when a category has no wallpapers? → Show an empty state within the grid area: "No wallpapers in this category" with an illustration.
- What happens when pagination reaches the last page? → Stop loading more items, no additional loading indicator shown at the bottom.
- What happens on network failure while loading categories? → Show an error state with a retry button. If cached categories exist, show them with a subtle "offline" indicator.
- What happens on network failure while loading wallpapers? → Show an error state within the grid area with a retry button. If cached wallpapers exist for that category, show cached data.
- What happens when a video fails to load or play? → Show a static thumbnail fallback image with a play icon overlay.
- What happens when the user rapidly switches between categories? → Cancel any in-flight requests for the previous category before fetching new content.
- What happens on the Classification Detail screen when the network fails? → Same error/retry pattern as the main grid.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch and display a list of categories from the server on Home screen load.
- **FR-002**: Each category MUST have a type: image, video, or classification.
- **FR-003**: The Home screen MUST display a horizontal scrollable category selector at the top using text-only chips with a selected highlight color.
- **FR-004**: The first category MUST be auto-selected when the Home screen loads.
- **FR-005**: The content grid MUST update when the user selects a different category.
- **FR-006**: Image-type categories MUST display wallpapers in a responsive grid (2/3/4 columns based on screen width).
- **FR-007**: Video-type categories MUST display video wallpapers with muted, looping auto-play previews, limited to a maximum of 2-3 concurrent auto-plays; remaining visible cells MUST show a static thumbnail with a play icon overlay.
- **FR-008**: Video cells MUST pause when scrolled off-screen and resume when scrolled back on-screen (respecting the concurrent auto-play limit).
- **FR-009**: Classification-type categories MUST display a bento-style grid using a repeating pattern (1 large 2-column card + 2-3 small 1-column cards) with thumbnail + name overlay on gradient.
- **FR-010**: Tapping a wallpaper thumbnail (image or video) MUST navigate to the wallpaper detail screen.
- **FR-011**: Tapping a classification card MUST navigate to the Classification Detail screen.
- **FR-012**: The Classification Detail screen MUST display wallpapers from that classification in a paginated grid.
- **FR-013**: All grids MUST support infinite scroll pagination — loading the next page when the user scrolls near the bottom.
- **FR-014**: The Home screen MUST include a navigation drawer with menu items: Home, Favorites, My Downloads, Get Premium, Settings, About, Rate App, Share App, Send Feedback.
- **FR-015**: The Home screen AppBar MUST display the app name/logo and a profile icon.
- **FR-016**: Categories MUST be cached locally and served via stale-while-revalidate — show cached data immediately while fetching fresh data from the server.
- **FR-017**: Guest users MUST NOT see premium-only wallpapers in any grid (items are hidden, not locked or badged).
- **FR-018**: Premium users MUST see all wallpapers including premium items with no visual distinction.
- **FR-019**: When the user switches categories, any in-flight network request for the previous category MUST be cancelled.
- **FR-020**: All content screens MUST implement four-state pattern: loading, error (with retry), empty (with illustration), success.
- **FR-021**: The Classification Detail screen MUST show the classification name in the AppBar.
- **FR-022**: A banner ad placeholder area MUST be present at the bottom of the Home screen for free users (actual ad integration is Phase 5).

### Key Entities

- **Category**: Represents a content grouping. Key attributes: unique identifier, name, type (image/video/classification), thumbnail image, display order.
- **Wallpaper**: A single wallpaper item. Key attributes: unique identifier, image/video URL, thumbnail URL, is premium flag, category association, classification associations.
- **Classification**: A thematic grouping of wallpapers. Key attributes: unique identifier, name, thumbnail image, wallpaper count.

## Assumptions

- The server API provides endpoints for: fetching categories, fetching wallpapers by category (paginated), fetching classifications by category, and fetching wallpapers by classification (paginated).
- Category type (image/video/classification) is determined by the server and included in the category response.
- The premium flag on wallpapers (`is_premium`) is set by the server; the client filters display based on user subscription status.
- Video wallpapers have both a thumbnail URL (for fallback/loading) and a video URL (for the looping preview).
- Pagination uses page-based (page number + page size) approach with the server indicating whether more pages exist.
- The drawer menu items for Favorites, Downloads, Premium, Settings, and About navigate to placeholder screens until those features are implemented in later phases.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can browse at least 3 different categories and see content load within 2 seconds on a standard connection.
- **SC-002**: Switching between categories updates the grid content within 1 second (cached data shown instantly, fresh data updated in background).
- **SC-003**: Infinite scroll pagination loads the next page of content before the user reaches the absolute bottom of the list (pre-fetch threshold).
- **SC-004**: Video previews auto-play within 1 second of becoming visible and pause within 500ms of scrolling off-screen.
- **SC-005**: The app does not show any premium wallpapers to guest users across all grid types.
- **SC-006**: All content screens gracefully handle loading, error, empty, and success states without crashes or blank screens.
- **SC-007**: The navigation drawer provides access to all 9 menu sections from the Home screen.
- **SC-008**: Classification Detail screens load and display wallpapers with the same pagination behavior as the main grid.
- **SC-009**: Cached categories allow the Home screen to render meaningful content even when offline.
- **SC-010**: Users can tap any wallpaper or classification to navigate to its detail screen without delay.
