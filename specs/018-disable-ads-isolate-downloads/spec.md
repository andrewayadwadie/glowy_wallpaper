# Feature Specification: Disable Ads (Traceable) & Isolate-Backed Downloads

**Feature Branch**: `018-disable-ads-isolate-downloads`  
**Created**: 2026-07-24  
**Status**: Draft  
**Input**: User description: "create new branch from main to this speckit then hash and comment all implementation of ads in whole project and put //TODO: comment to be able to trace changes and make download images don't depend on ads and make download process wich is heavy run on isolate"

## Clarifications

### Session 2026-07-24

- Q: What exact traceability marker tag must every disabled ad location carry? → A: `// TODO(ads-disabled-018): <reason>` — feature-numbered, Dart-idiomatic, lint-visible
- Q: How are the automated tests that assert ad behaviour handled? → A: Comment them out with the same marker (not deleted, not skipped), and rewrite the download tests to assert the no-ad path
- Q: What happens to an in-progress download when the user leaves the wallpaper screen? → A: It continues to completion and still saves to gallery and history; only the screen-bound messages are skipped
- Q: How is memory handled for large media downloads? → A: Stream to disk as bytes arrive — peak memory stays roughly constant and independent of file size; no size limit imposed
- Q: What happens to the premium offer while ads are paused, given its headline benefit is ad removal? → A: Hide the premium purchase entry point entirely for the duration of the pause

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Download starts instantly, no ad required (Priority: P1)

A person opens a wallpaper, taps Download, and the save begins immediately. No rewarded video plays, no waiting spinner for an ad to load, no chance of losing the download because an ad was dismissed or failed to fill.

**Why this priority**: The download is the core value of the app. Today it is gated behind a rewarded ad, so users can be blocked, delayed, or lose the action entirely when ad inventory is unavailable. Removing the gate directly restores the primary task.

**Independent Test**: Tap Download on any wallpaper (image and video) with ads unavailable/blocked. The file must save to the gallery with no ad shown and no ad-related delay.

**Acceptance Scenarios**:

1. **Given** a user viewing a wallpaper with an internet connection, **When** they tap Download, **Then** the download progress begins within one second and no ad appears.
2. **Given** a device where ad serving is completely unavailable, **When** the user taps Download, **Then** the download still completes successfully.
3. **Given** a download in progress, **When** it finishes, **Then** the user sees the existing success confirmation and the item appears in download history.
4. **Given** the user has no internet connection, **When** they tap Download, **Then** they see the existing "no connection" message and no ad-related state is entered.

---

### User Story 2 - Ad-free app throughout (Priority: P2)

Across every screen — splash, home, wallpaper detail, category switching, app resume — the user sees no banners, no full-screen interstitials, no app-open ads, and no consent/privacy ad prompt.

**Why this priority**: Once the download gate is gone, the remaining ad surfaces are the only ad interruptions left. Turning them all off delivers a single coherent experience and matches the request to disable ads project-wide.

**Independent Test**: Cold-start the app, browse home, switch categories repeatedly, open a wallpaper, background and resume the app. No ad surface appears at any point, and no ad consent dialog is shown on first run.

**Acceptance Scenarios**:

1. **Given** a fresh install, **When** the app launches for the first time, **Then** no ad consent/privacy form is presented.
2. **Given** the home screen, **When** it renders for a non-premium user, **Then** no banner occupies the bottom of the screen and the layout has no leftover empty band.
3. **Given** a user switching categories many times, **When** each switch happens, **Then** no interstitial appears.
4. **Given** the app is backgrounded and resumed, or the splash completes, **When** the app returns to the foreground, **Then** no app-open ad appears.
5. **Given** ads are disabled, **When** the app starts, **Then** startup is not delayed by ad initialization and no ad-related error can block launch.
6. **Given** ads are paused for everyone, **When** a non-subscribed user navigates the whole app, **Then** no premium purchase entry point is offered, and the screens where it used to appear show no gap or dead control.

---

### User Story 3 - Interface stays smooth while downloading (Priority: P2)

While a large wallpaper or video downloads and is written to the gallery, the app keeps scrolling, animating, and responding without freezing or dropping frames.

**Why this priority**: Downloading full-resolution media and writing it to storage is the heaviest work in the app. Users notice the stall, and it makes even a successful download feel broken.

**Independent Test**: Download the largest available video wallpaper on a mid-range device while scrolling the similar-wallpapers list. Scrolling stays fluid and the progress indicator keeps updating.

**Acceptance Scenarios**:

