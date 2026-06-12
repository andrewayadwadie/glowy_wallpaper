# Feature Specification: AdMob Ads Integration

**Feature Branch**: `016-admob-ads-integration`  
**Created**: 2026-06-10  
**Status**: Draft  
**Input**: User description: "Implement Google AdMob ads in the Glowy wallpapers app — a rewarded ad gating image downloads (with graceful degradation on network failure), an app-open ad after the splash screen, a bottom banner on the Home page, and an interstitial on category navigation — organized as a cross-cutting ads layer with per-format managers, flavor/platform-resolved ad unit IDs, and consistent logging."

## Overview

Glowy is a free, ad-supported wallpapers app with an optional ad-free premium tier. This feature consolidates and standardizes the app's monetization surfaces into four clearly-defined ad placements, each with predictable user-facing behavior. The guiding principle is **revenue without friction**: ads must never trap, block, or frustrate a user, and a network failure must never prevent someone from completing the action they intended (most critically, downloading a wallpaper).

## Clarifications

### Session 2026-06-10

- Q: Interstitial frequency cap + cooldown — persist across app restarts? → A: In-memory, per session (counter + cooldown reset on each app launch; no persistence).
- Q: App-open ad — also show on foreground resume, or post-splash only? → A: Post-splash AND on foreground resume, with a frequency cap (≥ 4 min between app-open shows) and the no-stacked-ads guard.
- Q: Rewarded download — cold-start wait when no ad is ready yet? → A: Show a brief loading indicator for up to ~5 seconds; if no ad readies, on network failure proceed with the download.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reward-gated wallpaper download that never traps the user (Priority: P1)

A user browsing wallpapers taps **Download** on an image they like. A short rewarded ad plays; when it completes, the wallpaper download proceeds automatically and saves to their device. If the user has no connection or the ad cannot be served, the download still proceeds without the user being blocked or shown an error about the ad.

**Why this priority**: Downloading is the core value of the app and the primary monetization moment. If this placement blocks or fails the user's main task, it damages both retention and store rating. It must work flawlessly before any other placement matters.

**Independent Test**: Tap Download with a normal connection (ad shows, download proceeds after reward); tap Download in airplane mode / with ads unavailable (download proceeds immediately, no ad-related error). Both verified independently of the other three placements.

**Acceptance Scenarios**:

1. **Given** a wallpaper detail/grid with a ready rewarded ad, **When** the user taps Download and watches the ad to completion, **Then** the reward is granted and the wallpaper download begins automatically.
2. **Given** the device is offline or the ad fails to load/serve due to a network problem, **When** the user taps Download, **Then** the download proceeds as if the reward had been earned, with no blocking ad error shown.
3. **Given** the user taps Download immediately on a cold start before any ad has finished loading, **When** a brief loading indicator is shown for up to ~5 seconds and no ad becomes ready, **Then** the user is not left waiting longer than that; on a network-related failure the download proceeds.
4. **Given** a rewarded ad is showing, **When** the user dismisses it early (closes it) for a non-network reason before earning the reward, **Then** the reward is NOT granted and the download does not proceed.
5. **Given** a rewarded ad has just been shown, **When** the show completes (any outcome), **Then** a fresh rewarded ad begins preloading so the next Download tap has an ad ready.
6. **Given** the user holds an active ad-free premium entitlement, **When** they tap Download, **Then** no rewarded ad is shown and the download proceeds directly.

---

### User Story 2 - App-open ad on launch after splash (Priority: P2)

When the user opens the app, the splash screen finishes and — if an app-open ad is ready — a full-screen ad is shown once before the user lands on the Home screen. If no ad is ready, the user proceeds straight to Home with no delay. Additionally, when the user returns to the app from the background, an app-open ad may be shown, subject to a frequency cap so returning users are not over-served.

**Why this priority**: High-value impression at a natural transition point, but strictly secondary to download because it must never delay or block app entry.

**Independent Test**: Launch the app with an ad preloaded (ad shows once, then Home appears); launch with no ad ready (Home appears immediately, no wait). Verified without the other placements.

**Acceptance Scenarios**:

1. **Given** an app-open ad is loaded and fresh when the splash completes, **When** the splash finishes, **Then** the ad is shown once and, on dismissal, the user lands on Home.
2. **Given** no app-open ad is ready (or it is stale) when the splash completes, **When** the splash finishes, **Then** the user proceeds directly to Home and a fresh ad loads in the background for next time.
3. **Given** a loaded app-open ad has aged beyond its validity window (~4 hours), **When** the app attempts to show it, **Then** the stale ad is discarded and not shown, and a fresh one is requested.
4. **Given** another full-screen ad is already showing, **When** an app-open show is triggered, **Then** the app-open ad is not shown (no stacked full-screen ads).
5. **Given** an app-open ad is dismissed or fails to show, **When** the event occurs, **Then** a fresh app-open ad is requested.
6. **Given** the user holds an active ad-free premium entitlement, **When** the app opens or resumes, **Then** no app-open ad is shown.
7. **Given** the app returns to the foreground from the background and a fresh app-open ad is ready and the resume frequency cap (≥ 4 min since the last app-open show) is satisfied, **When** the app resumes, **Then** the app-open ad is shown once.
8. **Given** the resume frequency cap has not elapsed since the last app-open show, **When** the app resumes, **Then** no app-open ad is shown.

---

### User Story 3 - Bottom banner on the Home page (Priority: P2)

While browsing the Home page, the user sees a banner ad pinned to the bottom of the screen in a dedicated slot. The banner is sized to the device width and never covers or pushes the wallpaper grid in a jarring way. If the banner fails to load, the slot collapses cleanly with no empty grey box.

**Why this priority**: Steady passive impressions during the highest-traffic screen, but lower urgency than download because it is non-interruptive.

**Independent Test**: Open Home with banner serving (banner appears at bottom, grid scrolls above it unobstructed); simulate banner load failure (slot collapses, grid uses full height). Verified independently.

**Acceptance Scenarios**:

1. **Given** the Home page is displayed and a banner serves, **When** the page renders, **Then** an adaptive banner sized to the device width appears pinned at the bottom in a reserved slot that does not overlap the wallpaper grid.
2. **Given** the banner fails to load, **When** the failure occurs, **Then** the bottom slot collapses/hides gracefully (no empty placeholder box) and the grid uses the freed space.
3. **Given** the user navigates away from Home, **When** the Home banner is no longer needed, **Then** the banner resources are released.
4. **Given** the user holds an active ad-free premium entitlement, **When** Home is displayed, **Then** no banner slot is shown.

---

### User Story 4 - Interstitial on category navigation, frequency-capped (Priority: P3)

As the user switches between categories in the Home category selector, occasionally (not on every switch) a full-screen interstitial ad appears between selections. The ad never blocks the navigation itself, and respects a frequency cap and cooldown so it does not feel spammy.

**Why this priority**: Incremental revenue from an engaged browsing action, but the most intrusive placement, so it is lowest priority and most heavily rate-limited.

**Independent Test**: Switch categories repeatedly and confirm an interstitial appears at most once per configured number of switches and not more often than the cooldown allows; confirm category content always loads regardless of whether an ad shows.

**Acceptance Scenarios**:

1. **Given** the user has changed categories enough times to meet the frequency cap and the cooldown has elapsed, **When** they switch category again and an interstitial is loaded, **Then** the interstitial is shown and the newly selected category loads after dismissal.
2. **Given** the frequency cap or the minimum cooldown has not yet been met, **When** the user switches category, **Then** no interstitial is shown and the category switch proceeds silently.
3. **Given** no interstitial is loaded when the trigger fires, **When** the user switches category, **Then** the switch proceeds without delay and a fresh interstitial preloads for later.
4. **Given** an interstitial has just been shown, **When** it is dismissed, **Then** a fresh interstitial begins preloading.
5. **Given** the user holds an active ad-free premium entitlement, **When** they switch categories, **Then** no interstitial is ever shown.

---

### Edge Cases

- **Offline at every placement**: Download proceeds (graceful degradation, P1). App-open, banner, and interstitial silently no-show; none surface an error to the user.
- **Rapid repeated Download taps**: Only one rewarded flow runs at a time; the reward/download is granted exactly once per intended download, never duplicated.
- **Rapid category switching**: Frequency cap + cooldown prevent more than the allowed number of interstitials; switching remains smooth.
- **App backgrounded during an ad**: Ad lifecycle is handled cleanly; returning to the app does not leave a stuck full-screen ad or a blocked screen.
- **Premium status changes mid-session** (purchase or expiry): Ad behavior reflects the current entitlement at the next placement trigger.
- **Ad shown while another full-screen ad is active**: New full-screen show is suppressed to avoid stacked ads.
- **Stale app-open ad** (older than ~4 hours): Discarded rather than shown.
- **Rapid background/foreground toggling**: The ≥ 4-min resume cap prevents an app-open ad on every resume; only the first eligible resume after the cap elapses shows one.
- **Banner load failure**: Slot collapses; no grey box, no layout jump that hides content.
- **Consent in a regulated region**: First launch shows the consent prompt once; the user's choice is honored on later launches and governs whether personalized vs non-personalized ads are served.
- **Consent unavailable / non-regulated region**: No prompt is forced; the app proceeds and serves ads at the personalization level the absent/limited consent allows.

