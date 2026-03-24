# Tasks: Monetization — AdMob Ads & In-App Purchases

**Input**: Design documents from `/specs/005-admob-iap-monetization/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Included — Constitution Principle VII mandates unit tests for every use case, repository implementation, and Cubit.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story (US1, US2, US3, US4)
- Exact file paths included

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add dependencies, env config, Hive boxes, and constants needed by all stories

- [X] T001 Add `in_app_purchase: ^3.2.0` to `pubspec.yaml` and run `flutter pub get`
- [X] T002 Add ad unit ID fields (`ADMOB_BANNER_ID`, `ADMOB_REWARDED_ID`, `ADMOB_APP_OPEN_ID`) and IAP product ID fields (`IAP_MONTHLY_PRODUCT_ID`, `IAP_YEARLY_PRODUCT_ID`) to `lib/core/config/env.dart` via Envied
- [X] T003 [P] Add the new env variables with Google test ad unit IDs to `.env.dev`, `.env.staging`, `.env.prod`
- [X] T004 [P] Open `subscription_cache` and `ad_frequency` Hive boxes in `lib/main.dart` alongside existing box initializations
- [X] T005 [P] Add premium/monetization string constants to `lib/core/utils/app_strings.dart` (error messages, button labels, feature comparison text, ad unavailable message)

**Checkpoint**: Dependencies installed, env config extended, Hive boxes ready. Run `flutter pub get` and `flutter analyze` to confirm zero warnings.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, data layer, AdHelper, and DI wiring that ALL user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

### Domain Layer

- [X] T006 [P] Create `SubscriptionEntity` with status enum (`free`/`premium`), productId, purchaseToken, verificationState enum (`verified`/`pending`/`unverified`), expiryDate, lastVerifiedAt in `lib/features/premium/domain/entities/subscription_entity.dart`
- [X] T007 [P] Create `PremiumProductEntity` with productId, title, price, billingPeriod enum (`monthly`/`yearly`), rawPrice in `lib/features/premium/domain/entities/premium_product_entity.dart`
- [X] T008 Create `PremiumRepository` abstract contract with `getProducts()`, `purchasePremium()`, `restorePurchases()`, `getSubscriptionStatus()`, `getCachedSubscription()` — all returning `Future<Either<Failure, T>>` — in `lib/features/premium/domain/repositories/premium_repository.dart`
- [X] T009 [P] Create `SubscriptionCacheModel` (Freezed) with JSON serialization and a `toEntity()`/`fromEntity()` mapper in `lib/features/premium/data/models/subscription_cache_model.dart`
- [X] T010 [P] Create `PremiumProductModel` (Freezed) with `fromProductDetails()` factory that maps `in_app_purchase` `ProductDetails` to entity in `lib/features/premium/data/models/premium_product_model.dart`
- [X] T011 [P] Create `PremiumLocalSource` — reads/writes `subscription_cache` Hive box (get, save, clear, check 7-day TTL), reads/writes `ad_frequency` box (last app-open shown timestamp) in `lib/features/premium/data/datasources/premium_local_source.dart`
- [X] T012 [P] Create `PremiumRemoteSource` — Retrofit interface for `POST /api/v1/subscription/verify` and `GET /api/v1/subscription/status` per contracts/subscription-verify.md in `lib/features/premium/data/datasources/premium_remote_source.dart`
- [X] T013 [P] Create `IAPDataSource` — wraps `InAppPurchase.instance`: `queryProducts(productIds)`, `buySubscription(productDetails)`, `restorePurchases()`, listens to `purchaseStream` in `lib/features/premium/data/datasources/iap_data_source.dart`
- [X] T014 Create `PremiumRepositoryImpl` implementing `PremiumRepository` — orchestrates IAPDataSource + PremiumRemoteSource + PremiumLocalSource per contracts/iap-interface.md purchase/restore flows, including optimistic grant on verification failure in `lib/features/premium/data/repositories/premium_repository_impl.dart`
- [X] T015 Create `AdHelper` singleton in `lib/core/services/ad_helper.dart` per contracts/ad-helper-interface.md — `initialize()`, `loadBannerAd()`, `disposeBannerAd()`, `showAppOpenAd()` with 4h frequency cap via Hive `ad_frequency` box, `showRewardedAd({action})` with auto-preload, `shouldShowAds` getter reading `SubscriptionCubit`, `dispose()`, and Firebase Analytics event logging (`ad_shown`, `reward_earned`)
- [X] T016 Register all new dependencies in `lib/core/di/injection_container.dart`: AdHelper (singleton), IAPDataSource, PremiumRemoteSource, PremiumLocalSource, PremiumRepositoryImpl, and all use cases (T017–T020)
- [X] T017 Run `dart run build_runner build --delete-conflicting-outputs` to generate Freezed, Retrofit, and Injectable code for all new models and data sources

**Checkpoint**: Foundation ready — all entities, data sources, repository, and AdHelper compiled. Run `flutter analyze` to confirm zero warnings. User story implementation can now begin.

---

## Phase 3: User Story 1 — Free User Sees Ads Throughout App (Priority: P1) MVP

**Goal**: Free users see app-open ad on cold start (4h cap), banner ad on Home, and rewarded ad gates on download/preview actions.

**Independent Test**: Fresh install (no subscription), cold-start → app-open ad shown, Home → banner at bottom, tap Download → rewarded ad → download proceeds, tap Preview → rewarded ad → preview opens.

### Implementation

- [X] T018 [US1] Create `BannerAdWidget` that uses `AdHelper.loadBannerAd()` and disposes via `AdHelper.disposeBannerAd()` on widget disposal, hidden when `shouldShowAds == false`, in `lib/core/widgets/banner_ad_widget.dart`
- [X] T019 [US1] Replace the banner ad placeholder in `lib/features/home/presentation/pages/home_page.dart` — swap the hardcoded `SizedBox` + `AppStrings.adPlaceholder` container with `BannerAdWidget`, conditionally shown via `SubscriptionCubit.shouldShowAds`
- [X] T020 [US1] Replace `adGatePlaceholder()` in `lib/core/widgets/ad_gate_placeholder.dart` with real implementation that calls `AdHelper.showRewardedAd(action: action)` — returns `true` for premium users, shows rewarded ad for free users, shows "ad unavailable" snackbar if ad not loaded
- [X] T021 [US1] Integrate app-open ad in `lib/features/splash/presentation/pages/splash_page.dart` — after `subscriptionCubit.checkStatus()` completes, call `AdHelper.showAppOpenAd()` for free users before navigating to Home; skip if premium or ad not ready
- [X] T022 [US1] Wire rewarded ad gate for phone-frame preview action in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` — wrap preview button tap with `AdHelper.showRewardedAd(action: 'preview')`, only open preview if reward earned or user is premium

