# Glowy Wallpapers — Project Roadmap

## Executive Summary

**Glowy Wallpapers** is a cross-platform mobile wallpaper app built with Flutter for Android and iOS. Users browse high-quality wallpapers organized by categories — static images, looping videos, and thematic classifications — download them to their device, save favorites, and preview wallpapers in a phone frame mockup before setting them.

The app follows a freemium monetization model: free users see AdMob ads (banner on home, rewarded ads gating downloads and previews, and an app-open ad on launch), while premium subscribers via Stripe enjoy a fully ad-free experience. Firebase Cloud Messaging powers push notifications to drive engagement and re-engagement.

### Tech Stack

| Layer                | Technology                                    |
| -------------------- | --------------------------------------------- |
| Framework            | Flutter 3.41.5 (Dart 3.11.3)                  |
| Architecture         | Clean Architecture, feature-first             |
| State Management     | Bloc / Cubit (Freezed states)                 |
| Dependency Injection | Injectable + GetIt                            |
| Networking           | Dio + Retrofit (code-gen)                     |
| Navigation           | GoRouter                                      |
| Local Storage        | Hive (cache), flutter_secure_storage (tokens) |
| Error Handling       | dartz Either\<Failure, T\>                    |
| Ads                  | Google AdMob (banner, rewarded, app open)     |
| Payments             | Stripe via flutter_stripe                     |
| Notifications        | Firebase Cloud Messaging                      |
| Environment          | Envied (dev / staging / prod flavors)         |

### Monetization

| Ad Format           | Placement                            | Audience                |
| ------------------- | ------------------------------------ | ----------------------- |
| App Open Ad         | On cold start, after splash          | Free users              |
| Banner Ad           | Bottom of Home screen                | Free users              |
| Rewarded Ad         | Before download and preview actions  | Free users              |
| Stripe Subscription | Monthly premium plan removes all ads | Converts free → premium |

---

## Phase 1 — Foundation & Scaffolding

> Set up the Flutter project, Clean Architecture folders, core infrastructure, and native splash. The app compiles and navigates from splash to an empty Home shell.

| #    | Task                 | Description                                                                                 |
| ---- | -------------------- | ------------------------------------------------------------------------------------------- |
| 1.1  | Project Creation     | Create Flutter project, install all packages, configure min SDK versions                    |
| 1.2  | Folder Structure     | Scaffold the full feature-first Clean Architecture tree (10 features × 3 layers)            |
| 1.3  | Error Handling       | `Failure` base class + `ServerFailure`, `CacheFailure`, `NetworkFailure`; custom exceptions |
| 1.4  | Environment Config   | Envied setup for dev/staging/prod with API keys, AdMob IDs, Stripe keys                     |
| 1.5  | Dependency Injection | Injectable + GetIt wiring; `@module` for Dio, SharedPrefs, Hive, SecureStorage              |
| 1.6  | Network Layer        | Dio client factory, auth interceptor (token attachment), PrettyDioLogger (dev only)         |
| 1.7  | Theme & Styling      | Material 3 light/dark `ThemeData`, `AppColors`, `AppTextStyles` with Google Fonts           |
| 1.8  | Router Skeleton      | GoRouter with all placeholder routes, named route constants, initial → `/splash`            |
| 1.9  | Core Widgets         | `AppCachedImage`, `AppLoading`, `AppErrorWidget`, `AdaptiveGrid` (responsive columns)       |
| 1.10 | Native Splash        | `flutter_native_splash` config with branding; SplashPage initialization placeholder         |
| 1.11 | Main Entry Point     | Wire bindings → Hive → DI → Firebase → AdMob → `MaterialApp.router`                         |

**Exit Criteria:** App compiles on both platforms, shows native splash, navigates to empty Home screen.

---

## Phase 2 — Auth & User Profile

> Implement login/register, secure token management, user profile, subscription check on launch, and route protection via GoRouter auth guard.

