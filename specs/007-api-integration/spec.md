# Feature Specification: Real API Integration

**Feature Branch**: `007-api-integration`
**Created**: 2026-03-25
**Status**: Draft
**Input**: User description: "in @plan.md implement API Collection, API-1: App Data (Bootstrap), API-2: Category Content (Images & Videos), API-3: Classifications List and API Flow Summary integrate all apis in application to get real data and after integrate api in app make test to ensure this apis is work correctly without any errors or issues"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - App Bootstrap with Real Data (Priority: P1)

When a user opens the app for the first time (or after clearing cache), the app fetches live data from the backend. The category carousel displays real categories from the server, and the side drawer shows real app metadata (app name, about text, privacy policy, terms of use, share links, and contact email) — all sourced from the backend, not hardcoded values.

**Why this priority**: This is the foundation of all content in the app. Without live categories and app metadata, every other screen is empty or shows stale placeholder data. All other user stories depend on categories being loaded from the real API.

**Independent Test**: Can be tested by launching the app and verifying the category carousel shows server-returned categories, the drawer About / Privacy Policy / Terms pages display server-provided text, and the Share App action uses the server-provided store link.

**Acceptance Scenarios**:

1. **Given** the app is launched cold, **When** the bootstrap call completes successfully, **Then** the category carousel displays exactly the categories returned by the server in the correct display order.
2. **Given** the app is launched cold, **When** the bootstrap call completes, **Then** the drawer About page shows the server-returned `about` text instead of any hardcoded placeholder.
3. **Given** the app is launched cold, **When** the bootstrap call completes, **Then** Share App action uses the server-returned platform-specific share link (`androidShareLink` on Android, `iphoneShareLink` on iOS).
4. **Given** the app is launched cold, **When** the bootstrap call completes, **Then** the Send Feedback action uses the server-returned `contactEmail`.
5. **Given** the backend is unreachable, **When** the app is launched, **Then** the app shows a user-friendly error with a retry option and does not crash.
6. **Given** a previous bootstrap response is cached, **When** the app is launched and the network is unavailable, **Then** the app displays the cached categories and metadata without error.
7. **Given** categories have loaded successfully, **When** no user interaction has occurred, **Then** the first category (by display order) is already selected and its content grid is already loading.

---

### User Story 2 - Real Wallpaper & Video Content with Pagination (Priority: P2)

When a user taps an image or video category, the app fetches paginated wallpaper or video items from the backend and displays them in the appropriate grid. As the user scrolls to the bottom, the next page loads automatically. The user always sees live, up-to-date content from the server.

**Why this priority**: Content grids are the core value of the app. Without real paginated content, users cannot browse or interact with any wallpapers or videos.

**Independent Test**: Can be tested by tapping an IMAGES or VIDEOS category and verifying the grid populates with server-returned items, then scrolling to the bottom to confirm a second page loads.

**Acceptance Scenarios**:

1. **Given** a user taps an IMAGES category, **When** the content loads, **Then** the image grid shows server-returned wallpaper thumbnails with correct top-rated badges where applicable.
2. **Given** a user taps a VIDEOS category, **When** the content loads, **Then** the video grid shows server-returned video thumbnails.
3. **Given** the first page of a category is displayed, **When** the user scrolls to the bottom, **Then** the next page of items is fetched and appended to the grid without resetting scroll position.
4. **Given** the user is on the last page of a category, **When** the user scrolls to the bottom, **Then** no further network requests are made and a "no more items" indication is shown.
5. **Given** an IMAGE_CLASSIFICATION category is tapped and a classification is then selected, **When** the classification's wallpaper content loads, **Then** only wallpapers belonging to that classification are shown.
6. **Given** a network error occurs while loading content, **When** the error state is displayed, **Then** the user can tap retry to reload the same page.

---

### User Story 3 - Real Classifications Bento Grid (Priority: P3)

When a user taps an IMAGE_CLASSIFICATION category, the app fetches the list of classifications from the backend and displays them as a bento grid of cards. Each card shows the classification thumbnail, name, and item count. Tapping a card navigates to the filtered content grid for that classification.

