# Feature Specification: Monetization — AdMob Ads & In-App Purchases

**Feature Branch**: `005-admob-iap-monetization`
**Created**: 2026-03-24
**Status**: Draft
**Input**: User description: "continue implementation of Phase 5 — Monetization (AdMob & In-App Purchases) from plan.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Free User Sees Ads Throughout App (Priority: P1)

A user who has not purchased a premium subscription opens the app. On every cold start they see a full-screen ad before reaching Home. While browsing the Home screen, a banner ad sits at the bottom. When they try to download a wallpaper or preview it in the phone frame, a rewarded video ad plays first — only after successfully watching it does the action proceed.

**Why this priority**: Ads are the primary revenue mechanism for non-paying users and must be in place before the premium upsell is meaningful.

**Independent Test**: Install the app fresh (no subscription), cold-start it, browse Home, attempt a download, and attempt a phone-frame preview. All three ad types must appear at the correct moments.

**Acceptance Scenarios**:

1. **Given** the app has been cold-started and at least 4 hours have elapsed since the last app-open ad was shown, **When** the splash initialization finishes, **Then** a full-screen (app-open) ad is shown to a free user before the Home screen is displayed.
2. **Given** the app has been cold-started but fewer than 4 hours have elapsed since the last app-open ad, **When** the splash initialization finishes, **Then** no app-open ad is shown and the user navigates directly to Home.
3. **Given** a free user is on the Home screen, **When** the screen is visible, **Then** a banner ad is anchored to the bottom of the screen.
4. **Given** a free user taps the Download button on a wallpaper, **When** the download flow begins, **Then** a rewarded video ad is presented; the download only proceeds if the user earns the reward.
5. **Given** a free user taps the Preview (phone-frame) button, **When** the preview flow begins, **Then** a rewarded video ad is presented; the preview only opens if the user earns the reward.
6. **Given** a rewarded ad fails to load, **When** the user triggers the gated action, **Then** the system informs the user that the ad is unavailable and the action does not proceed.

---

### User Story 2 - User Purchases a Premium Subscription (Priority: P1)

A free user navigates to the "Get Premium" screen, sees a comparison of Free vs. Premium benefits, reviews the subscription price fetched live from the platform store, and completes a purchase through the native platform payment sheet. After a successful purchase, all ads disappear instantly and the user has unrestricted access to downloads and previews.

**Why this priority**: Premium conversion is the core monetization goal; the end-to-end purchase flow must be reliable and secure.

**Independent Test**: Open "Get Premium" from the profile or drawer, tap "Subscribe Now", complete the platform purchase flow, and verify ads are gone and gated actions work freely.

**Acceptance Scenarios**:

1. **Given** a user opens the Get Premium screen, **When** the screen loads, **Then** it displays a feature comparison table (Free vs. Premium) and the live subscription price from the platform store.
2. **Given** a user taps "Subscribe Now", **When** the native payment sheet is presented, **Then** the platform purchase flow (Google Play / App Store) is initiated.
3. **Given** a user completes the purchase successfully, **When** the transaction is confirmed and verified server-side, **Then** the app switches to premium mode: all ads are hidden and all gated actions become unrestricted.
4. **Given** a purchase is pending (e.g., parental approval required), **When** the user returns to the app, **Then** the app shows a pending state and does not grant premium access until the transaction is confirmed.
5. **Given** a purchase fails (payment declined, network error, etc.), **When** the failure is detected, **Then** the user sees a clear error message and remains on the free tier.

---

### User Story 3 - User Restores a Previous Purchase (Priority: P2)

A premium subscriber reinstalls the app or switches devices. They navigate to the Get Premium screen and tap "Restore Purchase". The app re-verifies their existing subscription with the platform store and restores their premium status without charging them again.

**Why this priority**: Restore is a platform store requirement and a critical trust signal; users who paid must never be forced to pay again.

**Independent Test**: On a device where a subscription was previously purchased, install fresh, open Get Premium, tap Restore, and confirm premium status is regained.

**Acceptance Scenarios**:

1. **Given** a user who previously purchased premium taps "Restore Purchase", **When** the platform store confirms the subscription is active, **Then** premium access is restored and all ads are removed.
2. **Given** a user taps "Restore Purchase" and no active subscription exists, **When** the platform store returns no valid purchase, **Then** the user is informed that no active subscription was found.
3. **Given** a restore check encounters a network error, **When** the platform store is unreachable, **Then** the user is informed to try again later.

---

### User Story 4 - Premium User Manages or Cancels Subscription (Priority: P3)

A premium subscriber on the Profile page taps "Manage Subscription". The app deep-links them directly into the platform store's subscription management page, where they can cancel or change their plan. Cancellation is entirely managed by the platform.

**Why this priority**: Subscription management is mandatory per App Store and Google Play policies, but the app itself does not handle cancellation logic.

**Independent Test**: On a premium account, navigate to Profile, tap "Manage Subscription", and confirm the correct platform store management page opens.

**Acceptance Scenarios**:

1. **Given** a premium user is on the Profile screen, **When** they tap "Manage Subscription", **Then** the device opens the platform-native subscription management page (Google Play on Android, App Store on iOS).
2. **Given** the subscription lapses (user cancels externally), **When** the app is next cold-started, **Then** the subscription check detects the lapse and the user is returned to free tier with ads re-enabled.

---

### Edge Cases

- What happens when the app-open ad is still loading when splash initialization finishes? The app navigates to Home without blocking the user; the ad is discarded gracefully.
- How does the system handle a duplicate purchase attempt while a transaction is already in flight? The purchase button is disabled during an active transaction.
- What if the rewarded ad preload fails before the user triggers a gated action? The user is notified the ad is unavailable and the action is blocked.
- What if server-side receipt verification returns an error or is unreachable at purchase time? Premium is granted optimistically; the receipt is stored as pending-verification and re-verified silently on the next cold start. The user is not informed unless re-verification also fails on the next start, at which point they revert to free tier.
- What if premium status cannot be checked on launch due to network offline? The app falls back to the locally cached premium flag (trusted for up to 7 days). If no cache exists, the user is treated as free. If the cache is older than 7 days and the device is still offline, the user is treated as free until connectivity is restored and a re-check succeeds.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display a full-screen (app-open) ad to free users after splash initialization completes, before navigating to the Home screen. The ad MUST be subject to a frequency cap: shown at most once per session and only if at least 4 hours have elapsed since it was last shown.
- **FR-002**: The system MUST display a banner ad at the bottom of the Home screen for free users at all times the screen is active.
- **FR-003**: The system MUST hide all ad units completely for premium users — no ad content may be loaded or displayed.
- **FR-004**: The system MUST gate the wallpaper download action behind a rewarded video ad for free users; the download MUST only proceed after the reward is successfully earned.
- **FR-005**: The system MUST gate the phone-frame preview action behind a rewarded video ad for free users; the preview MUST only open after the reward is earned.
- **FR-006**: The system MUST preload the next rewarded ad automatically after each ad is consumed so subsequent gated actions have a ready ad.
- **FR-007**: The system MUST provide a "Get Premium" screen that shows a feature comparison (Free vs. Premium) and both a monthly and a yearly subscription option, with live prices fetched from the platform store. The user selects a plan before tapping "Subscribe Now".
- **FR-008**: The system MUST initiate the native platform purchase flow when the user taps "Subscribe Now" on the Get Premium screen.
- **FR-009**: The system MUST attempt to verify every completed purchase receipt with the backend server. If verification succeeds, premium is granted immediately. If the verification endpoint is unreachable or returns an error, the system MUST grant premium optimistically, mark the receipt as pending-verification, and silently re-verify on the next cold start; if re-verification fails again, the user reverts to free tier.
- **FR-010**: Upon successful verified purchase, the system MUST immediately remove all ads and lift all rewarded-ad gates for the current session and all future sessions.
- **FR-011**: The Get Premium screen MUST include a "Restore Purchase" button.
- **FR-012**: Tapping "Restore Purchase" MUST re-verify existing purchases with the platform store and re-grant premium access if an active subscription is found.
- **FR-013**: The Profile screen MUST include a "Manage Subscription" button that deep-links to the platform's native subscription management page.
- **FR-014**: The system MUST cache premium status locally so users do not lose access between sessions. The cached flag is trusted for up to 7 days; after 7 days without a successful re-check, the user is treated as free until connectivity is restored.
- **FR-015**: The system MUST detect a lapsed subscription on cold start and revert the user to the free tier.
- **FR-016**: The system MUST emit the following analytics events at the points indicated: `ad_shown` (app-open or rewarded ad displayed), `reward_earned` (rewarded ad completed), `purchase_initiated` (Subscribe Now tapped), `purchase_succeeded` (premium granted after verification), `restore_succeeded` (premium restored via Restore Purchase).

