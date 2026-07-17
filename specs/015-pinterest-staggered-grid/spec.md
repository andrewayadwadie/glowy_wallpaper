# Feature Specification: Pinterest-Style Staggered Grid

**Feature Branch**: `015-pinterest-staggered-grid`  
**Created**: 2026-04-09  
**Status**: Draft  
**Input**: User description: "استخدم flutter_staggered_grid_view: ^0.7.0 عشان تعمل الgridview اللى فى الابليكيشن كله بطريقة Pinterest"

## Clarifications

### Session 2026-04-09

- Q: Where does the wallpaper aspect ratio come from? → A: Ratio is decoded from the image after it downloads — layout reflows once known (Option B)
- Q: How should the card height transition from placeholder to decoded height? → A: Animate the height change (smooth resize + fade-in) — hides the reflow visually (Option A)
- Q: What does the card look like while the image is still loading (before decode)? → A: Shimmer skeleton at 3:4 fallback height — consistent with app-wide loading pattern (Option A)
- Q: Should the grid column count change in landscape orientation? → A: Stay at 2 columns in landscape — consistent with spec scope, no additional layout path (Option B)
- Q: Should wallpaper cards show a title/label overlay or be image-only? → A: Image-only — no text on the card, same as current behavior (Option B)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Wallpapers in Staggered Layout (Priority: P1)

A user opens any wallpaper grid screen (Home browse, Category Detail, Classification Detail) and sees wallpapers displayed in a Pinterest-style masonry layout — each card initially renders at a placeholder height, then reflowsto its correct proportional height once the image is decoded, so tall images appear taller and wide images appear shorter.

**Why this priority**: This is the core visual change and the most-visited surface in the app. It immediately improves perceived content quality and browsing engagement.

**Independent Test**: Launch the app, navigate to any wallpaper grid, and verify items have variable heights arranged in two staggered columns after images load.

**Acceptance Scenarios**:

1. **Given** a wallpaper grid is loaded with items of different aspect ratios, **When** the images finish loading, **Then** items are displayed in two columns with heights that vary per item based on the decoded aspect ratio.
2. **Given** an image is still loading, **When** the user views that card, **Then** the card displays at the fallback 3:4 placeholder height and smoothly transitions to the correct height once decoded.
3. **Given** a wallpaper has a portrait aspect ratio, **When** it appears in the grid after decoding, **Then** its card is visibly taller than a landscape-aspect-ratio card in the same grid.

---

### User Story 2 - Favorites & Downloads Staggered Grids (Priority: P2)

A user visits their Favorites or Downloads page and finds the same Pinterest-style staggered layout, giving their saved collection a visually consistent and engaging appearance matching the rest of the app.

**Why this priority**: Consistency across all grid screens matters for a polished UX. Favorites and Downloads are high-intent screens where users spend deliberate time.

**Independent Test**: Save several wallpapers with mixed aspect ratios, open the Favorites page, and confirm the staggered layout is applied after images decode.

**Acceptance Scenarios**:

1. **Given** the Favorites page contains saved wallpapers, **When** the images decode, **Then** items are displayed in a staggered two-column layout with variable heights.
2. **Given** the Downloads page contains downloaded wallpapers, **When** the user views it, **Then** the same staggered layout is used.
3. **Given** the Favorites or Downloads page is empty, **When** the user views it, **Then** the empty-state placeholder is displayed correctly without layout breakage.

---

### User Story 3 - Similar Wallpapers Sheet Staggered Layout (Priority: P3)

When a user opens a wallpaper detail screen and views the "Similar Wallpapers" section, the suggestions appear in the same Pinterest-style staggered layout for visual consistency.

**Why this priority**: This surface is secondary but visible. A consistent layout language across all grid surfaces avoids a fragmented feel.

**Independent Test**: Open any wallpaper detail, scroll to the Similar Wallpapers section, and verify the staggered layout is present after decode.

**Acceptance Scenarios**:

1. **Given** the Similar Wallpapers section is visible with results, **When** images decode, **Then** items appear in staggered columns with variable heights.
2. **Given** no similar wallpapers are found, **When** the section displays its empty state, **Then** the layout renders correctly without errors.

---

### Edge Cases

