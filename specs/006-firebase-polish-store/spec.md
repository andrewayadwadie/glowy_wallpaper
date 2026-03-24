# Feature Specification: Firebase, Polish & Store Readiness

**Feature Branch**: `006-firebase-polish-store`
**Created**: 2026-03-25
**Status**: Draft
**Input**: User description: "implement Phase 6 — Firebase, Polish & Store Readiness from @plan.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Push Notification Delivery (Priority: P1)

A registered user receives push notifications from the app while it is in the foreground, background, or closed. Tapping a notification navigates them to the correct in-app screen.

**Why this priority**: Notifications are the primary re-engagement channel. Without working notifications, the app cannot drive users back to content.

**Independent Test**: Can be tested by sending a test notification to a device and verifying delivery and tap navigation work in all three app states (foreground, background, terminated).

**Acceptance Scenarios**:

1. **Given** the app is in the foreground, **When** a push notification arrives, **Then** an in-app banner is shown and the user can tap it to navigate to the linked screen.
2. **Given** the app is in the background, **When** a push notification arrives, **Then** the system notification tray shows the message; tapping it opens the app and navigates to the linked screen.
3. **Given** the app is closed (terminated), **When** the user taps a push notification in the notification tray, **Then** the app launches and navigates directly to the linked screen.
4. **Given** a notification with a deep link, **When** the user taps it, **Then** they land on the correct content screen (e.g., a specific wallpaper or category).

---

### User Story 2 - Side Menu Engagement Actions (Priority: P2)

A user can rate the app in their platform store, share the app with friends, send feedback to the support team, and read the About and Terms pages — all from the side navigation drawer.

**Why this priority**: These engagement and retention actions complete the product experience and are required for store submission compliance (privacy policy, terms of use).

**Independent Test**: Can be tested by opening the drawer and verifying each menu item launches the correct external action or in-app page.

**Acceptance Scenarios**:

1. **Given** the side menu is open, **When** the user taps "Rate App", **Then** the platform store page for the app opens in the store app.
2. **Given** the side menu is open, **When** the user taps "Share App", **Then** the system share sheet opens with a pre-filled share link.
3. **Given** the side menu is open, **When** the user taps "Send Feedback", **Then** the default email client opens pre-addressed to the support email.
4. **Given** the side menu is open, **When** the user taps "About", **Then** an in-app page shows app description content fetched at launch.
5. **Given** the side menu is open, **When** the user taps "Terms of Use" or "Privacy Policy", **Then** the respective in-app page shows the legal content fetched at launch.

---

### User Story 3 - Consistent Loading, Empty & Error States (Priority: P2)

Every screen in the app shows a shimmer skeleton while content loads, a meaningful empty state illustration when there is no content, and a retry-able error state when a network request fails.

**Why this priority**: Inconsistent or missing states degrade perceived quality and cause user confusion. Required for store approval and positive reviews.

**Independent Test**: Can be tested by throttling the network, blocking requests, or opening screens with empty datasets.

**Acceptance Scenarios**:

1. **Given** any content screen is loading, **When** the data has not yet arrived, **Then** a shimmer skeleton placeholder matching the content layout is visible.
2. **Given** a network request fails on any screen, **When** the error state is shown, **Then** the user sees a descriptive message and a "Retry" button that re-triggers the request.
3. **Given** a screen with no content (e.g., no favorites, no downloads), **When** the empty state is shown, **Then** an illustration with a helpful message is displayed.
4. **Given** a successful load follows a loading state, **When** data arrives, **Then** the shimmer is replaced smoothly by real content.

---

### User Story 4 - Responsive Layout & Visual Polish (Priority: P3)

The app looks great and functions correctly on phone and tablet screen sizes, including proper grid columns, constrained drawer width, correct aspect ratios, and respect for system text size settings.

**Why this priority**: Visual polish and responsiveness are required for store featuring and positive user reviews. Lower priority than functional completeness.

**Independent Test**: Can be tested by running the app on a tablet emulator and at large system font sizes.

**Acceptance Scenarios**:

1. **Given** the app runs on a tablet (screen width ≥ 600dp), **When** the home grid is displayed, **Then** it shows 3 or 4 columns (vs 2 on phone).
2. **Given** the app runs on a tablet, **When** the drawer is opened, **Then** the drawer width is constrained and does not stretch full-screen.
3. **Given** the user has set a large system font size, **When** any screen is displayed, **Then** text scales appropriately without overflowing or clipping.
4. **Given** any wallpaper thumbnail or card, **When** displayed in the grid, **Then** aspect ratios are consistent and images are not distorted.

---

### User Story 5 - App Icon, Splash & Store Listing Readiness (Priority: P3)

The app has a polished adaptive icon on Android and a standard icon on iOS. The native splash screen displays branding. Play Store and App Store listings have complete metadata, screenshots, and privacy policy.

**Why this priority**: Required for store submission. Icons and splash are visible at first launch; store metadata affects discoverability.

**Independent Test**: Can be tested by building a release APK/IPA and verifying icon display on the home screen, then running through the store submission checklist.

**Acceptance Scenarios**:

1. **Given** the app is installed on Android, **When** viewed on the home screen, **Then** the adaptive icon displays correctly with the foreground asset on any icon shape.
2. **Given** the app launches cold, **When** the splash screen is shown, **Then** the branded splash is displayed before the first screen loads.
3. **Given** the Play Store / App Store listing, **When** reviewed by a reviewer, **Then** app description, screenshots, privacy policy URL, and content rating are all present.

---

### Edge Cases

