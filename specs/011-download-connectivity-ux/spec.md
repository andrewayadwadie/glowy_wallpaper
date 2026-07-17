# Feature Specification: Improve Download Connectivity Check and UX

**Feature Branch**: `011-download-connectivity-ux`  
**Created**: 2026-04-02  
**Status**: Draft  
**Input**: User description: "change download logic to check internet connectivity and stability before proceeding; gracefully bypass ad gate on ad errors; use image_gallery_saver_plus for gallery saving; replace blocking circular indicator + black screen with non-intrusive progress UX"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Download Blocked When Offline (Priority: P1)

A user taps the download button while their device has no internet connection (airplane mode, dead zone, or very poor signal). The app immediately tells them it cannot proceed instead of silently failing or hanging.

**Why this priority**: Data integrity and user trust — showing a clear "unavailable" message is the minimum acceptable behavior when connectivity is absent. All other download improvements are irrelevant if the baseline connectivity guard is absent.

**Independent Test**: Can be tested by disabling device network, tapping download, and verifying a "Network unavailable" snackbar appears and no download attempt is made.

**Acceptance Scenarios**:

1. **Given** the device has no internet connection, **When** the user taps the download button, **Then** a snackbar is displayed immediately informing the user that the network is unavailable, and the download does not start.
2. **Given** the device has a connected but unstable/unusable connection (e.g., WiFi with no actual traffic possible), **When** the user taps download, **Then** the system treats this as "no usable internet" and shows the same unavailability message.
3. **Given** the device had no connection and the user taps download, **When** connectivity is restored and the user taps download again, **Then** the download proceeds normally.

---

### User Story 2 - Download Proceeds Despite Ad Gate Failure (Priority: P2)

A user taps download and the app attempts to show an interstitial or reward ad before proceeding. The ad fails to load or display (network ad error, fill rate miss, timeout). The user should not be blocked — the download continues automatically without the ad.

**Why this priority**: Ad gate failures must not become a barrier to core functionality. Blocking downloads on ad errors would frustrate users and generate negative reviews.

**Independent Test**: Can be tested by simulating an ad load failure and verifying the download proceeds to completion without user intervention.

**Acceptance Scenarios**:

1. **Given** the user has internet, **When** the ad gate encounters a loading or display error, **Then** the download proceeds automatically as if the ad had been shown successfully.
2. **Given** the user has internet, **When** the ad gate times out waiting for an ad, **Then** the download is not blocked and proceeds normally.
3. **Given** the user has internet and the ad loads and closes normally, **When** the ad is dismissed, **Then** the download proceeds as before.

---

### User Story 3 - Wallpaper Saved to Device Gallery (Priority: P2)

A user downloads a wallpaper and expects it to appear in their device photo gallery app, not just in the app's private storage.

**Why this priority**: Gallery visibility is the primary expectation users have when "downloading" an image on mobile. If the wallpaper is saved silently to private storage only, users cannot find or use it as a wallpaper.

**Independent Test**: Can be tested by completing a download and opening the device gallery app to confirm the wallpaper appears.

**Acceptance Scenarios**:

1. **Given** the user successfully downloads a wallpaper, **When** the download completes, **Then** the wallpaper file is accessible in the device's photo gallery.
2. **Given** gallery save permission is required, **When** the app does not have it, **Then** the app requests the permission before saving, and saves on grant.
3. **Given** gallery save permission is denied, **When** it is a first-time denial, **Then** the user is informed the image was not saved to the gallery. **Given** permission is permanently denied, **When** a download is attempted, **Then** a dialog is shown with an "Open Settings" button to guide the user to grant permission.

---

### User Story 4 - Non-Blocking Download Progress Indicator (Priority: P3)

A user taps download and expects to see meaningful progress feedback without the entire screen becoming unusable (no black overlay or full-screen blocking spinner).

**Why this priority**: A blocking overlay with a dark background creates a poor experience — users feel trapped and cannot cancel or navigate away. Non-blocking progress keeps the interface responsive and trustworthy.

**Independent Test**: Can be tested by tapping download and verifying the user can still interact with the wallpaper detail screen during the download, while progress is still communicated.

**Acceptance Scenarios**:

1. **Given** a download is in progress, **When** the user views the screen, **Then** the download button animates to show fill progress and a percentage, while the wallpaper and the rest of the screen remain fully interactive.
2. **Given** a download is in progress, **When** the download completes, **Then** the progress indicator is dismissed and a brief success confirmation is shown.
3. **Given** a download fails mid-way, **When** the failure is detected, **Then** the progress indicator is dismissed and an error message is shown without leaving a blocked or frozen UI.