**Why this priority**: Classification browsing enhances discovery for thematic categories. It depends on P1 (categories loaded) and the data model from P2, making it logically third.

**Independent Test**: Can be tested by tapping an IMAGE_CLASSIFICATION category and verifying the bento grid shows server-returned classification cards with correct names, thumbnails, and item counts.

**Acceptance Scenarios**:

1. **Given** a user taps an IMAGE_CLASSIFICATION category, **When** the classifications load, **Then** the bento grid displays server-returned classification cards with name, thumbnail, and item count.
2. **Given** classifications are displayed, **When** the user taps a classification card, **Then** the content grid loads showing only wallpapers filtered to that classification.
3. **Given** a classifications fetch fails, **When** the error state is shown, **Then** the user can retry without navigating away.

---

### User Story 4 - API Integration Test Coverage (Priority: P4)

The development team can verify all three API integrations are working correctly by running an automated test suite. Tests cover: successful responses, error responses (network errors, 4xx, 5xx), pagination boundary conditions, and correct data mapping from API response to app data models.

**Why this priority**: Tests validate correctness of the integration and prevent regressions. They are essential for confidence before production release but do not block the user-facing features.

**Independent Test**: Can be verified by running the test suite and confirming all tests pass with zero failures and zero errors.

**Acceptance Scenarios**:

1. **Given** a mock server returns a valid bootstrap response, **When** the bootstrap use case executes, **Then** the test passes confirming categories and app metadata are correctly parsed and mapped.
2. **Given** a mock server returns a valid paginated content response, **When** the content use case executes for page 1, **Then** the test confirms items and pagination fields are correctly mapped.
3. **Given** a mock server returns a 5xx error, **When** any API use case executes, **Then** the test confirms a server failure result is returned and no crash occurs.
4. **Given** the last page is reached (page == totalPages), **When** the load-more action is triggered, **Then** the test confirms no additional network call is made.
5. **Given** a valid classifications response, **When** the classifications use case executes, **Then** the test confirms all classification fields (id, name, thumbnailUrl, itemCount) are correctly mapped.

---

### Edge Cases

- What happens when the bootstrap response returns an empty categories array?
- What happens when a category has `imageCount` of zero?
- How does the app handle a `null` `classificationId` on a content item from a non-classification category?
- What happens if `totalPages` is 0 or 1 and the user tries to load more?
- How does the app recover if the bootstrap call succeeds but a subsequent category-content call fails?
- What happens when cached bootstrap data is present but the server returns updated categories (new category added, category removed)?
- How does the app handle very large `itemCount` values on classification cards (display truncation)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST fetch app metadata and category list from the backend on every cold start before presenting the Home screen.
- **FR-018**: Upon successful bootstrap, the app MUST automatically select the first category (by `displayOrder`) and immediately begin loading its content — no user tap required.
- **FR-002**: The category carousel MUST display categories in the order defined by the server's `displayOrder` field.
- **FR-003**: The drawer About, Privacy Policy, and Terms of Use pages MUST display text sourced from the backend bootstrap response, not hardcoded strings.
- **FR-004**: The Share App action MUST use the platform-appropriate share link returned by the bootstrap API (`androidShareLink` or `iphoneShareLink`).
- **FR-005**: The Send Feedback action MUST use the `contactEmail` value returned by the bootstrap API.
- **FR-006**: Selecting an IMAGES or VIDEOS category MUST load the first page of content items from the backend with a configurable page size (default: 20 items per page).
- **FR-007**: The content grid MUST support infinite scroll pagination — when the user reaches the bottom, the next page MUST be fetched and appended without resetting the scroll position.
- **FR-008**: The app MUST stop requesting additional pages once the last page has been reached (`page == totalPages`).
- **FR-009**: Selecting an IMAGE_CLASSIFICATION category MUST fetch and display the classifications list from the backend.
- **FR-010**: Tapping a classification card MUST load the content grid filtered to that specific classification using the `classificationId` query parameter.
- **FR-011**: The last successful bootstrap response MUST be cached locally so the app can display categories and metadata when the network is unavailable.
- **FR-012**: All API error states MUST present a user-readable message and a retry action on the relevant screen.
- **FR-013**: The app MUST NOT crash or enter an unrecoverable state due to any API error (network timeout, 4xx, 5xx).
- **FR-014**: An automated test suite MUST cover all three API response flows: bootstrap, category content (paginated), and classifications.
- **FR-015**: Tests MUST cover error response scenarios (server error, network unavailable) for all three APIs.
- **FR-016**: Tests MUST verify correct mapping of all fields from API response to the corresponding app data model.
- **FR-017**: All three API endpoints MUST be called without an authentication token — requests to these endpoints MUST NOT include an Authorization header.