### Key Entities

- **Subscription**: Represents a user's premium entitlement. Key attributes: status (`free` / `premium`), product ID, purchase token/receipt, verification state (`verified` / `pending` / `unverified`), expiry date. Cached locally; re-verified server-side on purchase and restore. A `pending` receipt is re-verified silently on the next cold start.
- **AdUnit**: A runtime-managed ad instance (app-open, banner, rewarded). Key attributes: type, load state (loading / loaded / failed), shown state. Lifecycle tied to screen visibility and user tier.
- **PremiumProduct**: A store product descriptor retrieved live from the platform. Key attributes: product ID, display title, formatted price string, billing period (`monthly` / `yearly`). Both a monthly and a yearly product are shown on the Get Premium screen; the user selects one before purchasing.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Free users see the app-open ad on 100% of eligible cold starts (ad loaded and at least 4 hours since last show); users who cold-start within the 4-hour window never see it.
- **SC-002**: The banner ad is visible to free users at all times the Home screen is active and is never visible to premium users.
- **SC-003**: There are zero bypass paths for free users to download or preview wallpapers without earning a rewarded ad reward.
- **SC-004**: Premium users complete downloads and previews with zero ad interruptions.
- **SC-005**: The end-to-end purchase flow (Subscribe Now → platform payment → server verification → premium granted) completes without requiring any extra steps beyond the native payment sheet.
- **SC-006**: Restore Purchase successfully re-grants premium on a fresh install for users with an active subscription.
- **SC-007**: On subscription lapse, the user is reverted to free tier (with ads) within one app cold start.
- **SC-008**: The Get Premium screen displays the live price from the platform store within 3 seconds of opening on a standard network connection.
- **SC-009**: All 5 key funnel events (`ad_shown`, `reward_earned`, `purchase_initiated`, `purchase_succeeded`, `restore_succeeded`) are emitted with zero omissions across their respective user flows.

## Clarifications

### Session 2026-03-24

- Q: If the `/subscription/verify` endpoint is unreachable or returns an error at purchase time, what should the app do? → A: Grant premium optimistically; mark receipt as pending-verification; re-verify silently on the next cold start and revert only if still unverified.
- Q: Should the Get Premium screen offer both monthly and yearly subscription plans, or just one for MVP? → A: Both monthly and yearly plans shown; user selects before tapping Subscribe Now.
- Q: How long should the locally cached premium flag remain trusted when the device is offline before a forced re-check? → A: 7 days.
- Q: Should the app-open ad show on every cold start or have a frequency cap? → A: Once per session, with a minimum 4-hour gap between shows.
- Q: Should the monetization layer track analytics/funnel events? → A: Track key funnel events only: ad shown, reward earned, purchase initiated, purchase succeeded, restore succeeded.

## Assumptions

- The backend exposes a `POST /subscription/verify` endpoint that accepts a purchase token/receipt and returns a verified premium status.
- AdMob ad unit IDs (banner, rewarded, app-open) are environment-specific and configured via the existing Envied environment config.
- Two IAP product IDs (one monthly, one yearly) are pre-configured in Google Play Console and App Store Connect before this phase is implemented.
- The app already has a global `SubscriptionCubit` (from Phase 2) holding the `free` / `premium` state; this phase wires purchase and ad logic into it.
- The rewarded ad gate applies to both image and video wallpaper downloads and to phone-frame previews.
- No in-app cancellation UI is required; subscription cancellation is always performed through the platform store.
- Platform-level purchase security (e.g., preventing duplicate charges for active subscriptions) is enforced by the platform stores themselves.
