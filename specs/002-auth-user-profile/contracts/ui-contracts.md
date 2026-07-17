# UI Contracts: Auth & User Profile

**Feature**: 002-auth-user-profile
**Date**: 2026-03-20

## Login Page

**Route**: `/login`
**Access**: Guest only (premium users redirected to Home)

**Layout**:
- App logo at top center
- Email text field with inline validation
- Password text field with show/hide toggle and inline validation
- Login button (disabled until valid input, shows loading spinner during API call)
- Lockout timer (visible after 5 failed attempts, 30s countdown)
- "Don't have an account? Register" link at bottom
- Error message area (generic "Invalid email or password" for credential errors)

**States**:
- Initial: Empty form, Login button disabled
- Validating: Inline errors shown as user types
- Submitting: Login button shows loading spinner, fields disabled
- Error: Error message shown below form
- Locked Out: Login button disabled, countdown timer shown

---

## Register Page

**Route**: `/register`
**Access**: Guest only (premium users redirected to Home)

**Layout**:
- App logo at top center
- Display name text field with validation (required, max 100 chars)
- Email text field with RFC 5322 validation
- Password text field with show/hide toggle (8+ chars, 1 uppercase, 1 number)
- Confirm password text field with match validation
- Register button (disabled until all validations pass)
- "Already have an account? Login" link at bottom
- Error message area

**States**:
- Initial: Empty form, Register button disabled
- Validating: Inline errors shown as user types
- Submitting: Register button shows loading spinner, fields disabled
- Error: Server error message shown below form
- Success: Navigate to Home as premium user

---

## Profile Page (Premium User)

**Route**: `/profile`
**Access**: Premium users only (guest sees bottom sheet prompt on profile icon)

**Layout**:
- User avatar placeholder (circle with initials)
- Display name (headlineMedium)
- Email (bodyMedium, muted color)
- "Premium" badge (chip with accent color)
- Divider
- "Subscription Advantages" section header
  - "Ad-free experience" with check icon
  - "Access premium wallpapers" with check icon
  - "Priority downloads" with check icon
- Divider
- Unsubscribe button (outlined, danger color)
- Logout button (filled, secondary color)

**States**:
- Loaded: All user data displayed
- Unsubscribing: Confirmation dialog → loading → navigate to Home as guest
- Logging out: Confirmation dialog → loading → navigate to Home as guest

---

## Guest Profile Bottom Sheet

**Trigger**: Guest taps profile icon on Home AppBar
**Type**: Modal bottom sheet

**Layout**:
- Handle bar at top
- Illustration or icon (person outline)
- Title: "Log in or Register to access your profile" (titleMedium)
- Subtitle: "Unlock premium wallpapers, ad-free experience, and more" (bodyMedium, muted)
- Login button (filled, primary)
- Register button (outlined, primary)
- Dismiss area (tap outside to close)

---

## Guest Action Bottom Sheet

**Trigger**: Guest taps favorite/download on any content item
**Type**: Modal bottom sheet

**Layout**:
- Handle bar at top
- Icon (lock outline)
- Title: "Premium Feature" (titleMedium)
- Subtitle: "Log in or register to [favorite/download] wallpapers" (bodyMedium, muted)
- Login button (filled, primary)
- Register button (outlined, primary)
- Dismiss area (tap outside to close)

**After auth**: Return to exact item/screen and retry the action automatically.

---

## Home Page Updates

**Profile icon in AppBar**: Always visible. Tap behavior depends on user state:
- Guest: Show Guest Profile Bottom Sheet
- Premium: Navigate to Profile Page

**Content grid filtering**: Content items from API include an `is_premium` field. When SubscriptionCubit state is `guest`, filter out items where `is_premium == true` before rendering the grid. When `premium`, show all items.

---

## Splash Page Updates

**Flow**:
1. Show branded splash (#121212 background)
2. Initialize services (Hive, DI, Firebase)
3. Check for stored auth token
   - No token → navigate to Home as guest
   - Token found → call `/subscription/status`
     - 200 + is_premium:true → navigate to Home as premium
     - 200 + is_premium:false → clear token, navigate to Home as guest (subscription expired)
     - 401 → clear token, navigate to Home as guest
     - Network error → use cached status (default: guest), navigate to Home
4. Error during init → show AppErrorWidget with retry