1. **Given** a large media download is in progress, **When** the user scrolls or taps other controls, **Then** the interface responds without visible freezing.
2. **Given** a download is in progress, **When** bytes arrive, **Then** the progress indicator updates continuously and reaches completion.
3. **Given** a download fails mid-transfer, **When** the failure occurs, **Then** the user sees the existing failure message and the app remains responsive and usable.
4. **Given** the user leaves the wallpaper screen mid-download, **When** they navigate away, **Then** the download runs to completion and the file still lands in the gallery and download history, with no crash and no stuck progress state.

---

### User Story 4 - Ad code is disabled but fully traceable and restorable (Priority: P3)

A maintainer can locate every place ads were switched off, understand why, and re-enable the whole ad system later without re-implementing it.

**Why this priority**: Ads are a revenue path that is being paused, not deleted. Without consistent markers the disable becomes irreversible in practice and dead code rots silently.

**Independent Test**: Search the project for the agreed marker text. Every disabled ad site is listed, each carries a short reason, and no ad behaviour remains active anywhere.

**Acceptance Scenarios**:

1. **Given** the change is complete, **When** a maintainer searches for the traceability marker, **Then** every disabled ad location is found, including app startup, all ad surfaces, dependency wiring, and the download flow.
2. **Given** ad code is disabled rather than deleted, **When** the project is built, **Then** it compiles and runs with no unused-code or missing-reference errors.
3. **Given** the automated test suite, **When** it runs, **Then** it passes: tests that assert ad behaviour are disabled with the same marker, and download tests assert the no-ad path.
4. **Given** a future decision to restore ads, **When** a maintainer follows the markers, **Then** re-enabling requires only reversing the marked edits.

---

### Edge Cases

