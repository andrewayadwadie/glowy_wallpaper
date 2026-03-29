# Feature Specification: AdMob Ad Units Integration — Production Ad Setup

**Feature Branch**: `010-admob-ad-units-setup`
**Created**: 2026-03-27
**Status**: Draft
**Input**: User description: "Integrate specific AdMob ad units: App Open (splash), Rewarded Interstitial (download gate), Interstitial (favorite gate), Banner (home bottom) with production ad unit IDs"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - App Open Ad on Splash (Priority: P1)

When a user launches the app, a full-screen App Open ad is displayed during the splash screen before the user reaches the Home screen. This is the first ad experience and sets the tone for the monetization flow.

**Why this priority**: App Open ads generate revenue on every cold start and are the highest-impression ad format. This must work correctly from the first launch.

**Independent Test**: Cold-start the app, observe the App Open ad appearing over the splash screen before navigating to Home. Verify the ad uses the correct production ad unit ID.

**Acceptance Scenarios**:

1. **Given** the app is cold-started, **When** the splash screen initialization completes, **Then** an App Open ad (unit: `ca-app-pub-2083776520196762/2548207750`) is displayed before navigating to Home.
2. **Given** the App Open ad is displayed, **When** the user dismisses it or it auto-closes, **Then** the app navigates to the Home screen normally.
3. **Given** the App Open ad fails to load (network error, fill rate), **When** the splash completes, **Then** the app navigates to Home without delay — no ad is shown.
4. **Given** the user is a premium subscriber, **When** the app cold-starts, **Then** no App Open ad is loaded or displayed.

---

### User Story 2 - Rewarded Interstitial Ad Before Download (Priority: P1)

When a free user taps the download button on any wallpaper (image or video), a Rewarded Interstitial ad plays. The download only begins after the user completes watching the ad and earns the reward. This is the core download monetization gate.

**Why this priority**: Downloads are the primary user action and the Rewarded Interstitial format maximizes revenue per download event while giving users a clear value exchange.

**Independent Test**: As a free user, tap download on any wallpaper. A Rewarded Interstitial ad should play. After completing the ad, the download starts automatically.

**Acceptance Scenarios**:

1. **Given** a free user taps the Download button, **When** the download flow begins, **Then** a Rewarded Interstitial ad (unit: `ca-app-pub-2083776520196762/2641508848`) is presented.
2. **Given** the Rewarded Interstitial ad completes and the user earns the reward, **When** the ad is dismissed, **Then** the wallpaper download begins immediately.
3. **Given** the user dismisses the Rewarded Interstitial ad before earning the reward (e.g., closes early), **When** the ad closes, **Then** the download does not proceed and the user is informed.
4. **Given** the Rewarded Interstitial ad fails to load, **When** the user taps Download, **Then** the user is informed that the ad is unavailable and the download does not proceed.
5. **Given** the user is a premium subscriber, **When** they tap Download, **Then** the download proceeds immediately with no ad.
6. **Given** a Rewarded Interstitial ad was just consumed, **When** the ad closes, **Then** the next Rewarded Interstitial ad is preloaded automatically for the next download action.

---

### User Story 3 - Interstitial Ad Before Favorite (Priority: P1)

When a free user taps the favorite (heart) button to **add** a wallpaper to favorites, an Interstitial ad is displayed before the favorite action is executed. Unlike the download gate, this is a non-rewarded interstitial — it shows and then the favorite action proceeds after dismissal. The ad is NOT shown when removing a favorite.

**Why this priority**: Favorites are a frequent user action. An Interstitial ad here generates consistent impressions without blocking the action permanently (the favorite always completes after the ad).

**Independent Test**: As a free user, tap the favorite button on a wallpaper detail page. An Interstitial ad should display. After it dismisses, the wallpaper should be added to favorites.

**Acceptance Scenarios**:

1. **Given** a free user taps the Favorite button on a wallpaper that is NOT already favorited, **When** the add-favorite action is triggered, **Then** an Interstitial ad (unit: `ca-app-pub-2083776520196762/1519998865`) is displayed.
2. **Given** the Interstitial ad is shown, **When** the user dismisses the ad (tap close or it auto-closes), **Then** the add-favorite action completes (wallpaper is added to favorites).
3. **Given** a free user taps the Favorite button on a wallpaper that IS already favorited, **When** the remove-favorite action is triggered, **Then** no Interstitial ad is shown and the wallpaper is removed from favorites immediately.
4. **Given** the Interstitial ad fails to load, **When** the user taps Favorite, **Then** the favorite action proceeds immediately without showing an ad.
5. **Given** the user is a premium subscriber, **When** they tap Favorite, **Then** the favorite action proceeds immediately with no ad.
6. **Given** an Interstitial ad was just shown, **When** it closes, **Then** the next Interstitial ad is preloaded for the next favorite action.
7. **Given** a free user adds a favorite and an Interstitial was shown less than 60 seconds ago, **When** the add-favorite action is triggered, **Then** no Interstitial ad is shown and the favorite is added immediately.

---

### User Story 4 - Banner Ad on Home Screen (Priority: P2)

A persistent banner ad is always visible at the bottom of the Home screen for free users. It provides steady background revenue while the user browses wallpaper categories and content.

**Why this priority**: Banner ads provide consistent baseline revenue. However, they are lower priority than action-gated ads because they don't block user flows.

**Independent Test**: Navigate to the Home screen as a free user. A banner ad should be visible at the bottom of the screen at all times.

**Acceptance Scenarios**:

1. **Given** a free user is on the Home screen, **When** the screen is visible, **Then** a Banner ad (unit: `ca-app-pub-2083776520196762/8536132654`) is displayed anchored at the bottom of the screen.
2. **Given** the Banner ad is displayed, **When** the user navigates away from Home, **Then** the banner ad is properly disposed.
3. **Given** the Banner ad fails to load, **When** the Home screen is visible, **Then** the banner space collapses gracefully (no blank gap).
4. **Given** the user is a premium subscriber, **When** they view the Home screen, **Then** no banner ad is loaded or displayed.

---

### Edge Cases

- What happens when the user has no internet and ads cannot load? All ad-gated actions except download should proceed without an ad. Downloads should show an informational message that the ad couldn't load.
- What happens if the user rapidly taps the favorite button multiple times? Only the first tap triggers the Interstitial ad; subsequent taps are debounced until the ad flow completes.
- What if the Rewarded Interstitial ad shows but the app is backgrounded during playback? The ad state is preserved; when the user returns, the ad resumes or completes, and the reward is handled based on the ad SDK's callback.
- What if premium status changes mid-session (subscription lapses)? Ad gates re-activate on the next action check; no need to restart the app.
- What if multiple ad formats try to load simultaneously? Ad loading should be sequential — never show two full-screen ads at once. The App Open ad has priority on cold start.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display an App Open ad (unit ID: `ca-app-pub-2083776520196762/2548207750`) during the splash screen on every cold start for free users, before navigating to Home.
- **FR-002**: The system MUST gate the wallpaper download action behind a Rewarded Interstitial ad (unit ID: `ca-app-pub-2083776520196762/2641508848`) for free users. The download MUST only begin after the user earns the reward (reward setting: 2 — "get your download").
- **FR-003**: The system MUST display an Interstitial ad (unit ID: `ca-app-pub-2083776520196762/1519998865`) before executing the add-favorite action for free users. The ad MUST NOT be shown when removing a favorite. The favorite action MUST proceed after the ad is dismissed. The system MUST enforce a 60-second cooldown between Interstitial ads — if the last Interstitial was shown less than 60 seconds ago, the favorite proceeds without an ad.
- **FR-004**: The system MUST display a Banner ad (unit ID: `ca-app-pub-2083776520196762/8536132654`) at the bottom of the Home screen at all times for free users.
- **FR-005**: The system MUST hide all ad units (App Open, Rewarded Interstitial, Interstitial, Banner) completely for premium users — no ad content may be loaded or displayed.
- **FR-006**: The system MUST preload the next Rewarded Interstitial ad automatically after each ad is consumed, ensuring minimal wait time for subsequent download actions.
- **FR-007**: The system MUST preload the next Interstitial ad automatically after each ad is consumed, ensuring minimal wait time for subsequent favorite actions.
- **FR-008**: The system MUST replace the existing Rewarded ad format (used for downloads) with the Rewarded Interstitial format using the new production ad unit ID.
- **FR-009**: The system MUST add Interstitial ad support as a new ad type in the ad management service, alongside the existing App Open, Banner, and Rewarded types.
- **FR-010**: The system MUST update all ad unit IDs from test/placeholder IDs to the production IDs specified in this feature.
- **FR-011**: The system MUST handle ad load failures gracefully — Interstitial failures allow the action to proceed; Rewarded Interstitial failures block the download with a user-friendly message. When an ad must load on-demand (not preloaded), the system MUST show a loading indicator and enforce a 10-second timeout; if the ad does not load within 10 seconds, it is treated as a load failure.
- **FR-012**: The system MUST ensure only one full-screen ad (App Open, Interstitial, or Rewarded Interstitial) is displayed at a time — no overlapping full-screen ads.
- **FR-013**: The system MUST log analytics events for each ad interaction: `ad_shown` (with ad type parameter), `reward_earned` (for Rewarded Interstitial), and `ad_failed` (when ad fails to load for a gated action).
- **FR-014**: The system MUST remove the existing rewarded ad gate on the preview (phone frame) action. Preview MUST be accessible to all users (free and premium) without any ad.