**Checkpoint**: Free user sees all 3 ad types. Premium user (from Phase 2 subscription check) sees zero ads. Download and preview gated correctly.

---

## Phase 4: User Story 2 — User Purchases Premium Subscription (Priority: P1)

**Goal**: Get Premium screen with monthly/yearly plan selection, native purchase flow, server-side receipt verification, and immediate ad removal on premium grant.

**Independent Test**: Open Get Premium → see prices from store → select plan → Subscribe Now → platform payment → premium granted → all ads disappear → downloads/previews ungated.

### Use Cases

- [X] T023 [P] [US2] Create `GetProducts` use case calling `PremiumRepository.getProducts()` in `lib/features/premium/domain/usecases/get_products.dart`
- [X] T024 [P] [US2] Create `PurchasePremium` use case calling `PremiumRepository.purchasePremium(product)` in `lib/features/premium/domain/usecases/purchase_premium.dart`
- [X] T025 [P] [US2] Create `GetSubscriptionStatus` use case calling `PremiumRepository.getSubscriptionStatus()` in `lib/features/premium/domain/usecases/get_subscription_status.dart`

### Presentation — Cubit

- [X] T026 [US2] Create `PremiumState` (Freezed) with states: initial, productsLoading, productsLoaded(products, selectedProduct), purchasing, purchaseSuccess(subscription), purchaseError(message), purchasePending in `lib/features/premium/presentation/cubit/premium_state.dart`
- [X] T027 [US2] Create `PremiumCubit` with methods: `loadProducts()`, `selectProduct(product)`, `purchase()` — calls GetProducts, PurchasePremium use cases, updates SubscriptionCubit on success, logs `purchase_initiated` and `purchase_succeeded` analytics events in `lib/features/premium/presentation/cubit/premium_cubit.dart`

### Presentation — Page & Widgets

