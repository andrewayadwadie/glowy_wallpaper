# Feature Specification: Auth & User Profile

**Feature Branch**: `002-auth-user-profile`
**Created**: 2026-03-20
**Status**: Draft
**Input**: User description: "Phase 2 — Auth & User Profile from plan.md"

## Clarifications

### Session 2026-03-20

- Q: What user data does the API return alongside the auth token on login/register? → A: Token + full user object (id, name, email, subscription status) in the login/register response.
- Q: What happens when an authenticated user navigates to Login/Register? → A: Redirect authenticated users from Login/Register to Home automatically.
- Q: Is a confirm password field required on the Register screen? → A: Yes, require confirm password field on Register (must match password).
- Q: How should the app handle repeated failed login attempts? → A: Client-side lockout — disable login button for 30 seconds after 5 failed attempts, show countdown.
- Q: Should the Splash screen check auth status and route accordingly? → A: Yes — Splash checks token → if authenticated: fetch subscription status → Home; if not: → Home as guest.
- Q: Is auth required to access Home? → A: No. All users (guest and premium) see Home. Auth is NOT a gate for Home access. Premium content items are simply hidden from guest users.
- Q: What does the Profile icon show for guest vs premium users? → A: Guest → bottom sheet prompting login/register. Premium → shows user data, subscription advantages, and unsubscribe button.
- Q: How is user status validated on app start? → A: An endpoint accepts the user's saved token to verify their status with the server on launch.

### Session 2026-03-20 (Clarify Round 2)

- Q: What does the guest profile icon interaction look like? → A: Bottom sheet prompting "Log in or Register to access your profile" with two buttons.
- Q: Are subscription advantages static or dynamic? → A: Static hardcoded list (e.g., "Ad-free experience", "Access premium wallpapers", "Priority downloads").
- Q: Does unsubscribe take effect immediately or at end of billing period? → A: Immediate — status reverts to "guest" right away, premium items hidden instantly.
- Q: After a guest authenticates from a premium-action prompt, where do they return? → A: Return to the exact item/screen they were on, then retry the action.
- Q: How many user types exist? → A: Two types only — Guest and Premium. No "free authenticated" tier. Guest sees regular content with ads. Premium sees all content with no ads.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Guest Access to Home (Priority: P1)

Any user — guest or premium — opens the app and lands on the Home screen. Guest users (no account or not logged in) see all regular content but premium items are hidden from them entirely (no "exclusive" badge or lock icon — the items simply do not appear). Guests also see ads. This ensures a clean, frustration-free browsing experience for guests while incentivizing premium subscription.

**Why this priority**: Home must be accessible to everyone immediately. Gating Home behind auth would lose users at first launch. Showing premium items with locks would frustrate guests. Hiding them entirely keeps the experience clean.

**Independent Test**: Launch the app without logging in → verify Home screen loads with regular content visible → verify premium-only items are NOT visible (no badge, no lock, just absent) → verify ads are shown. Then log in as a premium user → verify premium items now appear and ads are gone.

**Acceptance Scenarios**:

1. **Given** a guest user (not logged in), **When** they launch the app, **Then** they are navigated directly to the Home screen after the splash.
2. **Given** a guest user on Home, **When** the content loads, **Then** premium items are completely hidden — not shown with a lock or "exclusive" label, just absent from the grid.
3. **Given** a guest user on Home, **When** ads load, **Then** ads are displayed (banner, rewarded gates, etc.).
4. **Given** a premium user on Home, **When** the content loads, **Then** all items are visible including premium content, with no special badge or flag distinguishing them, and no ads are shown.

---

### User Story 2 - User Registration (Priority: P2)

A guest user decides to create an account and subscribe to premium. They navigate to the Register screen (e.g., from the profile icon bottom sheet or menu), fill in their name, email, password, and confirm password, and tap "Register." The system validates their input (email format, password strength, password match), creates an account via the API, receives the auth token and user object in the response, securely stores the token and user data, and navigates them back to Home — now as a premium user with all content visible and no ads.

**Why this priority**: Registration is the conversion funnel from guest to premium. It unlocks all premium features.

**Independent Test**: Open the app as guest → navigate to Register → fill valid name/email/password/confirm password → tap Register → verify navigation to Home with premium content visible and ads removed.

**Acceptance Scenarios**:

1. **Given** the user is on the Register screen, **When** they enter a valid name, unused email, strong password (8+ characters, at least one uppercase, one number), and matching confirm password, and tap Register, **Then** the account is created, auth token and user object are received, token is securely stored, and they are navigated to Home.
2. **Given** the user is on the Register screen, **When** they enter an email that is already registered, **Then** the system displays an error message "Email already in use" without crashing.
3. **Given** the user is on the Register screen, **When** they enter a weak password (fewer than 8 characters), **Then** the Register button remains disabled and inline validation shows "Password must be at least 8 characters."
4. **Given** the user is on the Register screen, **When** the confirm password does not match the password, **Then** inline validation shows "Passwords do not match" and the Register button remains disabled.
5. **Given** the user is on the Register screen, **When** they submit the form and the network is unavailable, **Then** a user-friendly error message is shown with a retry option.

---

### User Story 3 - User Login (Priority: P3)

A returning premium user who previously registered wants to log back in. They navigate to Login, enter their email and password, and tap "Login." The system authenticates via the API, receives the token and user object, stores the token securely, and navigates to Home with premium content visible and no ads.

**Why this priority**: Login is the re-entry point for returning premium users. It restores their ad-free experience and premium content visibility.

**Independent Test**: Open the app → navigate to Login → enter valid credentials → tap Login → verify token stored and navigation to Home with premium content and no ads.

**Acceptance Scenarios**:

1. **Given** the user has a registered account, **When** they enter correct email and password and tap Login, **Then** they are authenticated, token and user object are received, token is stored, and they navigate to Home.
2. **Given** the user enters incorrect credentials, **When** they tap Login, **Then** the system displays "Invalid email or password" without revealing which field is wrong.
3. **Given** the user is on the Login screen, **When** they tap "Don't have an account? Register," **Then** they are navigated to the Register screen.
4. **Given** the user has failed login 5 times consecutively, **When** they attempt a 6th login, **Then** the login button is disabled for 30 seconds and a countdown timer is displayed.
5. **Given** the user is already authenticated (valid stored token), **When** they navigate to the Login screen, **Then** they are automatically redirected to Home.

---

### User Story 4 - Token Validation & Status Check on Launch (Priority: P4)

When the app starts, the splash screen checks if a saved auth token exists. If a token is found, it is sent to the server via a validation endpoint to verify the user's current status (valid/expired, guest/premium). If valid and premium, the user proceeds to Home as a premium user with all content and no ads. If the token is invalid or expired (401), the token is cleared and the user proceeds to Home as a guest. If no token exists, the user proceeds to Home as a guest.

**Why this priority**: Token validation on startup ensures the user's status is always current (e.g., if their subscription expired since last use). It also catches revoked tokens early rather than failing on the first API call.

**Independent Test**: Log in → close app → reopen → verify splash sends token to server → verify correct status applied → Home loads with correct content visibility. Then revoke token server-side → reopen → verify guest experience on Home.

**Acceptance Scenarios**:

1. **Given** a stored auth token exists, **When** the app launches and sends the token to the validation endpoint, **Then** the server returns the user's current status (premium or expired) and the app applies it before navigating to Home.
2. **Given** a stored auth token exists but is expired/revoked, **When** the validation endpoint returns 401, **Then** the token is cleared and the user proceeds to Home as a guest.
3. **Given** no stored token exists, **When** the app launches, **Then** the user proceeds directly to Home as a guest (no validation call made).
4. **Given** a stored auth token exists, **When** the validation endpoint call fails (network error), **Then** the app proceeds to Home using the last known status, defaulting to guest if no cached status exists.

---

### User Story 5 - Profile Icon Behavior (Guest vs Premium) (Priority: P5)

The Profile icon is visible on the Home screen for all users. Its behavior changes based on the user's status:
- **Guest user** taps the profile icon → a bottom sheet appears prompting "Log in or Register to access your profile" with Login and Register buttons.
- **Premium user** taps the profile icon → they see their display name, email, a "Premium" subscription badge, a static list of subscription advantages ("Ad-free experience", "Access premium wallpapers", "Priority downloads"), and an Unsubscribe button.

**Why this priority**: The profile icon is a key touchpoint for conversion (guest → premium) and retention (showing premium value). Two distinct states require different UI responses.

**Independent Test**: Launch as guest → tap profile icon → verify bottom sheet with login/register prompt. Log in as premium → tap profile icon → verify full profile with advantages list and unsubscribe button.

**Acceptance Scenarios**:

1. **Given** a guest user on Home, **When** they tap the profile icon, **Then** a bottom sheet appears with the message "Log in or Register to access your profile" and Login and Register buttons.
2. **Given** a guest user sees the bottom sheet, **When** they tap Login, **Then** they are navigated to the Login screen.
3. **Given** a guest user sees the bottom sheet, **When** they tap Register, **Then** they are navigated to the Register screen.
4. **Given** a premium user on Home, **When** they tap the profile icon, **Then** they see their display name, email, "Premium" badge, a list of subscription advantages, and an Unsubscribe button.
5. **Given** a premium user on Profile, **When** they tap Unsubscribe, **Then** a confirmation dialog appears asking "Are you sure you want to unsubscribe?"
6. **Given** a premium user confirms unsubscribe, **When** the unsubscribe completes, **Then** their status reverts to guest immediately, premium content is hidden on Home, ads reappear, and the profile icon reverts to guest behavior (bottom sheet prompt).

---

### User Story 6 - Logout (Priority: P6)

A premium user can log out from their Profile screen. Tapping Logout clears the session, removes the stored token, and returns them to Home as a guest — not to a Login screen, since Home is accessible to all. Premium content is hidden and ads reappear.

**Why this priority**: Logout is the inverse of login. Since Home is guest-accessible, logout should return the user to Home (not Login), with the guest experience restored.

**Independent Test**: Log in as premium → navigate to Profile → tap Logout → verify token cleared → verify Home loads as guest (premium items hidden, ads shown).

**Acceptance Scenarios**:

1. **Given** a premium user on Profile, **When** they tap Logout, **Then** a confirmation dialog appears asking "Are you sure you want to log out?"
2. **Given** the user confirms logout, **When** the logout completes, **Then** the auth token is removed from secure storage, app state is reset to guest, and they are navigated to Home.
3. **Given** the user taps Logout but network is unavailable, **When** logout API call fails, **Then** the local session is still cleared and the user is navigated to Home as a guest (local-first logout).
4. **Given** the user has logged out, **When** they view Home, **Then** premium items are hidden, ads are shown, and the profile icon shows guest behavior (bottom sheet prompt).

---

### Edge Cases

- What happens when the user's email contains special characters (e.g., `user+tag@example.com`)? The system must accept RFC 5322-compliant email addresses.
- What happens if the user double-taps the Register/Login button? The system must prevent duplicate submissions (disable button after first tap, show loading indicator).
- What happens if the user force-kills the app during registration? No partial state should persist — the next launch should present Home as a guest.
- What happens when the stored token is corrupted or unreadable from secure storage? Treat as no token — proceed to Home as guest.
- What happens if the user changes their password on another device? The existing token should be invalidated by the API (401), triggering a transition to guest on next launch.
- What happens during registration if the API returns a 500 server error? Show a generic "Something went wrong" message with a retry option.
- What happens if the user enters wrong credentials 5 times? The login button is disabled for 30 seconds with a visible countdown, then re-enabled.
- What happens if a guest user tries to interact with a premium-gated action (e.g., favorite, download)? A bottom sheet prompts them to log in or register. After successful auth, the user is returned to the exact item/screen and the action is retried automatically.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow all users (guest and premium) to access the Home screen without authentication.
- **FR-002**: System MUST support exactly two user types: Guest (unauthenticated, sees regular content with ads) and Premium (authenticated subscriber, sees all content with no ads).
- **FR-003**: System MUST hide premium content items from guest users entirely — no "exclusive" badge, lock icon, or any indicator. The items simply do not appear in the content grids.
- **FR-004**: System MUST show all content (including premium items) to premium users, with no visual distinction between regular and premium items, and no ads.
- **FR-005**: System MUST allow users to register with display name, email, password, and confirm password.
- **FR-006**: System MUST validate email format (RFC 5322), password strength (minimum 8 characters, at least one uppercase letter, one number), and confirm password match on the client side before submitting.
- **FR-007**: System MUST authenticate users via email and password against the `/auth/login` endpoint.
- **FR-008**: System MUST securely store the authentication token using device-level encrypted storage (not plain local storage).
- **FR-009**: System MUST send the stored auth token to a server validation endpoint on app launch to verify the user's current status (valid/expired, guest/premium).
- **FR-010**: System MUST handle 401 API responses from the validation endpoint by clearing the stored token and proceeding to Home as a guest.
- **FR-011**: System MUST redirect authenticated users attempting to access Login or Register to the Home screen.
- **FR-012**: System MUST provide a Logout action that clears the stored token and all user-specific cached data, then navigates to Home as a guest.
- **FR-013**: System MUST show a bottom sheet with "Log in or Register" prompt when a guest user taps the profile icon.
- **FR-014**: System MUST show the Profile screen for premium users with: display name, email, "Premium" badge, a static list of subscription advantages ("Ad-free experience", "Access premium wallpapers", "Priority downloads"), and an Unsubscribe button.
- **FR-015**: System MUST fetch and apply subscription status (guest/premium) from the server on app launch for authenticated users, defaulting to guest if the check fails.
- **FR-016**: System MUST show inline validation errors on form fields (email format, password strength, confirm password match, required fields) in real time as the user types.
- **FR-017**: System MUST disable the submit button and show a loading indicator during API calls to prevent duplicate submissions.
- **FR-018**: System MUST display user-friendly error messages for all API failure scenarios (network error, server error, invalid credentials, email already in use).
- **FR-019**: System MUST call `/auth/logout` on the server before clearing the local session. If the server call fails, the local session MUST still be cleared (local-first logout).
- **FR-020**: System MUST receive and store the user object (id, display name, email, subscription status) returned alongside the auth token in login/register API responses.
- **FR-021**: System MUST disable the login button for 30 seconds after 5 consecutive failed login attempts and display a countdown timer.
- **FR-022**: System MUST show a bottom sheet prompting login/register when a guest user attempts a premium-gated action (favorite, download). After successful authentication, the user MUST be returned to the exact item/screen and the action retried automatically.
- **FR-023**: System MUST process unsubscribe requests immediately — the user's status reverts to guest instantly, premium content is hidden, and ads reappear without requiring an app restart.

