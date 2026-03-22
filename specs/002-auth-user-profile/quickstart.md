# Quickstart: Auth & User Profile

**Feature**: 002-auth-user-profile
**Date**: 2026-03-20

## Test Scenarios

### Scenario 1: Guest launches app and browses Home
1. Fresh install, no stored token
2. App shows splash → navigates to Home
3. Home displays regular content only (no premium items)
4. Ads are visible
5. Profile icon shows in AppBar

**Expected**: Home loads in <3s, premium items absent, ads shown.

### Scenario 2: Guest taps profile icon
1. Guest user on Home
2. Tap profile icon in AppBar
3. Bottom sheet appears: "Log in or Register to access your profile"
4. Login and Register buttons visible

**Expected**: Bottom sheet appears immediately, both buttons functional.

### Scenario 3: Guest registers
1. From profile bottom sheet, tap Register
2. Fill: name="Test User", email="test@example.com", password="Test1234", confirm="Test1234"
3. Tap Register
4. API returns token + user (is_premium: true)
5. Navigate to Home

**Expected**: Home now shows premium content, no ads, profile icon leads to Profile page.

### Scenario 4: Premium user logs out
1. Premium user on Home → tap profile icon → Profile page
2. Tap Logout → confirmation dialog → confirm
3. Navigate to Home as guest

**Expected**: Premium items hidden, ads reappear, profile icon shows bottom sheet again.

### Scenario 5: Premium user unsubscribes
1. Premium user on Profile page
2. Tap Unsubscribe → confirmation dialog → confirm
3. API call succeeds
4. Status reverts to guest immediately

**Expected**: Navigate to Home, premium items hidden, ads shown, within 1 second.

### Scenario 6: Token validation on relaunch
1. Premium user closes app
2. Reopen app
3. Splash checks stored token → calls /subscription/status
4. Server returns 200 + is_premium: true
5. Navigate to Home as premium

**Expected**: Home loads with premium content in <3s.

### Scenario 7: Expired token on relaunch
1. Previously premium user, token expired server-side
2. Reopen app
3. Splash checks stored token → calls /subscription/status → 401
4. Token cleared, navigate to Home as guest

**Expected**: Guest experience, no crash, no Login redirect.

### Scenario 8: Guest tries to favorite/download
1. Guest user on Home, taps favorite/download on a wallpaper
2. Bottom sheet: "Premium Feature — Log in or register to favorite wallpapers"
3. User taps Login → logs in
4. Returns to exact wallpaper, action retried

**Expected**: Seamless return to item with action completed.

### Scenario 9: Login lockout after 5 failures
1. Enter wrong password 5 times
2. Login button disabled, 30s countdown shown
3. Wait 30s → button re-enabled

**Expected**: Countdown visible, button re-enables after timer.

### Scenario 10: Offline login attempt
1. Disable network
2. Try to login
3. Error message: "No internet connection"
4. Re-enable network, retry → succeeds

**Expected**: Clear error message, retry works.

## Build & Run

```bash
# Generate code (Freezed models, Retrofit, Injectable)
dart run build_runner build --delete-conflicting-outputs

# Run on device
flutter run

# Run tests
flutter test test/features/auth/

# Analyze
flutter analyze
```

## Key Files to Implement

| Layer | File | Purpose |
|-------|------|---------|
| Domain | `lib/features/auth/domain/entities/user_entity.dart` | User entity |
| Domain | `lib/features/auth/domain/repositories/auth_repository.dart` | Repository contract |
| Domain | `lib/features/auth/domain/usecases/login.dart` | Login use case |
| Domain | `lib/features/auth/domain/usecases/register.dart` | Register use case |
| Domain | `lib/features/auth/domain/usecases/logout.dart` | Logout use case |
| Domain | `lib/features/auth/domain/usecases/validate_token.dart` | Token validation use case |
| Domain | `lib/features/auth/domain/usecases/unsubscribe.dart` | Unsubscribe use case |
| Domain | `lib/features/auth/domain/usecases/get_cached_user.dart` | Get cached user use case |
| Data | `lib/features/auth/data/models/user_model.dart` | Freezed user model |
| Data | `lib/features/auth/data/models/auth_response_model.dart` | Freezed auth response |
| Data | `lib/features/auth/data/models/login_request_model.dart` | Login request body |
| Data | `lib/features/auth/data/models/register_request_model.dart` | Register request body |
| Data | `lib/features/auth/data/models/subscription_status_model.dart` | Subscription status |
| Data | `lib/features/auth/data/datasources/auth_remote_data_source.dart` | Retrofit API calls |
| Data | `lib/features/auth/data/datasources/auth_local_data_source.dart` | SecureStorage + Hive |
| Data | `lib/features/auth/data/repositories/auth_repository_impl.dart` | Repository implementation |
| Presentation | `lib/features/auth/presentation/cubit/auth_cubit.dart` | Auth actions cubit |
| Presentation | `lib/features/auth/presentation/cubit/subscription_cubit.dart` | App-wide subscription state |
| Presentation | `lib/features/auth/presentation/pages/login_page.dart` | Login screen |
| Presentation | `lib/features/auth/presentation/pages/register_page.dart` | Register screen |
| Presentation | `lib/features/auth/presentation/pages/profile_page.dart` | Profile screen |
| Presentation | `lib/features/auth/presentation/widgets/auth_form_field.dart` | Reusable form field |
| Presentation | `lib/features/auth/presentation/widgets/guest_profile_bottom_sheet.dart` | Guest prompt |
| Presentation | `lib/features/auth/presentation/widgets/guest_action_bottom_sheet.dart` | Premium action prompt |
| Core | `lib/core/routes/app_router.dart` | UPDATE: auth redirect logic |
| Core | `lib/core/utils/app_strings.dart` | UPDATE: auth string constants |
| Update | `lib/features/splash/presentation/pages/splash_page.dart` | UPDATE: token validation flow |
| Update | `lib/features/home/presentation/pages/home_page.dart` | UPDATE: profile icon, content filter |