- [X] T028 [P] [US2] Create `FeatureComparisonWidget` showing Free vs Premium comparison table (ads, downloads, previews) using `AutoSizeText` and theme colors in `lib/features/premium/presentation/widgets/feature_comparison_widget.dart`
- [X] T029 [P] [US2] Create `PlanCardWidget` showing product title, price, billing period with selection highlight state, using ScreenUtil dimensions in `lib/features/premium/presentation/widgets/plan_card_widget.dart`
- [X] T030 [US2] Create `GetPremiumPage` with four-state pattern (loading/error/empty/success): `FeatureComparisonWidget` at top, monthly + yearly `PlanCardWidget` selectors, "Subscribe Now" button (disabled during purchase), error/pending states per spec edge cases in `lib/features/premium/presentation/pages/get_premium_page.dart`

### Wiring

- [X] T031 [US2] Register `PremiumCubit` in DI (`lib/core/di/injection_container.dart`) and add the `/premium` route in `lib/core/routes/app_router.dart` to navigate to `GetPremiumPage` with `BlocProvider<PremiumCubit>`
- [X] T032 [US2] Extend `SubscriptionCubit` in `lib/features/auth/presentation/cubit/subscription_cubit.dart` — add `setPremiumFromSubscription(SubscriptionEntity)` method so PremiumCubit can update global premium state after purchase; ensure `shouldShowAds` reacts immediately
- [X] T033 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to generate Freezed code for `PremiumState`

**Checkpoint**: Full purchase flow works end-to-end. Ads disappear after successful subscription. Subscribe Now button disabled during in-flight transaction.

---

## Phase 5: User Story 3 — User Restores a Previous Purchase (Priority: P2)

**Goal**: Restore Purchase button on Get Premium screen re-verifies existing platform subscriptions and re-grants premium.

**Independent Test**: Fresh install on a device with previous subscription → open Get Premium → tap Restore → premium restored → ads removed.

### Use Case

- [X] T034 [US3] Create `RestorePurchases` use case calling `PremiumRepository.restorePurchases()` in `lib/features/premium/domain/usecases/restore_purchases.dart`

### Wiring

- [X] T035 [US3] Add restore flow to `PremiumCubit` — add `restoring` and `restoreSuccess`/`restoreError`/`restoreNotFound` states to `PremiumState`, add `restore()` method that calls RestorePurchases use case, updates SubscriptionCubit on success, logs `restore_succeeded` analytics event in `lib/features/premium/presentation/cubit/premium_cubit.dart` and `lib/features/premium/presentation/cubit/premium_state.dart`
- [X] T036 [US3] Add "Restore Purchase" button to `GetPremiumPage` — shown below Subscribe Now, triggers `PremiumCubit.restore()`, shows loading state during restore, displays success/not-found/error messages per contracts/iap-interface.md error states in `lib/features/premium/presentation/pages/get_premium_page.dart`
- [X] T037 [US3] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate Freezed code for updated `PremiumState`

**Checkpoint**: Restore Purchase works on fresh install. "No active subscription" shown when no subscription exists. Network error handled gracefully.

---

## Phase 6: User Story 4 — Premium User Manages or Cancels Subscription (Priority: P3)

**Goal**: Profile page "Manage Subscription" button deep-links to platform store. Lapsed subscription detected on cold start.

**Independent Test**: Premium account → Profile → Manage Subscription → platform store opens. Cancel externally → cold-start → ads return.

### Implementation

- [X] T038 [US4] Add "Manage Subscription" button to the profile page — visible only when `SubscriptionCubit.isPremium`, opens platform-specific subscription management URL via `url_launcher` (Play Store deep link on Android, App Store on iOS) in the profile page under `lib/features/auth/presentation/pages/` or `lib/features/settings/presentation/pages/`
- [X] T039 [US4] Wire cold-start lapse detection in `lib/features/splash/presentation/pages/splash_page.dart` — after `subscriptionCubit.checkStatus()`, if subscription was previously premium but `getSubscriptionStatus()` returns free (or pending receipt re-verification fails), revert to guest state and ensure ads are re-enabled via `SubscriptionCubit`
- [X] T040 [US4] Wire 7-day cache TTL check in `SubscriptionCubit.checkStatus()` — if cached premium is older than 7 days and network is unavailable, treat user as free; if network available, call `getSubscriptionStatus()` to refresh in `lib/features/auth/presentation/cubit/subscription_cubit.dart`