| #   | Task                      | Description                                                                                                                     |
| --- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 2.1 | Auth Domain               | `UserEntity`, `AuthRepository` contract, use cases: Login, Register, Logout, GetCurrentUser, IsLoggedIn                         |
| 2.2 | Auth Data                 | Freezed models, Retrofit data source (`/auth/login`, `/auth/register`), SecureStorage local source, repository impl with Either |
| 2.3 | Auth Presentation         | `AuthCubit` + Freezed states, LoginPage, RegisterPage, reusable `AuthFormField` with validation                                 |
| 2.4 | Auth Interceptor          | Auto-attach `Authorization: Bearer` header; handle 401 → clear session → redirect to login                                      |
| 2.5 | Router Auth Guard         | GoRouter `redirect`: unauthenticated → `/login`; authenticated + on login → `/home`                                             |
| 2.6 | User Profile              | ProfilePage showing name, user ID, subscription badge; unsubscribe button (placeholder, wired in Phase 5)                       |
| 2.7 | Splash Subscription Check | Check login → call `/subscription/status` → store premium flag → show ad flag if free → navigate                                |
| 2.8 | Global Subscription Cubit | App-wide `SubscriptionCubit` (`free` / `premium`) provided at root; updated on check, purchase, cancel                          |

**Exit Criteria:** Users can register, log in, view profile. Protected routes redirect. Premium status checked on every cold start.

---

## Phase 3 — Home, Categories & Content Grids

> Build the Home screen with drawer, horizontal category selector, and dynamic grids that switch between image thumbnails, looping video thumbnails, and classification bento cards.

| #   | Task                      | Description                                                                                                                                        |
| --- | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 3.1 | Categories Domain         | `CategoryEntity` (with `CategoryType` enum: image/video/classification), `WallpaperEntity`, `ClassificationEntity`, repository contract, use cases |
| 3.2 | Categories Data           | Freezed models, Retrofit data source (categories, wallpapers, classifications), Hive cache for categories, stale-while-revalidate repo             |
| 3.3 | Home Cubit                | Fetch categories on init, track selected category, fetch content by type, pagination (page tracking, `hasReachedEnd`)                              |
| 3.4 | Home Page Layout          | AppBar (logo + profile icon), Drawer with all menu items, category list + content area, banner ad placeholder                                      |
| 3.5 | Image Grid                | `AdaptiveGrid` of `CachedNetworkImage` thumbnails, tap → wallpaper detail, infinite scroll pagination                                              |
| 3.6 | Video Grid                | `AdaptiveGrid` with `video_player` looping cells (muted, auto-play on visible, pause off-screen), tap → detail                                     |
| 3.7 | Classification Bento Grid | Mixed-size cards with thumbnail + name overlay + gradient, tap → classification detail                                                             |
| 3.8 | Classification Detail     | Full feature: Retrofit source → repo → cubit → page; grid of wallpapers in that classification with pagination                                     |
| 3.9 | Dynamic Content Switcher  | Switch grid type based on `selectedCategory.type` — image grid, video grid, or bento grid                                                          |

**Exit Criteria:** Users can browse categories, see different grid types per category, tap classifications to drill in. Pagination works.

---

## Phase 4 — Wallpaper Detail, Download & Favorites

> Full-screen wallpaper carousel with download to gallery, favorites (local-first + API sync), phone frame preview, and similar wallpapers bottom sheet.

| #   | Task                     | Description                                                                                                                  |
| --- | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------- |
| 4.1 | Detail Domain            | Repository contract for similar wallpapers, toggle favorite, download wallpaper; use cases for each                          |
| 4.2 | Detail Data              | Retrofit source (similar, favorites API), local source (Dio bytes download → `gal` gallery save, Hive tracking), repo impl   |
| 4.3 | Detail Cubit             | Init carousel with category wallpapers, toggle favorite (optimistic), download flow, load similar wallpapers                 |
| 4.4 | Detail Page (Carousel)   | Full-screen `PageView.builder` with `CachedNetworkImage`, overlay action bar (download, favorite, preview), swipe navigation |
| 4.5 | Download Flow            | Permission handling (Android 13+ / iOS), Dio download bytes → `gal.putImageBytes`, Hive metadata tracking, success toast     |
| 4.6 | Favorites Feature        | Full Clean Architecture: Hive local box + Retrofit API sync, local-first for instant UI, FavoritesPage grid, empty state     |
| 4.7 | My Downloads Feature     | Hive-only tracking, DownloadsPage grid from local metadata, empty state                                                      |
| 4.8 | Phone Frame Preview      | `PhonePreviewWidget` with device frame asset, wallpaper scaled inside, full-screen overlay, tap to dismiss                   |
| 4.9 | Similar Wallpapers Sheet | `DraggableScrollableSheet` with thumbnails from `/wallpapers/{id}/similar`, tap navigates to that wallpaper                  |

**Exit Criteria:** Users can swipe through wallpapers, download to gallery, favorite/unfavorite, preview in phone frame, browse similar wallpapers.