---

### Edge Cases

- Connectivity lost mid-download: treated as a standard download failure — progress is dismissed and a non-blocking error message is shown (same path as FR-009). No automatic retry.
- How does the system handle a download button tap during an already-in-progress download (prevent duplicate)?
- Gallery permission permanently denied: a dialog is shown explaining the situation with an "Open Settings" button, so the user can manually grant the permission from device settings.
- What if the device storage is full when saving to gallery?
- What if the wallpaper URL is temporarily unreachable despite an internet connection being available?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST verify real internet reachability before initiating a download using a check that covers both connection presence and actual internet access (including captive portal detection). "Connected but not routable" is treated as no connection.
- **FR-002**: The system MUST display a "network unavailable" snackbar and abort the download when the pre-download connectivity check fails.
- **FR-003**: The system MUST allow the download to proceed normally when the ad gate component encounters any error or failure, without requiring user action.
- **FR-004**: The system MUST save the downloaded wallpaper to the device's public photo gallery so it is visible in the native gallery application.
- **FR-005**: The system MUST request gallery write permission before saving. If denied once, saving is skipped with a clear message. If permanently denied, a dialog MUST be shown with an "Open Settings" button directing the user to grant the permission manually.
- **FR-006**: The system MUST display download progress by animating the download button (fill + percentage), keeping the rest of the screen fully interactive and unobscured. The button reverts to its default state on completion or failure.
- **FR-007**: The system MUST prevent duplicate download attempts when a download is already in progress.
- **FR-008**: The system MUST show a success confirmation when the wallpaper is saved to the gallery.
- **FR-009**: The system MUST show an error message (non-blocking) when a download fails for any reason — including mid-transfer connectivity loss — describing the issue clearly. No automatic retry is attempted; the user must tap download again.
- **FR-010**: The system MUST log a success event when a wallpaper is saved to the gallery, and a failure event with a reason parameter (e.g., no_connectivity, gallery_permission_denied, download_error) when a download attempt does not complete successfully.

### Key Entities

- **Download Request**: Represents a user-initiated download action, including the target wallpaper, connectivity status at time of request, ad gate outcome, and progress state.
- **Connectivity Status**: The assessed quality of the device's internet connection at the time of a download attempt (usable / unusable).
- **Gallery Save Result**: The outcome of attempting to write the wallpaper file to the device photo gallery (success / permission denied / storage full / other error).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of download attempts on devices with no usable internet connection are blocked before any network request is made, and the user receives feedback within 1 second.
- **SC-002**: 100% of download attempts where the ad gate encounters an error still result in a completed download (no user-visible blockage from ad failures).
- **SC-003**: Downloaded wallpapers appear in the device photo gallery within 3 seconds of the download completing.
- **SC-004**: During an active download, the user can still scroll, tap, or navigate on the wallpaper detail screen without UI freeze or unresponsiveness.
- **SC-005**: Zero occurrences of the full-screen black overlay / centered spinner being shown during the download flow after this change is shipped.
- **SC-006**: Users can identify download status (in-progress, complete, failed) at a glance without the interface being blocked.

## Clarifications

### Session 2026-04-02

- Q: What happens when internet connectivity is lost mid-download? → A: Treat as download failure — dismiss progress, show non-blocking error message. No automatic retry.
- Q: Which non-blocking progress UI pattern should replace the full-screen spinner? → A: Animate the download button — it shows a fill or percentage while downloading, reverts on completion.
- Q: How should the pre-download connectivity check assess real internet reachability? → A: Use a reachability-aware package that checks both connection presence and DNS/internet probe — handles captive portals and dead connections.
- Q: When gallery write permission is permanently denied, what should the app do? → A: Show a dialog explaining the situation with an "Open Settings" button so the user can grant permission manually.
- Q: Should download failure events be tracked in analytics alongside the existing success event? → A: Yes — log both success and failure events, with failure reason as a parameter.

## Assumptions

- The existing download flow in the app already includes an ad gate step (`adGatePlaceholder`) that returns a result indicating success or failure; this feature extends the gate to treat error responses as "proceed anyway."
- Gallery permission handling already exists in the app for a prior feature (permission_handler is listed as an active dependency); this feature reuses that pattern.
- The connectivity check uses a reachability-aware package that probes both connection presence and actual internet access (DNS lookup or equivalent), correctly handling captive portals and dead connections.
- The non-blocking progress UI replaces the existing full-screen circular indicator using an animated download button that shows fill progress and percentage.
- Downloads that lose connectivity mid-transfer will surface as a download error and follow the existing error handling path (FR-009), not the pre-check path (FR-002).