## Requirements *(mandatory)*

### Functional Requirements

#### Rewarded download gate (P1)

- **FR-001**: The system MUST present a rewarded ad when the user initiates a wallpaper download, and grant the reward (proceed with the download) only when the user earns the reward by completing the ad — except as overridden by FR-002 and FR-018.
- **FR-002**: The system MUST allow the download to proceed (grant the reward) when the ad fails to load or fails to show due to a network-related problem, so the user is never blocked by a connectivity failure.
- **FR-003**: The system MUST NOT make the user wait indefinitely when no ad is ready at the moment of the Download tap. It MUST show a brief loading indicator for up to ~5 seconds; if no ad becomes ready within that window, a network-related failure MUST fall through to completing the download. The ~5-second value is a tunable default.
- **FR-004**: The system MUST NOT grant the reward (MUST NOT download) when the user dismisses the ad early for a non-network reason before earning the reward.
- **FR-005**: The system MUST preload a rewarded ad ahead of need and reload a fresh one after every show, so an ad is typically ready for the next download.
- **FR-006**: The download flow MUST use a single, well-defined rewarded ad placement; any prior/duplicate rewarded wiring for downloads MUST be removed so only this placement remains.

#### App-open ad (P2)

- **FR-007**: The system MUST show an app-open ad once after the splash screen completes, only if a fresh ad is ready, and otherwise proceed immediately to Home.
- **FR-008**: The system MUST discard and not show an app-open ad that has aged beyond its validity window (~4 hours), and request a fresh one instead.
- **FR-009**: The system MUST NOT show an app-open ad (or any full-screen ad) while another full-screen ad is already showing.
- **FR-010**: The system MUST request a fresh app-open ad after each dismissal or failure.
- **FR-010a**: The system MUST also show an app-open ad when the app returns to the foreground from the background, subject to a frequency cap (default ≥ 4 minutes since the last app-open show, held in memory per session) and all guards in FR-008/FR-009 (freshness, no stacked full-screen ads). When the cap is not met, the resume show MUST be skipped silently. The very first foreground entry on cold start is handled by the post-splash show (FR-007), not the resume show.

#### Home banner (P2)

- **FR-011**: The system MUST display a bottom-anchored banner on the Home page, sized to the available device width (an adaptive banner, not a fixed legacy size), in a reserved slot that does not overlap or obscure the wallpaper grid.
- **FR-012**: The system MUST collapse/hide the banner slot gracefully on load failure, leaving no empty placeholder, and MAY retry the load once.
- **FR-013**: The system MUST release banner resources when the Home banner is no longer displayed.

#### Category interstitial (P3)

- **FR-014**: The system MUST show an interstitial in response to category-selection changes on the Home page, never blocking the navigation itself.
- **FR-015**: The system MUST enforce a frequency cap (show at most once per N category switches, default N configurable in the 3–4 range) AND a minimum cooldown (default ≥ 60 seconds) between interstitials; when either condition is unmet, the show MUST be skipped silently. The cap counter and cooldown timestamp are held in memory per app session and reset on each app launch (not persisted across restarts).
- **FR-016**: The system MUST skip the interstitial silently when none is loaded at trigger time, and preload a fresh one for later.
- **FR-017**: The system MUST preload an interstitial and reload a fresh one after every show.

#### Cross-cutting

- **FR-018**: The system MUST suppress ALL ad placements for users holding an active ad-free premium entitlement, and the corresponding user action (download, app entry, browsing) MUST proceed normally without ads.
- **FR-019**: The system MUST use non-production (test) ad inventory in non-production builds and production ad inventory only in production builds, so test traffic never counts against real ad accounts.
- **FR-020**: The system MUST select the correct ad inventory per platform (Android AND iOS) at runtime for every placement; both platforms are in scope for this iteration. Production iOS ad identifiers and the iOS application identifier are supplied as configuration before release (see Assumptions); test inventory is used on iOS until they are provided.
- **FR-021**: The system MUST record an observability log/analytics event for every ad lifecycle outcome: load, show, failure, reward-earned, and dismissal, for each placement.
- **FR-022**: The system MUST release each ad object after use and reload single-use full-screen ads after each show, avoiding leaks and "ad already in use" conditions.
- **FR-023**: The system MUST initialize the ad framework once at app startup before any ad is requested, and a failure to initialize MUST NOT crash or block app launch.
- **FR-024**: Each placement (rewarded, app-open, banner, interstitial) MUST be independently testable and independently disable-able without affecting the others.
- **FR-025**: The system MUST present a privacy/consent prompt (a regulated-region consent flow, e.g. Google UMP) on first launch in regions that require it, gather the user's consent choice before requesting personalized ads, and respect that choice on subsequent launches without re-prompting unless required.
- **FR-026**: The system MUST NOT block app entry on the consent flow beyond the standard one-time prompt; if consent cannot be gathered (e.g. offline, region not requiring it), the app MUST proceed and serve only the ad personalization level the gathered/absent consent permits.
- **FR-027**: The consent flow MUST be testable in a forced-region/debug mode so the prompt can be verified without being physically in a regulated region.