- Premium/subscribed users: already ad-free, so the app looks the same to them; their entitlements and restore path keep working even though the purchase entry point is hidden.
- Non-premium user who previously saw the premium offer: the entry point is simply absent, with no broken link, empty screen, or layout gap left behind.
- Existing subscriber reinstalling or switching devices: restore-purchases still reachable and still grants their entitlement.
- Ad-serving failure at startup: with ads disabled there is no init step left that can delay or fail launch.
- Storage/photos permission denied or permanently denied: existing permission messaging and "open settings" path must still trigger, now reached without any ad step first.
- Offline or connection dropped mid-download: existing network failure message shown; no partial file left in the gallery.
- Very large video files on low-memory devices: the file is written out as it arrives rather than held whole in memory, so size does not drive memory use; the download must complete or fail cleanly with a message, never hang the interface.
- Storage full or write failure part-way through: the user sees a failure message, the partial file is removed, and no history entry is recorded.
- Rapid repeated taps on Download: only one download runs at a time.
- Backgrounding the app mid-download: download either completes or fails with a message; no stuck progress state on return.
- Leaving the wallpaper screen mid-download: the transfer keeps running and still saves; success and failure messages tied to that screen are simply not shown.
- Returning to a wallpaper whose download finished while the screen was closed: it shows as already downloaded, with no duplicate file or duplicate history entry.
- Store listing/policy: app is distributed without ad content while the pause is in effect.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The download action MUST complete without requiring the user to view, complete, or dismiss any ad.
- **FR-002**: No ad surface — banner, interstitial, app-open, or rewarded — MUST be displayed anywhere in the app.
- **FR-003**: The ad privacy/consent prompt MUST NOT be presented to users.
- **FR-004**: App startup MUST NOT wait on, or be able to fail because of, ad initialization.
- **FR-005**: Screen layouts that reserved space for an ad MUST reclaim that space with no empty gap or shifted content.
- **FR-006**: Heavy download work — transferring media bytes and writing the file to device storage — MUST run off the interface thread so the app remains responsive.
- **FR-007**: Download progress MUST continue to be reported to the user from first byte to completion while the work runs off the interface thread.
- **FR-008**: All existing download outcomes MUST be preserved: success confirmation, saved-to-gallery result, download history entry, permission-denied handling, network-failure handling, and analytics events for success and failure.
- **FR-009**: Ad implementation MUST be disabled by commenting it out, not by deleting it, so it can be restored.
- **FR-010**: Every disabled ad location MUST carry the marker `// TODO(ads-disabled-018): <reason>`, using that exact tag with no variation, followed by a one-line reason.
- **FR-011**: The disable MUST cover every ad location in the project: startup/initialization, consent handling, all ad managers, the ad widget, dependency registration, the shared ad flag, and each screen that triggers an ad.
- **FR-012**: The project MUST build and run cleanly with ads disabled — no unreachable references, no unused-import or dead-code failures.
- **FR-013**: The automated test suite MUST pass. Tests that exist solely to assert ad behaviour MUST be commented out in place and carry the same marker as the production code they cover — they are neither deleted nor left as skipped/pending tests.
- **FR-017**: Download tests MUST be rewritten to assert the ad-free path: a download succeeds with no ad step invoked, and no ad component participates in the download flow.
- **FR-014**: Premium/subscription logic — entitlement checks, subscription state, expiry/lapse handling, and restore-purchases — MUST remain fully working and unmodified. Only the user-facing purchase entry point is affected (FR-021).
- **FR-021**: The premium purchase entry point MUST be hidden from users for the duration of the ad pause, so nobody can buy a subscription whose headline benefit is currently inert. The hiding MUST be done with the same marker as the ad edits so it is reversed alongside them.
- **FR-022**: Users who already hold an active subscription MUST keep every entitlement they paid for, and the restore-purchases path MUST remain reachable so an existing subscriber on a new device can recover their entitlement.
- **FR-015**: Only one download MUST be able to run at a time; repeated taps during an active download are ignored.
- **FR-016**: When the download work fails or is interrupted, the app MUST surface the existing error message and leave no stuck progress state.
- **FR-018**: A download in progress MUST survive the user leaving the wallpaper screen: it runs to completion and still saves to the gallery and to download history. Messages bound to the closed screen are skipped rather than queued, and no duplicate file or history entry is created.
- **FR-019**: Media MUST be written out progressively as it arrives rather than held whole in memory, so peak memory during a download stays roughly constant regardless of file size. No maximum file size is imposed on downloads.
- **FR-020**: If writing fails part-way through (for example, storage full), the app MUST remove the partial file, show a failure message, and record no download history entry.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of download attempts on a working connection start saving within 1 second of the tap, with zero ads shown.
- **SC-002**: Zero ad surfaces appear in a full manual pass covering splash, home, 10 category switches, wallpaper detail, and 3 background/resume cycles.
- **SC-003**: The interface stays responsive during download of the largest available media file, with no freeze longer than 100 ms on a mid-range device.
- **SC-009**: Peak memory added during a download does not scale with file size: downloading the largest available video adds no more than a small fixed working buffer over the app's idle memory, and low-end devices complete it without an out-of-memory failure.
- **SC-004**: Download success rate is equal to or higher than before the change, measured on the same devices and network conditions.
- **SC-005**: Time from tap to saved file drops by at least the full duration previously spent on the ad gate (typically 5–30 seconds per download).
- **SC-006**: A single project-wide search for `ads-disabled-018` returns every disabled ad location — verified against the list of known ad locations with no misses.
- **SC-007**: The full automated test suite passes with zero failures after the change.
- **SC-008**: Restoring ads later requires no new implementation work — only reversing marked edits.
- **SC-010**: Zero reachable premium purchase entry points remain in a full navigation pass, while an existing subscriber still resolves as premium and restore-purchases still succeeds.

## Assumptions

- "Hash and comment" is read as: comment out the ad code in place and leave it in the codebase, rather than delete it.
- All ad formats are covered by "all implementation of ads": banner, interstitial, app-open, and rewarded.
- The ad SDK dependency and platform-level ad identifiers (Android manifest entry, iOS plist entry, ad unit id configuration) stay in place so the project keeps building and ads can be restored quickly; only their use is disabled.
- Some steps of saving to the gallery must talk to the operating system and cannot be moved off the interface thread; only the heavy transfer and file-write work is relocated. User-visible responsiveness is the acceptance bar, not a specific internal split.
- Isolate-backed downloading applies to both image and video wallpapers, since both go through the same download path.
- Premium/in-app-purchase logic is untouched; only the purchase entry point is hidden (see Clarifications), which means no new subscriptions are sold while the pause is in effect. This is an accepted revenue tradeoff for the duration of the pause.
- Analytics events unrelated to ads are preserved; ad-specific analytics events go away with the ad code.
- The traceability marker tag is fixed at `// TODO(ads-disabled-018):` (see Clarifications) and used identically everywhere so a single search finds all sites.

## Out of Scope

- Removing the ad SDK dependency, ad unit configuration, or platform ad identifiers.
- Changing pricing, premium entitlements, or the mechanics of the purchase and restore flow (only the visibility of the purchase entry point changes — FR-021).
- Redesigning the download UI, adding background/queued downloads, or adding a download-resume capability.
- Changing which wallpapers are downloadable or introducing any new gate in place of the ad gate.