### Key Entities

- **AdUnit**: Runtime-managed ad instance. Types: App Open, Banner, Rewarded Interstitial, Interstitial. Key attributes: type, production unit ID, load state (loading / loaded / failed), shown state. Lifecycle tied to screen visibility and user tier.
- **AdGate**: A decision point where an ad is shown before a user action. Key attributes: gated action (download, favorite), gate type (blocking — action requires reward, non-blocking — action proceeds after dismissal), associated ad format.
- **RewardConfig**: Defines the reward settings for Rewarded Interstitial ads. For download gate: reward amount = 2, reward label = "get your download".

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The App Open ad displays on 100% of cold starts for free users when the ad is available, using the correct production ad unit ID.
- **SC-002**: The Banner ad is visible to free users at all times the Home screen is active, using the correct production ad unit ID, and is never visible to premium users.
- **SC-003**: There are zero bypass paths for free users to download wallpapers without completing the Rewarded Interstitial ad and earning the reward.
- **SC-004**: The favorite action is gated by an Interstitial ad for 100% of free user taps — the favorite always completes after ad dismissal (never blocked permanently).
- **SC-005**: Premium users complete downloads, favorites, and all other actions with zero ad interruptions.
- **SC-006**: The next Rewarded Interstitial and Interstitial ads are preloaded within 5 seconds of the previous ad being consumed.
- **SC-007**: All four ad unit IDs in production match the specified IDs: App Open (`2548207750`), Rewarded Interstitial (`2641508848`), Interstitial (`1519998865`), Banner (`8536132654`).
- **SC-008**: Ad failure scenarios are handled gracefully — no crashes, freezes, or permanent blocking of user actions due to ad SDK errors.
- **SC-009**: Analytics events (`ad_shown`, `reward_earned`, `ad_failed`) are emitted accurately for all ad interactions.

## Clarifications

### Session 2026-03-27

- Q: Should the Interstitial ad show on both adding AND removing favorites, or only on add? → A: Only when adding a favorite; removing a favorite proceeds with no ad.
- Q: Should the App Open ad have a frequency cap (e.g., 4-hour gap) or show on every cold start? → A: Show on every cold start with no frequency cap.
- Q: Should the Interstitial (favorite) ad show on every add-favorite or have a cooldown? → A: 60-second cooldown between Interstitial ads; favorites within the cooldown proceed without an ad.
- Q: Should the existing preview (phone frame) rewarded ad gate be removed or kept? → A: Remove it; preview becomes free for all users (no ad gate).
- Q: What is the maximum wait time for a Rewarded Interstitial ad to load on-demand? → A: 10 seconds; show a loading indicator during the wait, then treat as load failure if exceeded.

## Assumptions

- The AdMob account (pub ID: `2083776520196762`) is active and all four ad units are approved and serving.
- The existing `AdHelper` singleton service will be extended to support Rewarded Interstitial and Interstitial ad formats alongside the existing App Open and Banner.
- The existing environment configuration for ad unit IDs will be updated to use the production IDs.
- The `google_mobile_ads` package already in the project supports both `RewardedInterstitialAd` and `InterstitialAd` classes.
- The existing ad-gate pattern will be adapted for the Interstitial (favorite) gate with non-blocking behavior (action proceeds after dismissal regardless of reward).
- Premium users are identified via the existing `SubscriptionCubit.isPremium` check — no changes to subscription logic are needed.
- The preview (phone frame) action is NOT gated by any ad in this feature — the existing preview rewarded ad gate from 005 must be actively removed. Only download and favorite actions have ad gates.