### Key Entities

- **AppMetadata**: Represents live app configuration returned by the bootstrap API — includes display name, description, legal text (about, privacy policy, terms), platform-specific share links, and contact email. Replaces all previously hardcoded app strings.
- **Category**: A content grouping returned by the bootstrap API. Has a unique identifier, display name, content type (images / videos / image-classification), sort order, and item count.
- **WallpaperItem**: A single content item (image or video wallpaper) returned by the category content API. Has a unique identifier, full-resolution URL, thumbnail URL, media type, top-rated flag, optional classification association, and creation date.
- **Pagination**: Metadata attached to every content API response indicating current page, page size, total item count, and total number of pages. Drives the infinite scroll stop condition.
- **Classification**: A thematic grouping within an IMAGE_CLASSIFICATION category, returned by the classifications API. Has a unique identifier, display name, thumbnail image, and item count.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The app displays real, server-sourced categories in the carousel within 3 seconds of a cold start on a standard mobile network connection.
- **SC-002**: All three API flows (bootstrap, content, classifications) are covered by automated tests with 100% of tests passing before the feature is merged.
- **SC-003**: Zero app crashes occur during any API error condition (network unavailable, server error, empty response) as verified by test suite execution.
- **SC-004**: Infinite scroll pagination loads subsequent pages without visible scroll jank or position reset, as verified by manual testing on both Android and iOS.
- **SC-005**: The drawer About, Privacy Policy, and Terms pages show dynamically fetched text — verified by changing backend content and confirming the app reflects the update on next cold start.
- **SC-006**: On every launch with cached data, the category carousel renders instantly from cache before any network response arrives, then updates silently when the background fetch completes — verified by observing no blank/loading screen between launch and category display when cache is warm.
- **SC-007**: All previously hardcoded app metadata strings (about text, privacy policy, terms of use, share links, contact email) are replaced by API-sourced values — zero hardcoded copies remain in the codebase.

## Assumptions

- The backend API is available and returns the documented envelope format (`{ "success": bool, "data": {...}, "message": string }`) for all three endpoints.
- The `appId` required for all API routes is already configured in the app's environment configuration.
- Pagination default page size is 20 items per page, consistent with existing implementation.
- Bootstrap cache uses true stale-while-revalidate: cached data renders immediately on every launch, then a fresh fetch runs in the background and the UI updates when it completes. No TTL or manual pull-to-refresh required.
- Tests will use mock HTTP responses (not live network calls) to ensure determinism and isolation.
- The existing Retrofit + Dio networking infrastructure is used; no new HTTP client is introduced.
- The existing `AppConfig` class will be updated to source app metadata from the API rather than compile-time constants.
- All three APIs (bootstrap, content, classifications) are public endpoints — no authentication token is required. The existing auth interceptor MUST NOT attach a Bearer token to these requests.

## Clarifications

### Session 2026-03-25

- Q: Do these 3 APIs require an authenticated user session (Bearer token), or are they publicly accessible without a token? → A: All 3 APIs are public — no auth token required for any of them.
- Q: When cached bootstrap data exists, what is the refresh behavior on launch? → A: Show cached data immediately on every launch, then fetch fresh in the background and update the UI when it arrives (true stale-while-revalidate — always refreshes).
- Q: After categories load, when does the first category's content grid appear — automatically or on first user tap? → A: The first category is automatically selected and its content loads immediately after bootstrap completes — no tap required.