- What happens when a wallpaper has no decoded aspect ratio (image fails to load)? The card remains at the fallback 3:4 portrait ratio permanently.
- What happens when a grid contains only 1 item? The item occupies one column; the second column is empty.
- What happens when all items have identical aspect ratios? The grid appears as a uniform two-column layout — still valid staggered behavior.
- What happens on very small screens (under 320dp wide)? Columns remain usable; items do not overflow their bounds.
- How does the layout handle video wallpapers alongside image wallpapers? Video items render with a play indicator overlay; staggered height logic applies equally to both (decoded from video thumbnail).
- What happens when a card reflows its height after decode while the user is actively scrolling? The reflow must not cause a visible jump that disrupts the scroll position.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All wallpaper grid surfaces in the app MUST display items in a two-column Pinterest-style staggered (masonry) layout where each item's height is proportional to the wallpaper's natural aspect ratio. Cards are image-only — no title or text overlay is shown.
- **FR-002**: The staggered grid MUST be applied consistently to: the main wallpaper browse grid, category detail grid, classification detail grid, favorites grid, downloads grid, and similar wallpapers section.
- **FR-003**: Each grid item MUST preserve the wallpaper's correct aspect ratio — no cropping or squishing of content to fit a uniform cell height.
- **FR-004**: Before a wallpaper's aspect ratio is decoded, its card MUST display a shimmer skeleton at the fallback 3:4 portrait height, consistent with the app-wide loading pattern; once the image is decoded the card MUST animate smoothly (resize + fade-in) to the correct height so the transition feels intentional rather than a layout error.
- **FR-005**: The staggered layout MUST support lazy loading and pagination — new items append to the correct column without reflowing already-rendered items.
- **FR-006**: Tapping any item in the staggered grid MUST navigate to the wallpaper detail screen, identical to current behavior.
- **FR-007**: Video wallpapers in the staggered grid MUST display their thumbnail or preview with a visible play indicator; aspect ratio rules apply equally.
- **FR-008**: The staggered grid MUST handle empty states gracefully — when no items are present, the appropriate empty-state widget is shown in place of the grid.
- **FR-009**: The core shared grid widget MUST be updated so all consuming screens automatically inherit the staggered behavior, minimising duplicated layout logic.
- **FR-010**: The staggered layout MUST remain performant during fast scrolling — items outside the viewport MUST be efficiently recycled.

### Key Entities

- **WallpaperCard**: A single grid item representing one wallpaper; carries the image/video content, decoded aspect ratio (or fallback 3:4), and tap-navigation behaviour.
- **StaggeredGrid**: The layout container responsible for distributing WallpaperCards into two staggered columns based on each card's decoded or fallback aspect ratio.
- **GridSurface**: Any screen or widget in the app that hosts a StaggeredGrid — includes Home Browse, Category Detail, Classification Detail, Favorites, Downloads, and Similar Wallpapers.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 6 identified GridSurfaces in the app display a staggered two-column layout with variable item heights — 100% coverage, verifiable by manual walkthrough of each screen.
- **SC-002**: No wallpaper image is cropped or distorted within its grid card — each card's displayed height matches the decoded aspect ratio within a 5% tolerance after loading completes.
- **SC-003**: Scrolling through a grid of 50+ items produces no visible frame drops or layout jumps on a mid-range Android device.
- **SC-004**: Tapping a grid item navigates to the detail screen with no regression in responsiveness compared to before this change.
- **SC-005**: Empty-state widgets render correctly on all 6 GridSurfaces when no items are present, with zero layout overflow errors.
- **SC-006**: Cards that transition from placeholder height to decoded height do so with a smooth animated resize — the height change completes within 300ms and does not shift the user's current scroll position by more than 2dp.

## Assumptions

- Wallpaper API data does not include pre-computed width/height metadata; aspect ratio is determined by decoding each image on-device after download.
- Until decode completes, a fallback aspect ratio of 3:4 (portrait) is used for all cards.
- The number of columns is fixed at 2 regardless of orientation (portrait or landscape) and device type; tablet or multi-column support is explicitly out of scope for this feature.
- The spacing between grid items remains consistent with the current app design; gutter and padding values are not changed.
- The `classification_bento_grid.dart` bento-style category layout is decorative/navigational (not a wallpaper browser) and is explicitly out of scope — it retains its current design.
- The video grid uses the same staggered container as the image grid; video-specific rendering (player, thumbnail overlay) is unchanged by this feature.