- What happens when a notification arrives but the user has revoked notification permissions?
- How does the app handle a deep link to a screen that requires authentication when the user is logged out? → Redirect to login; after successful login navigate to the original destination.
- What happens when the "Rate App" store URL cannot be opened (e.g., store app not installed on emulator)?
- How does an empty state behave when a favorites/downloads list transitions from having items to being empty after a delete?
- What if a notification payload references a wallpaper ID that no longer exists on the server?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST request notification permission from the user after their first download or favorite action (iOS mandatory dialog; Android 13+ rationale dialog), not on first app launch, to maximise grant rate.
- **FR-002**: System MUST deliver push notifications to users when the app is in foreground, background, or terminated states.
- **FR-003**: System MUST navigate to the correct in-app screen when a user taps a push notification containing a deep link payload. If the user is not logged in, the system MUST redirect them to the login screen first and, upon successful login, navigate automatically to the original deep link destination.
- **FR-004**: System MUST display an in-app notification banner when a push notification arrives while the app is in the foreground.
- **FR-005**: Side menu MUST include: Rate App, Share App, Send Feedback, About, Privacy Policy, and Terms of Use items.
- **FR-006**: "Rate App" MUST open the platform-specific store listing for the app (Play Store on Android, App Store on iOS).
- **FR-007**: "Share App" MUST trigger the native share sheet with the app's platform-specific share link sourced from app bootstrap data.
- **FR-008**: "Send Feedback" MUST open the device's default email client pre-addressed to the support email sourced from app bootstrap data.
- **FR-009**: About, Privacy Policy, and Terms of Use MUST display content sourced from the app bootstrap API response and cached locally for offline access.
- **FR-010**: All content screens MUST display a shimmer skeleton placeholder while data is loading.
- **FR-011**: All content screens MUST display an error state with a retry button when a network request fails.
- **FR-012**: All content screens MUST display an empty state with an illustration and message when no content is available.
- **FR-013**: The home wallpaper grid MUST display 2 columns on phones and 3–4 columns on tablets (screen width ≥ 600dp).
- **FR-014**: The navigation drawer MUST be width-constrained on tablets (maximum 320dp wide).
- **FR-015**: All text in the app MUST scale with the system font size setting without overflow or clipping on any primary screen.
- **FR-016**: The app MUST have an adaptive launcher icon (foreground + background layers) on Android and a standard icon on iOS.
- **FR-017**: The native splash screen MUST display the app's brand colors and logo before navigation begins.
- **FR-018**: Play Store and App Store listings MUST include: title, short description, full description, at least 3 screenshots per platform, content rating, and privacy policy URL.
- **FR-019**: The codebase MUST produce zero static analysis warnings and contain no debug print statements, TODO comments, or unused imports at release.

### Key Entities

- **Push Notification**: A message delivered by the platform notification service containing a title, body, and optional deep link payload pointing to a specific screen or content item.
- **Deep Link**: A structured payload in a notification that maps to a named app route and optional parameters (e.g., wallpaper ID, category ID).
- **Shimmer Skeleton**: A placeholder UI element that mimics the layout of content during loading, using an animated shimmer effect.
- **Empty State**: A full-area widget shown when a list or grid has zero items, displaying an illustration and a descriptive message.
- **Error State**: A full-area widget shown when a data fetch fails, displaying an error message and a button to retry the request.
- **Adaptive Icon**: An Android launcher icon with separate foreground and background layers, allowing the platform to apply shape masks.
- **Store Metadata**: The collection of text, images, and legal documents required to publish an app on the Play Store or App Store.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Push notifications are delivered within 5 seconds of being sent for 95% of cases across foreground, background, and terminated app states.
- **SC-002**: Tapping a notification deep link navigates to the correct screen in under 2 seconds for 100% of tested scenarios.
- **SC-003**: All 5 side menu actions (Rate, Share, Feedback, About, Terms) launch their respective destinations without errors on both Android and iOS.
- **SC-004**: All content screens show a shimmer placeholder before content loads; no screen shows a blank flash during any tested loading scenario.
- **SC-005**: Simulating a network failure on any content screen shows a retry button that successfully reloads content when tapped.
- **SC-006**: Running the app on a 10-inch tablet shows the home grid with at least 3 columns and the drawer at maximum 320dp width.
- **SC-007**: Running the app at 200% system font size shows no text overflow or clipping on any primary screen.
- **SC-008**: The release build displays an adaptive icon correctly on Android and a standard icon on iOS home screens.
- **SC-009**: The store submission checklist (title, description, 3+ screenshots, privacy policy, content rating) is complete for both platforms before submission.
- **SC-010**: `flutter analyze` reports zero issues and the codebase contains no debug print calls, TODO comments, or unused imports.

## Clarifications

### Session 2026-03-25

- Q: When a logged-out user taps a notification deep link to a protected screen, what happens after login? → A: Redirect to login first; after successful login, navigate automatically to the original deep link destination.
- Q: When should the notification permission dialog be shown? → A: After the user's first download or favorite action (not on first app launch).

## Assumptions

- The app's Firebase project is already created; platform configuration files (google-services.json, GoogleService-Info.plist) need to be added to the native project folders.
- App bootstrap API (API-1) already returns `about`, `privacyPolicy`, `termsOfUse`, `contactEmail`, `androidShareLink`, and `iphoneShareLink` fields — these are consumed by the side menu actions and in-app pages.
- Store developer accounts (Google Play Console, App Store Connect) are already set up; this spec covers metadata preparation, not account setup.
- Notification permission is requested after the user's first download or favorite action — not on first app launch — to maximise grant rate.
- Deep link routing is handled by the existing GoRouter setup; this phase adds notification-triggered navigation on top.
- Screenshot assets will be captured from a real device or emulator as part of this phase's deliverables.
- "Rate App" falls back gracefully (shows a toast or silently logs) if the store URL cannot be opened.
- The shimmer animation dependency is added as a new package compatible with the existing tech stack.