---

## Phase 5 — Monetization (AdMob & Stripe Premium)

> Integrate all ad formats and the Stripe premium subscription flow. Free users see ads; premium users enjoy ad-free experience. Unsubscribe reverts to free.

| #   | Task                 | Description                                                                                                                              |
| --- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 5.1 | AdMob Helper         | Centralized `AdHelper` singleton: load/show/dispose for banner, rewarded, app-open; `shouldShowAds` checks `SubscriptionCubit`           |
| 5.2 | Banner Ad (Home)     | `BannerAdWidget` at Home bottom, visible for free users, hidden for premium, proper lifecycle disposal                                   |
| 5.3 | Rewarded Ad Gates    | Gate download + preview in `WallpaperDetailCubit`: check premium → show rewarded → proceed only if reward earned; auto-preload next ad   |
| 5.4 | App Open Ad (Launch) | Load during splash init, show for free users before navigating to Home; graceful fallback if ad fails to load                            |
| 5.5 | Premium Domain       | `SubscriptionEntity`, `PremiumRepository` (create checkout, get status, cancel), use cases                                               |
| 5.6 | Stripe Integration   | Retrofit source → API returns `clientSecret` → `Stripe.instance.initPaymentSheet()` → `presentPaymentSheet()` → update SubscriptionCubit |
| 5.7 | Get Premium Page     | Feature comparison table (Free vs Premium), price, "Subscribe Now" button → Stripe flow, "Restore Purchase" button                       |
| 5.8 | Unsubscribe Flow     | Profile page: confirmation dialog → API cancel + Stripe cancel → revert `SubscriptionCubit` to free → ads reappear                       |

**Exit Criteria:** Banner ad on Home, rewarded ads gate downloads/previews, app open ad on launch. Stripe checkout works. Premium removes all ads. Unsubscribe restores them.

---

## Phase 6 — Firebase, Polish & Store Readiness

> Push notifications, side menu actions, error/empty/loading states, responsive polish, app icon, and store listing preparation.

| #   | Task                  | Description                                                                                                                  |
| --- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 6.1 | FCM Setup             | `flutterfire configure`, platform configs (google-services.json / GoogleService-Info.plist), `NotificationService` singleton |
| 6.2 | Notification Handling | Foreground in-app banner, background/terminated tap → deep link to correct screen via GoRouter                               |
| 6.3 | Side Menu Actions     | Rate App (url_launcher → store), Share App (share_plus), Send Feedback (mailto:), About page, Terms page                     |
| 6.4 | Error States          | Consistent pattern across all screens: loading → error (with retry) → empty (with illustration) → success                    |
| 6.5 | Loading Skeletons     | Shimmer placeholders matching content layout for categories, grids, and detail screen                                        |
| 6.6 | Responsive Polish     | Adaptive grid columns (2/3/4), constrained drawer width on tablets, proper aspect ratios, text scaling respect               |
| 6.7 | App Icon & Splash     | `flutter_launcher_icons` (adaptive icon Android, standard iOS), finalize `flutter_native_splash` branding                    |
| 6.8 | Store Metadata        | Play Store + App Store descriptions, ASO keywords, privacy policy, changelog, screenshot structure                           |
| 6.9 | Integration Testing   | Full end-to-end flow verification, `flutter analyze` zero warnings, code cleanup (no print, no TODOs, no unused imports)     |

**Exit Criteria:** Notifications work, all screens have proper states, app looks great across devices, store assets ready, code clean and production-ready.

---

## Implementation Order

```
Phase 1  ──►  Phase 2  ──►  Phase 3  ──►  Phase 4  ──►  Phase 5  ──►  Phase 6
Foundation    Auth &        Home &        Detail,       AdMob &       Firebase,
& Scaffold    Profile       Categories    Downloads     Stripe        Polish &
                                          & Favorites   Premium       Store
```

Each phase builds on the previous one. Do not skip phases — later features depend on infrastructure established in earlier ones.

---

## Spec Kit Files Reference

```
.specify/
├── constitution.md          # Project-wide rules & conventions
├── spec.md                  # Full product specification
├── plan.md                  # Technical architecture & plan
└── tasks/
    ├── phase-1-foundation.md
    ├── phase-2-auth-profile.md
    ├── phase-3-home-categories.md
    ├── phase-4-detail-download-favorites.md
    ├── phase-5-monetization.md
    └── phase-6-firebase-polish.md
```