**Checkpoint**: Manage Subscription opens correct platform page. Lapsed subscriptions detected within one cold start. 7-day offline cache works correctly.

---

## Phase 7: Unit Tests

**Purpose**: Constitution Principle VII — unit tests for all use cases, repository impl, and cubits

- [X] T041 [P] Create `GetProducts` use case unit test in `test/features/premium/domain/usecases/get_products_test.dart`
- [X] T042 [P] Create `PurchasePremium` use case unit test in `test/features/premium/domain/usecases/purchase_premium_test.dart`
- [X] T043 [P] Create `RestorePurchases` use case unit test in `test/features/premium/domain/usecases/restore_purchases_test.dart`
- [X] T044 [P] Create `GetSubscriptionStatus` use case unit test in `test/features/premium/domain/usecases/get_subscription_status_test.dart`
- [X] T045 [P] Create `PremiumRepositoryImpl` unit test covering purchase flow (verified, pending/optimistic, error), restore flow (found, not found, network error), and cache TTL logic in `test/features/premium/data/repositories/premium_repository_impl_test.dart`
- [X] T046 [P] Create `PremiumCubit` unit test with `bloc_test` covering: loadProducts, selectProduct, purchase (success/error/pending), restore (success/not found/error), analytics event emission in `test/features/premium/presentation/cubit/premium_cubit_test.dart`

**Checkpoint**: All tests pass. Run `flutter test` to confirm.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, code quality, and integration verification

- [X] T047 Run `dart run build_runner build --delete-conflicting-outputs` — final code generation pass for all Freezed/Retrofit/Injectable artifacts
- [X] T048 Run `flutter analyze` and fix any warnings — ensure zero warnings per Constitution Principle VII
- [X] T049 Run `dart format .` to ensure consistent formatting across all new and modified files
- [X] T050 Verify the full quickstart.md flow end-to-end: cold-start ad → banner → rewarded gate → purchase → ads disappear → restore on fresh install → manage subscription deep link

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1: Ads (Phase 3)**: Depends on Phase 2 (needs AdHelper + entities)
- **US2: Purchase (Phase 4)**: Depends on Phase 2 (needs repository + IAP data source)
- **US3: Restore (Phase 5)**: Depends on Phase 4 (extends PremiumCubit + GetPremiumPage)
- **US4: Manage (Phase 6)**: Depends on Phase 2 (needs SubscriptionCubit extensions); can run in parallel with Phase 3–5
- **Tests (Phase 7)**: Depends on Phase 2–6 (tests the implementations)
- **Polish (Phase 8)**: Depends on all prior phases

### User Story Independence

- **US1 (Ads)** and **US2 (Purchase)**: Can run in parallel after Phase 2 (different files)
- **US3 (Restore)**: Depends on US2 (extends same cubit and page)
- **US4 (Manage)**: Independent of US1–US3; can start after Phase 2

### Within Each User Story

- Models → data sources → repository → use cases → cubit → page (Clean Architecture order)
- [P]-marked tasks within a phase can run in parallel

### Parallel Opportunities

```
After Phase 2 completes:

  ┌─► Phase 3 (US1: Ads)          ─── T018–T022
  │
  ├─► Phase 4 (US2: Purchase)     ─── T023–T033
  │     └─► Phase 5 (US3: Restore) ── T034–T037
  │
  └─► Phase 6 (US4: Manage)       ─── T038–T040

After all stories:
  └─► Phase 7 (Tests)             ─── T041–T046 (all [P])
      └─► Phase 8 (Polish)        ─── T047–T050
```

---

## Implementation Strategy

### MVP First (US1 + US2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: US1 — Free users see ads
4. Complete Phase 4: US2 — Purchase flow works
5. **STOP and VALIDATE**: Ads show, purchase removes them, full monetization loop works
6. Deploy/demo

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (Ads) → Test: ads appear for free users → Revenue starts
3. Add US2 (Purchase) → Test: end-to-end purchase → Premium conversions enabled
4. Add US3 (Restore) → Test: fresh install restore → Store compliance met
5. Add US4 (Manage) → Test: deep link works → Full compliance
6. Add Tests + Polish → Production ready

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Constitution Principle VIII: All ad operations through AdHelper singleton
- Constitution Principle V: All repo methods return `Either<Failure, T>`
- Constitution Principle VII: Unit tests mandatory — Phase 7 covers all use cases, repo, and cubit
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
