# Glowy Wallpaper

A cross-platform mobile wallpaper application built with Flutter, featuring image and video wallpapers, classification browsing, downloads, favorites, and a freemium monetization model with AdMob and in-app purchases.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Feature Modules](#feature-modules)
- [State Management](#state-management)
- [Error Handling](#error-handling)
- [Theming](#theming)
- [Responsive Design](#responsive-design)
- [Monetization](#monetization)
- [Notifications](#notifications)
- [Testing](#testing)
- [Code Style & Conventions](#code-style--conventions)

## Features

- Browse wallpapers by categories (images, videos, classifications)
- Full-screen wallpaper preview with swipe navigation
- Video wallpaper playback with mute/unmute controls
- Phone frame preview mode
- Download wallpapers to device gallery
- Favorites system (local + remote sync for premium users)
- Similar wallpapers discovery
- Classification-based browsing with nested wallpaper grids
- Infinite scroll pagination
- Firebase Cloud Messaging push notifications with deep linking
- Freemium model: ads for free users, ad-free experience for subscribers
- Material 3 light and dark theme support

## Tech Stack

| Category | Libraries |
|---|---|
| **Framework** | Flutter 3.41.5, Dart 3.11.3 |
| **State Management** | flutter_bloc 9.1.1 (Cubits) |
| **DI** | get_it 9.2.1, injectable 2.5.0 |
| **Navigation** | go_router 17.1.0 |
| **Networking** | dio 5.9.2, retrofit 4.4.2 |
| **Local Storage** | hive 2.2.3, flutter_secure_storage 9.2.4 |
| **Code Generation** | freezed 3.0.0, json_serializable 6.9.5, build_runner 2.4.15 |
| **Functional** | dartz 0.10.1 (Either type) |
| **UI** | flutter_screenutil 5.9.3, auto_size_text 3.0.0, cached_network_image 3.4.1 |
| **Fonts** | google_fonts 8.0.2 (Poppins) |
| **Loading** | loader_overlay 4.0.3, flutter_spinkit 5.2.1, shimmer 3.0.0 |
| **Animation** | lottie 3.3.2, animate_do 4.2.0 |
| **Media** | video_player 2.9.2, visibility_detector 0.4.0+2 |
| **Downloads** | gal 2.3.0, permission_handler 11.3.1, path_provider 2.1.5 |
| **Firebase** | firebase_core, firebase_analytics, firebase_messaging, firebase_crashlytics |
| **Monetization** | google_mobile_ads 5.3.0, in_app_purchase 3.2.0 |
| **Notifications** | flutter_local_notifications 18.0.1 |
| **Localization** | easy_localization 3.0.8 |
| **Utilities** | url_launcher, share_plus, connectivity_plus, envied |
| **Testing** | mocktail 1.0.4, bloc_test 10.0.0 |

## Architecture

The project follows **Clean Architecture** with a **feature-first** directory layout. Each feature is organized into three layers:

```
feature/
  domain/       -- Entities, repository interfaces, use cases
  data/         -- Models, data sources (remote + local), repository implementations
  presentation/ -- Cubits, pages, widgets
```

**Data flow:**

```
UI (Widget) --> Cubit --> UseCase --> Repository --> DataSource (Remote / Local)
                                        |
                                  Either<Failure, T>
```

- **Entities** are pure Dart classes in the domain layer
- **Models** extend entities with serialization (Freezed + json_serializable)
- **Repositories** return `Either<Failure, T>` from dartz for explicit error handling
- **Use cases** encapsulate single business operations
- **Cubits** manage UI state using Freezed state classes

## Project Structure

```
lib/
├── main.dart                         # Entry point, Hive & Firebase init
├── app.dart                          # MaterialApp.router, ScreenUtil, global providers
├── core/
│   ├── api/                          # Dio interceptors, API constants
│   ├── config/                       # App config, envied environment variables
│   ├── di/                           # GetIt service locator (injection_container.dart)
│   ├── enums/                        # Shared enums
│   ├── errors/                       # Failure sealed class, exception types
│   ├── models/                       # PaginatedResponse<T> generic wrapper
│   ├── network/                      # NetworkInfo (connectivity check)
│   ├── routes/                       # GoRouter config, route constants
│   ├── services/                     # AdHelper singleton
│   ├── theme/                        # Material 3 themes, colors, typography
│   ├── usecases/                     # Base UseCase<Type, Params> class
│   ├── utils/                        # AppStrings, AppDimens, AppColors
│   └── widgets/                      # Shared widgets (error, empty, shimmer, ads, etc.)
└── features/
    ├── app/                          # App bootstrap & metadata
    ├── auth/                         # Authentication & subscription
    ├── categories/                   # Category & classification browsing
    ├── wallpapers/                   # Wallpaper grid display
    ├── wallpaper_detail/             # Detail view, similar wallpapers
    ├── downloads/                    # Download to gallery
    ├── favorites/                    # Favorites (local + remote sync)
    ├── home/                         # Home page, category selector, drawer
    ├── premium/                      # IAP subscription management
    ├── notifications/                # FCM + local notifications
    ├── splash/                       # Splash screen
    └── settings/                     # Settings (placeholder)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.41.5+
- Dart SDK 3.11.3+
- Android Studio / VS Code with Flutter extensions
- Java 17 (for Android builds)
- Firebase CLI (for Firebase setup)

### Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd glowy_wallpaper
   ```

2. **Create environment files:**
   ```bash
   cp .env.example .env.dev
   ```
   Fill in the required values (see [Configuration](#configuration)).

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run code generation:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

### Hive Boxes

The following Hive boxes are initialized at startup:

| Box | Purpose |
|---|---|
| `user_cache` | Cached user data |
| `categories` | Category cache (legacy) |
| `favorites` | Local favorite wallpaper IDs |
| `downloads` | Download history records |
| `subscription_cache` | Premium subscription status |
| `ad_frequency` | Ad display frequency tracking |
| `app_bootstrap` | AppMetadataModel JSON cache |
| `notification_prefs` | Notification permission flag |

## Configuration

### Environment Variables (envied)

Environment-specific `.env` files (`.env.dev`, `.env.prod`, `.env.staging`) are loaded via the `envied` package:

| Variable | Description |
|---|---|
| `API_BASE_URL` | Backend API base URL |
| `ADMOB_APP_ID` | AdMob application ID |
| `ADMOB_BANNER_ID` | Banner ad unit ID |
| `ADMOB_REWARDED_ID` | Rewarded ad unit ID |
| `ADMOB_APP_OPEN_ID` | App open ad unit ID |
| `IAP_MONTHLY_PRODUCT_ID` | Monthly subscription product ID |
| `IAP_YEARLY_PRODUCT_ID` | Yearly subscription product ID |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key |

### App Config

Static configuration is defined in `lib/core/config/app_config.dart`:

- **Package name:** `com.glowy.wallpaper`
- **App ID:** `dcb4ac5f-17b9-4938-b0a9-8f1e78c4beb6`
- **Dev base URL:** `http://10.0.2.2:3001`
- **Prod base URL:** `https://api.glowywallpapers.com`

### Firebase

- **Project ID:** `glowywallpaper`
- **Services:** Analytics, Cloud Messaging, Crashlytics
- **Config file:** `android/app/google-services.json`

### Design Baseline

ScreenUtil is configured with a design size of **375x812** (iPhone 11).

## Feature Modules

### App Bootstrap (`features/app/`)
Fetches and caches application metadata from the API on startup. Provides categories, content metadata, and app configuration to the rest of the app. Supports background refresh with callback notification to the `HomeCubit`.

### Authentication (`features/auth/`)
User authentication with login/register flows. Manages auth tokens via `flutter_secure_storage`. Provides `SubscriptionCubit` as a global provider that tracks guest vs. premium user state using Freezed sealed states (`SubscriptionGuest`, `SubscriptionPremium`).

### Categories (`features/categories/`)
Manages category data and classification entities. Categories have three types: `image`, `video`, and `classification`. Classification categories contain sub-groups that can be browsed individually on a dedicated detail page with its own pagination.

### Wallpapers (`features/wallpapers/`)
Handles wallpaper grid display with support for both image and video content. Video wallpapers use `video_player` with `visibility_detector` for lifecycle management. Paginated loading with `PaginatedResponse<T>`.

### Wallpaper Detail (`features/wallpaper_detail/`)
Full-screen wallpaper preview with `PageView` swipe navigation. Features video playback (auto-play, loop, mute toggle), similar wallpapers discovery via bottom sheet, phone frame preview mode, and integration with download and favorite actions.

### Downloads (`features/downloads/`)
Downloads wallpapers to the device gallery using the `gal` package. Manages download history via Hive local storage. Handles storage permissions through `permission_handler`. Tracks download progress with real-time UI updates.

### Favorites (`features/favorites/`)
Local-first favorites with remote sync for premium users. Toggle functionality with optimistic UI updates. Guest users store favorites locally in Hive; premium users sync to the backend with merge capability on login.

### Home (`features/home/`)
Main application screen with category tab selector, content switcher (wallpaper grids / classification grids), navigation drawer with links to favorites, downloads, premium, about, privacy policy, and terms of use. Hosts the `HomeCubit` which orchestrates category selection and content loading.

### Premium (`features/premium/`)
In-app purchase management using the `in_app_purchase` package. Displays subscription products (monthly/yearly), handles purchase flow, receipt verification with backend, and purchase restoration. Integrates with `SubscriptionCubit` to toggle premium state.

### Notifications (`features/notifications/`)
Firebase Cloud Messaging integration with local notification fallback. Supports deep linking from notification payloads to specific app routes. Handles notification permissions and stores preference state in Hive.

### Splash (`features/splash/`)
Initial loading screen that validates auth tokens, initializes services, and navigates to the home page.

## State Management

The app uses **flutter_bloc** with **Cubits** (not full Blocs) for state management. States are modeled with **Freezed** for immutability and `copyWith` support.

### Content Status Pattern

All content-driven screens follow a 4-state pattern:

```dart
enum Status { loading, success, error, empty }
```

Each state maps to a dedicated UI widget: shimmer placeholder, content view, error with retry, or empty state with illustration.

### Global vs. Scoped Cubits

| Cubit | Scope | Provided By |
|---|---|---|
| `SubscriptionCubit` | Global | `app.dart` |
| `HomeCubit` | Home route | GoRouter builder |
| `WallpaperDetailCubit` | Detail route | GoRouter builder |
| `ClassificationDetailCubit` | Classification route | GoRouter builder |
| `DownloadCubit` | Detail / Downloads route | GoRouter builder |
| `FavoriteCubit` | Detail / Favorites route | GoRouter builder |
| `PremiumCubit` | Premium route | GoRouter builder |

## Error Handling

All repository methods return `Either<Failure, T>` from the `dartz` package:

```dart
Future<Either<Failure, List<WallpaperEntity>>> getWallpapers(...);
```

### Failure Types

| Type | Trigger |
|---|---|
| `ServerFailure` | API errors (non-2xx responses) |
| `CacheFailure` | Hive read/write failures |
| `NetworkFailure` | No internet connection |
| `UnauthorizedFailure` | 401 responses, expired tokens |
| `CancelledFailure` | Dio request cancellation |

Cubits fold the `Either` result to emit appropriate states:

```dart
result.fold(
  (failure) => emit(state.copyWith(status: Status.error, errorMessage: failure.message)),
  (data) => emit(state.copyWith(status: Status.success, items: data)),
);
```

## Theming

Material 3 light and dark themes are defined in `lib/core/theme/`:

- **`app_theme.dart`** -- `ThemeData` for light and dark modes with custom color schemes, text themes, AppBar styling, and card themes
- **`colors.dart`** -- `AppColors` with named constants for both light and dark palettes
- **`typography.dart`** -- `AppTextStyles` using Google Fonts (Poppins family)

Theme mode follows the system preference via `ThemeMode.system`.

**Convention:** No inline colors or text styles. All values reference `AppColors`, `AppTextStyles`, or `Theme.of(context)`.

## Responsive Design

All dimensions use **flutter_screenutil** extensions:

| Extension | Purpose |
|---|---|
| `.w` | Width-based scaling |
| `.h` | Height-based scaling |
| `.sp` | Font size scaling |
| `.r` | Radius scaling |

Predefined constants in `AppDimens` provide consistent spacing, radii, icon sizes, and component dimensions across the app.

**Convention:** `AutoSizeText` is used instead of `Text` for all user-facing text to handle overflow gracefully.

## Monetization

### AdMob (Free Users)

- **Banner ads** on the home page bottom navigation bar
- **Rewarded ads** for gated content access
- **App open ads** on app launch
- Centralized via `AdHelper` singleton in `lib/core/services/ad_helper.dart`
- Ad frequency tracked in Hive to prevent over-serving
- Ads are disabled when user has premium subscription

### In-App Purchases (Premium)

- Monthly and yearly subscription options
- Purchase flow handled by `PremiumCubit`
- Receipt verification with backend API
- Purchase restoration support
- Premium state managed globally by `SubscriptionCubit`

### Analytics

Firebase Analytics logs events for:
- Wallpaper previews and downloads
- Favorite toggles
- Similar wallpaper views
- Ad impressions and interactions
- Subscription purchases

## Notifications

- **Firebase Cloud Messaging** for remote push notifications
- **flutter_local_notifications** for foreground notification display
- Deep linking from notification payloads to specific routes (e.g., wallpaper detail, category)
- Pending route redirect handled in GoRouter's `redirect` callback
- Permission request state persisted in Hive `notification_prefs` box

## Testing

Tests are located in the `test/` directory and use `mocktail` for mocking and `bloc_test` for Cubit verification.

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/features/premium/presentation/cubit/premium_cubit_test.dart
```

Current test coverage includes:
- Premium repository implementation
- Premium use cases (get products, purchase, subscription status, restore)
- Premium cubit state transitions
- Notification service implementation

## Code Style & Conventions

### Mandatory Rules

- **AutoSizeText** over `Text` for all UI text
- **CachedNetworkImage** over `Image.network`
- **ScreenUtil** extensions (`.w`, `.h`, `.sp`, `.r`) for all dimensions
- **dartz Either** for all repository return types
- **loader_overlay + flutter_spinkit** for loading states
- No hardcoded colors, sizes, strings, or API URLs
- No `print()` statements -- use `dart:developer` `log()` or Firebase Crashlytics

### Quality Gates

```bash
# Static analysis (must pass with zero warnings)
flutter analyze

# Format code
dart format .

# Generate code (after model changes)
dart run build_runner build --delete-conflicting-outputs
```

### Dependency Injection

All dependencies are registered in `lib/core/di/injection_container.dart` using GetIt. Two Dio instances are configured:
- **Authenticated Dio** -- includes `AuthInterceptor` for token injection
- **Public Dio** (named `publicDio`) -- for unauthenticated endpoints (bootstrap, categories, wallpapers)

## License

All rights reserved.