### Key Entities

- **Ad Placement**: A defined monetization surface (rewarded-download, app-open, home-banner, category-interstitial). Attributes: format, trigger event, ready/loaded state, frequency/cooldown rules (where applicable).
- **Ad Inventory Identifier**: The reference that selects which ad to serve, resolved by build type (test vs production) and platform (Android vs iOS). Never user-visible.
- **Premium Entitlement**: The user's current ad-free status, which globally gates whether any ad is shown.
- **Frequency/Cooldown State**: In-memory, per-session counters and timestamps governing how often the category interstitial may appear (count of category switches since last show, time of last show). Reset on each app launch; not persisted.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of download attempts succeed in completing the download regardless of ad availability or network state — i.e., zero downloads are permanently blocked by the ad layer.
- **SC-002**: When offline, a user can still tap Download and receive their wallpaper in the same number of steps as when online (no extra blocking screens).
- **SC-003**: App entry after splash is never delayed by more than a negligible moment when no app-open ad is ready (user reaches Home with no perceptible added wait).
- **SC-004**: The Home wallpaper grid is never visually covered or clipped by the banner; on banner failure the grid reclaims 100% of the freed space with no empty box.
- **SC-005**: The category interstitial appears no more than once per N category switches (N = configured default) and never more frequently than the configured cooldown, verified across a sequence of rapid switches.
- **SC-006**: Premium (ad-free) users encounter zero ads across all four placements in a full session.
- **SC-007**: Every ad load/show/failure/reward/dismissal is observable in logs/analytics, enabling per-placement fill and failure rates to be measured.
- **SC-008**: No production ad inventory is requested from non-production builds (verifiable by inspecting requested identifiers in test runs).
- **SC-009**: All four placements behave identically (per their requirements) on both Android and iOS, each resolving the correct per-platform inventory.
- **SC-010**: In a regulated region, a first-launch user sees the consent prompt exactly once; their choice is persisted and personalized-ad behavior matches the choice on subsequent launches.

## Assumptions

- **Premium suppression preserved**: The existing ad-free premium behavior (ads suppressed when the user has an active entitlement) is retained and applies to all four placements. This mirrors the app's current monetization model.
- **Single download surface**: "Download" refers to the existing wallpaper download action(s) in the app; the rewarded gate replaces the current rewarded wiring on that action rather than adding a parallel one.
- **Test-vs-production selection**: Because the app currently ships from a single entry point (no separate flavor entry points yet), "non-production vs production" inventory is selected by build mode (debug/profile = test inventory, release = production inventory) unless flavor entry points are introduced during planning. The user-facing requirement (FR-019) is build-type agnostic.
- **Frequency defaults**: Category interstitial defaults to showing at most once per 3–4 category switches with a ≥ 60-second cooldown, tunable without code restructuring.
- **App-open validity window**: ~4 hours, per the ad framework's standard expiry guidance.
- **Reward semantics**: The "reward" carries no in-app currency; earning it simply authorizes the wallpaper download to proceed.
- **Real App ID / inventory IDs are a deployment step**: The production application identifier and any production ad identifiers are supplied as configuration at build/release time and are not part of the feature's user-facing behavior.
- **iOS in scope**: Both Android and iOS are delivered this iteration. Android production ad identifiers are known; **iOS production ad identifiers (per format) and the iOS App ID must be supplied by the product owner before the iOS release** — until then iOS serves test inventory. Per-platform plumbing is built regardless.
- **Consent in scope**: A regulated-region consent flow (Google UMP) is included. It governs ad personalization level only; it does not change whether the four placements appear (premium status alone governs ad suppression).

## Dependencies

- An active premium/entitlement signal must be queryable at each placement trigger to honor FR-018.
- A splash-to-Home navigation hand-off point must exist to trigger the app-open show (FR-007).
- A Home category-selection signal must be observable at the presentation layer to trigger the interstitial (FR-014) without embedding ad logic in category-selection business logic.
- The ad framework must be initialized at startup (FR-023).

## Out of Scope

- Rewarded ads for any action other than download.
- Native/in-feed ads woven into the wallpaper grid.
- Server-side ad mediation or additional ad networks beyond the primary provider.
- A/B testing of placement frequency (defaults are fixed for this iteration).
- Changes to the premium purchase flow itself (only its ad-suppression effect is consumed here).