### Key Entities

- **GuestUser**: Represents an unauthenticated user (the default state). Has no stored identity. Can browse Home and see regular (non-premium) content. Sees ads. Cannot favorite, download, or see premium items. Prompted to log in/register when attempting premium actions.
- **PremiumUser**: Represents an authenticated user with an active subscription. Attributes: unique identifier, display name, email address. Sees all content (including premium items). No ads. Can favorite and download. Has access to Profile with subscription advantages and unsubscribe option.
- **AuthToken**: Represents the premium user's authentication credential. Stored in encrypted device storage. Used to authenticate all API requests via the Authorization header. Validated against the server on each app launch. Has an implicit expiry controlled server-side.

## Assumptions

- The backend API is RESTful and follows the endpoint contracts defined in the project plan (`/auth/login`, `/auth/register`, `/auth/logout`, `/subscription/status`).
- The login and register API responses return both the auth token and a user object containing id, display name, email, and subscription status.
- A token validation endpoint exists that accepts the stored token and returns the user's current status (or 401 if invalid).
- Password hashing is handled server-side; the client sends plaintext passwords over HTTPS.
- The auth token is a JWT or opaque token — the client does not need to decode it, only store and attach it to requests.
- Token refresh is not in scope for Phase 2. If a token expires, the user becomes a guest and must re-authenticate.
- There are exactly two user types: Guest and Premium. There is no "free authenticated" tier.
- Registration implies premium subscription — a user who registers is a premium user. The payment/subscription flow (Stripe) is handled in Phase 5; for Phase 2, registration alone grants premium status.
- Premium content items are tagged as premium in the API response data, allowing the client to filter them based on user status.
- The Unsubscribe action takes effect immediately — no end-of-billing-period grace period on the client side.
- The subscription advantages list is static and hardcoded: "Ad-free experience", "Access premium wallpapers", "Priority downloads".
- The 5-attempt login lockout is client-side only and resets on app restart. Server-side rate limiting is the API's responsibility.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Guest users reach the Home screen within 3 seconds of app launch (no auth barrier).
- **SC-002**: 100% of premium content items are hidden from guest users — zero leakage.
- **SC-003**: Premium users see all content including premium items immediately upon Home load, with zero ads displayed.
- **SC-004**: Users can complete the registration flow (open app → fill form → return to Home as premium) in under 60 seconds.
- **SC-005**: Users can log in and return to Home with premium status in under 30 seconds.
- **SC-006**: Auto-login via token validation (stored token → splash check → Home) completes in under 3 seconds on cold start.
- **SC-007**: Profile icon responds correctly to user state (guest bottom sheet / premium profile) 100% of the time.
- **SC-008**: All form validation errors are displayed inline within 200ms of user input, before any API call.
- **SC-009**: Logout clears all user-specific data and returns to Home as guest in under 2 seconds, even if the network is unavailable.
- **SC-010**: 95% of users successfully complete registration on their first attempt without encountering confusing error states.
- **SC-011**: After a guest authenticates from a premium-action prompt, they are returned to the exact item within 1 second of auth completion.
- **SC-012**: Unsubscribe reverts user to guest state immediately — premium items hidden and ads reappear within 1 second.
