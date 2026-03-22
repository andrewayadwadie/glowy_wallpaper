# Tasks: Auth & User Profile

**Input**: Design documents from `/specs/002-auth-user-profile/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Constitution requires unit tests (Principle VII). Test tasks included for cubits, repositories, and use cases.

**Organization**: Tasks are grouped by user story. Each task includes explicit instructions so a cheaper LLM can implement without ambiguity.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add auth-related string constants, new route constants, and Hive box registration needed by all user stories.

- [X] T001 Update `lib/core/utils/app_strings.dart` to add auth-related string constants. Add these static const String fields to the `AppStrings` class: `login` = `'Login'`, `register` = `'Register'`, `logout` = `'Logout'`, `email` = `'Email'`, `password` = `'Password'`, `confirmPassword` = `'Confirm Password'`, `displayName` = `'Display Name'`, `loginTitle` = `'Welcome Back'`, `registerTitle` = `'Create Account'`, `emailRequired` = `'Email is required'`, `emailInvalid` = `'Please enter a valid email'`, `passwordRequired` = `'Password is required'`, `passwordWeak` = `'Password must be at least 8 characters with one uppercase letter and one number'`, `passwordMismatch` = `'Passwords do not match'`, `nameRequired` = `'Name is required'`, `invalidCredentials` = `'Invalid email or password'`, `emailAlreadyInUse` = `'Email already in use'`, `noAccount` = `"Don't have an account? Register"`, `hasAccount` = `'Already have an account? Login'`, `logoutConfirm` = `'Are you sure you want to log out?'`, `unsubscribe` = `'Unsubscribe'`, `unsubscribeConfirm` = `'Are you sure you want to unsubscribe?'`, `premiumBadge` = `'Premium'`, `guestBadge` = `'Guest'`, `profilePromptTitle` = `'Log in or Register to access your profile'`, `profilePromptSubtitle` = `'Unlock premium wallpapers, ad-free experience, and more'`, `premiumFeature` = `'Premium Feature'`, `premiumActionPrompt` = `'Log in or register to access this feature'`, `adFreeExperience` = `'Ad-free experience'`, `accessPremiumWallpapers` = `'Access premium wallpapers'`, `priorityDownloads` = `'Priority downloads'`, `loginLockedOut` = `'Too many attempts. Try again in'`, `seconds` = `'seconds'`.

- [X] T002 [P] Update `lib/core/routes/routes.dart` to add missing auth routes if not already present. Ensure `AppRoutes` has: `splash` = `'/splash'`, `home` = `'/'`, `login` = `'/login'`, `register` = `'/register'`, `profile` = `'/profile'`. Note: Change `home` from `'/home'` to `'/'` since Home is the root route now (no auth gate). If it's already `'/'`, leave it. If it's `'/home'`, change it.

- [X] T003 [P] Update `lib/core/api/server_strings.dart` to add auth endpoint paths. Add to the `ServerStrings` class: `subscriptionStatus` = `'/subscription/status'` (if not already present), `unsubscribe` = `'/subscription/unsubscribe'`. Verify `login`, `register`, `logout` are already present from Phase 1.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, repository contracts, data models, data sources, and DI registration that ALL user stories depend on.

**CRITICAL**: No user story work can begin until this phase is complete.

### Domain Layer

- [X] T004 Create `UserEntity` in `lib/features/auth/domain/entities/user_entity.dart`. Define a class `UserEntity` that extends `Equatable`. Fields: `final String id`, `final String displayName`, `final String email`, `final bool isPremium`. Constructor: `const UserEntity({required this.id, required this.displayName, required this.email, required this.isPremium})`. Override `props`: `[id, displayName, email, isPremium]`. Import `package:equatable/equatable.dart`.

- [X] T005 [P] Create `AuthRepository` contract in `lib/features/auth/domain/repositories/auth_repository.dart`. Define `abstract class AuthRepository` with these methods: `Future<Either<Failure, UserEntity>> login({required String email, required String password})`, `Future<Either<Failure, UserEntity>> register({required String displayName, required String email, required String password})`, `Future<Either<Failure, void>> logout()`, `Future<Either<Failure, bool>> validateToken()`, `Future<Either<Failure, UserEntity?>> getCachedUser()`, `Future<Either<Failure, void>> unsubscribe()`, `Future<bool> hasToken()`. Import `dartz`, `failure.dart`, and `user_entity.dart`.

- [X] T006 [P] Create `Login` use case in `lib/features/auth/domain/usecases/login.dart`. Define `class LoginParams extends Equatable` with `final String email` and `final String password`, `props => [email, password]`. Define `class Login extends UseCase<UserEntity, LoginParams>` that takes `AuthRepository` in constructor and calls `repository.login(email: params.email, password: params.password)` in the `call` method. Import usecase base, auth_repository, user_entity.

- [X] T007 [P] Create `Register` use case in `lib/features/auth/domain/usecases/register.dart`. Define `class RegisterParams extends Equatable` with `final String displayName`, `final String email`, `final String password`, `props => [displayName, email, password]`. Define `class Register extends UseCase<UserEntity, RegisterParams>` that calls `repository.register(...)`. Import usecase base, auth_repository, user_entity.

- [X] T008 [P] Create `Logout` use case in `lib/features/auth/domain/usecases/logout.dart`. Define `class Logout extends UseCase<void, NoParams>` that calls `repository.logout()`. Import usecase base (which has NoParams), auth_repository.

- [X] T009 [P] Create `ValidateToken` use case in `lib/features/auth/domain/usecases/validate_token.dart`. Define `class ValidateToken extends UseCase<bool, NoParams>` that calls `repository.validateToken()`. Returns `Right(true)` if premium, `Right(false)` if guest/expired. Import usecase base, auth_repository.

- [X] T010 [P] Create `GetCachedUser` use case in `lib/features/auth/domain/usecases/get_cached_user.dart`. Define `class GetCachedUser extends UseCase<UserEntity?, NoParams>` that calls `repository.getCachedUser()`. Returns the cached user entity or null if no cached user. Import usecase base, auth_repository, user_entity.

- [X] T011 [P] Create `Unsubscribe` use case in `lib/features/auth/domain/usecases/unsubscribe.dart`. Define `class Unsubscribe extends UseCase<void, NoParams>` that calls `repository.unsubscribe()`. Import usecase base, auth_repository.

### Data Layer — Models

- [X] T012 [P] Create `UserModel` in `lib/features/auth/data/models/user_model.dart`. Use `@freezed` annotation. Define `class UserModel with _$UserModel` with factory constructor: `factory UserModel({required String id, @JsonKey(name: 'display_name') required String displayName, required String email, @JsonKey(name: 'is_premium') required bool isPremium}) = _UserModel`. Add `factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json)`. Add an extension method or a method inside the class: `UserEntity toEntity() => UserEntity(id: id, displayName: displayName, email: email, isPremium: isPremium)`. Add `part 'user_model.freezed.dart';` and `part 'user_model.g.dart';`. Import freezed_annotation, json_annotation, user_entity.

- [X] T013 [P] Create `AuthResponseModel` in `lib/features/auth/data/models/auth_response_model.dart`. Use `@freezed`. Define with factory: `factory AuthResponseModel({required String token, required UserModel user}) = _AuthResponseModel`. Add `fromJson` factory. Add `part` statements. Import freezed_annotation, json_annotation, user_model.

- [X] T014 [P] Create `LoginRequestModel` in `lib/features/auth/data/models/login_request_model.dart`. Use `@freezed`. Define with factory: `factory LoginRequestModel({required String email, required String password}) = _LoginRequestModel`. Add `toJson` method and `fromJson` factory. Add `part` statements. Import freezed_annotation, json_annotation.

- [X] T015 [P] Create `RegisterRequestModel` in `lib/features/auth/data/models/register_request_model.dart`. Use `@freezed`. Define with factory: `factory RegisterRequestModel({@JsonKey(name: 'display_name') required String displayName, required String email, required String password}) = _RegisterRequestModel`. Note: `confirmPassword` is NOT sent to server — it's validated client-side only. Add `toJson` and `fromJson`. Add `part` statements. Import freezed_annotation, json_annotation.

- [X] T016 [P] Create `SubscriptionStatusModel` in `lib/features/auth/data/models/subscription_status_model.dart`. Use `@freezed`. Define with factory: `factory SubscriptionStatusModel({@JsonKey(name: 'is_premium') required bool isPremium}) = _SubscriptionStatusModel`. Add `fromJson` factory. Add `part` statements. Import freezed_annotation, json_annotation.

### Data Layer — Data Sources

- [X] T017 Create `AuthRemoteDataSource` in `lib/features/auth/data/datasources/auth_remote_data_source.dart`. Use Retrofit annotation. Define `@RestApi() abstract class AuthRemoteDataSource` with constructor `factory AuthRemoteDataSource(Dio dio, {String baseUrl}) = _AuthRemoteDataSource`. Methods: `@POST('/auth/login') Future<AuthResponseModel> login(@Body() LoginRequestModel request)`, `@POST('/auth/register') Future<AuthResponseModel> register(@Body() RegisterRequestModel request)`, `@POST('/auth/logout') Future<void> logout()`, `@GET('/subscription/status') Future<SubscriptionStatusModel> getSubscriptionStatus()`, `@POST('/subscription/unsubscribe') Future<void> unsubscribe()`. Add `part 'auth_remote_data_source.g.dart';`. Import dio, retrofit, and all request/response models.

- [X] T018 [P] Create `AuthLocalDataSource` in `lib/features/auth/data/datasources/auth_local_data_source.dart`. Define `abstract class AuthLocalDataSource` with methods: `Future<void> saveToken(String token)`, `Future<String?> getToken()`, `Future<void> clearToken()`, `Future<void> saveUser(UserModel user)`, `Future<UserModel?> getCachedUser()`, `Future<void> clearUser()`, `Future<bool> hasToken()`. Then define `class AuthLocalDataSourceImpl implements AuthLocalDataSource` that takes `FlutterSecureStorage` and `Box` (Hive) in constructor. Implement: `saveToken` → `secureStorage.write(key: 'auth_token', value: token)`, `getToken` → `secureStorage.read(key: 'auth_token')`, `clearToken` → `secureStorage.delete(key: 'auth_token')`, `saveUser` → `box.put('current_user', user.toJson())`, `getCachedUser` → read from box, if not null `UserModel.fromJson(Map<String, dynamic>.from(box.get('current_user')))`, `clearUser` → `box.delete('current_user')`, `hasToken` → `(await getToken()) != null`. Import flutter_secure_storage, hive, user_model.

### Data Layer — Repository Implementation

- [X] T019 Create `AuthRepositoryImpl` in `lib/features/auth/data/repositories/auth_repository_impl.dart`. Define `class AuthRepositoryImpl implements AuthRepository` that takes `AuthRemoteDataSource`, `AuthLocalDataSource`, and `NetworkInfo` in constructor. Implement each method:

  **login**: Try: check `networkInfo.isConnected`, if not throw `NetworkException`. Call `remoteDataSource.login(LoginRequestModel(email: email, password: password))`. Save token via `localDataSource.saveToken(response.token)`. Save user via `localDataSource.saveUser(response.user)`. Return `Right(response.user.toEntity())`. Catch `ServerException` → `Left(ServerFailure(e.message))`, `NetworkException` → `Left(NetworkFailure(message))`.

  **register**: Same pattern as login but calls `remoteDataSource.register(RegisterRequestModel(...))`.

  **logout**: Try: call `remoteDataSource.logout()` (ignore failure — local-first). Then always: `localDataSource.clearToken()`, `localDataSource.clearUser()`. Return `Right(null)`. Catch any exception → still clear local data, return `Right(null)`.

  **validateToken**: Try: check `hasToken()` — if false return `Right(false)`. Call `remoteDataSource.getSubscriptionStatus()`. If `response.isPremium` return `Right(true)` else return `Right(false)`. Catch `UnauthorizedException` or DioException with 401 → `localDataSource.clearToken()`, `localDataSource.clearUser()`, return `Right(false)`. Catch network errors → try getCachedUser, if cached and isPremium return `Right(true)`, else `Right(false)`.

  **getCachedUser**: Try: `localDataSource.getCachedUser()` → if not null `Right(user.toEntity())` else `Right(null)`. Catch → `Left(CacheFailure(...))`.

  **unsubscribe**: Try: call `remoteDataSource.unsubscribe()`. `localDataSource.clearToken()`, `localDataSource.clearUser()`. Return `Right(null)`. Catch → `Left(ServerFailure(...))`.

  **hasToken**: delegate to `localDataSource.hasToken()`.

  Import all necessary: dartz, failure, exceptions, network_info, user_entity, auth_repository, data sources, models.

### DI Registration

- [X] T020 Update `lib/core/di/injection_container.dart` to register all auth dependencies. Add these registrations inside `configureDependencies()` (or in a new `_initAuthDependencies()` helper called from it):

  ```
  // Auth Data Sources
  sl.registerLazySingleton(() => Hive.box('user_cache'));  // Make sure this box is opened in main.dart
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl<Dio>()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl<FlutterSecureStorage>(), sl<Box>()));

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl(), sl()));

  // Auth Use Cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => ValidateToken(sl()));
  sl.registerLazySingleton(() => GetCachedUser(sl()));
  sl.registerLazySingleton(() => Unsubscribe(sl()));

  // Auth Cubits
  sl.registerFactory(() => AuthCubit(login: sl(), register: sl(), logout: sl()));
  sl.registerLazySingleton(() => SubscriptionCubit(validateToken: sl(), getCachedUser: sl(), unsubscribe: sl()));
  ```

  Also update `lib/main.dart` to open the Hive box before DI: add `await Hive.openBox('user_cache');` after `await Hive.initFlutter()` and before `await configureDependencies()`.

  Import all use cases, cubits, data sources, repositories, and hive.

### Code Generation

- [X] T021 Run `dart run build_runner build --delete-conflicting-outputs` to generate all `.freezed.dart`, `.g.dart` files for the new models and Retrofit data source. Verify no build errors. Fix any import issues that arise.

**Checkpoint**: Foundation ready — all domain entities, data layer, and DI are in place. User story implementation can now begin.

---

## Phase 3: User Story 1 — Guest Access to Home (Priority: P1) — MVP

**Goal**: All users (guest and premium) land on Home. Guest users see regular content only (premium items hidden, no badge/lock). Ads shown for guests.

**Independent Test**: Launch app without logging in → Home loads → premium items absent → ads visible.

### Implementation for User Story 1

- [X] T022 [P] [US1] Create `SubscriptionCubit` in `lib/features/auth/presentation/cubit/subscription_cubit.dart`. Define Freezed states in `lib/features/auth/presentation/cubit/subscription_state.dart`:

  ```dart
  @freezed
  class SubscriptionState with _$SubscriptionState {
    const factory SubscriptionState.guest() = SubscriptionGuest;
    const factory SubscriptionState.premium({required UserEntity user}) = SubscriptionPremium;
    const factory SubscriptionState.loading() = SubscriptionLoading;
  }
  ```

  The `SubscriptionCubit` takes `ValidateToken`, `GetCachedUser`, and `Unsubscribe` use cases. Methods:

  `Future<void> checkStatus()`: emit loading → call `validateToken(NoParams())` → fold: left → emit guest, right(true) → call getCachedUser → if user not null emit premium(user), right(false) → emit guest.

  `Future<void> performUnsubscribe()`: emit loading → call `unsubscribe(NoParams())` → fold: left → emit premium (re-emit current, show error via separate mechanism), right → emit guest.

  `void setGuest()`: emit guest.

  `void setPremium(UserEntity user)`: emit premium(user: user).

  `bool get isPremium` → `state is SubscriptionPremium`.

  `bool get shouldShowAds` → `!isPremium`.

  Import freezed, bloc, user_entity, use cases, noparams.

- [X] T023 [US1] Update `lib/features/splash/presentation/pages/splash_page.dart` to implement the token validation flow. In `_initializeApp()`, after existing init steps (Hive, DI, Firebase), add: (1) Get `SubscriptionCubit` from `sl<SubscriptionCubit>()`. (2) Call `await subscriptionCubit.checkStatus()`. (3) Navigate to Home: `if (mounted) context.go(AppRoutes.home)`. Remove the old `await Future.delayed(Duration(seconds: 2))` — the real init + token check replaces the artificial delay. Keep the try-catch for error handling with AppErrorWidget. The splash background stays `Color(0xFF121212)` with comment `// Matches native splash background - intentionally hardcoded`.

- [X] T024 [US1] Update `lib/features/home/presentation/pages/home_page.dart` to add the profile icon in the AppBar. Add an `actions` list to the `AppBar` with an `IconButton(icon: Icon(Icons.person_outline), onPressed: _onProfileTapped)`. The `_onProfileTapped` method checks `context.read<SubscriptionCubit>().isPremium`: if premium → `context.push(AppRoutes.profile)`, if guest → show `GuestProfileBottomSheet` (created in a later task, for now just call `showModalBottomSheet` with placeholder text). Import go_router, subscription_cubit, flutter_bloc.

- [X] T025 [US1] Update `lib/app.dart` to provide `SubscriptionCubit` at the app root. Wrap the `MaterialApp.router` with `BlocProvider<SubscriptionCubit>(create: (_) => sl<SubscriptionCubit>(), child: MaterialApp.router(...))`. Import flutter_bloc, subscription_cubit, injection_container.

**Checkpoint**: App launches → splash validates token (none exists) → Home loads as guest. Profile icon visible in AppBar. Premium content filtering will work once content grids exist (Phase 3 of roadmap).

---

## Phase 4: User Story 2 — User Registration (Priority: P2)

**Goal**: Guest registers → account created → token stored → navigated to Home as premium user.

**Independent Test**: Navigate to Register → fill valid form → tap Register → verify Home loads with premium status.

### Implementation for User Story 2

- [ ] T026 [P] [US2] Create `AuthCubit` in `lib/features/auth/presentation/cubit/auth_cubit.dart`. Define Freezed states in `lib/features/auth/presentation/cubit/auth_state.dart`:

  ```dart
  @freezed
  class AuthState with _$AuthState {
    const factory AuthState.initial() = AuthInitial;
    const factory AuthState.loading() = AuthLoading;
    const factory AuthState.authenticated({required UserEntity user}) = AuthAuthenticated;
    const factory AuthState.error({required String message}) = AuthError;
    const factory AuthState.lockedOut({required int remainingSeconds}) = AuthLockedOut;
  }
  ```

  The `AuthCubit` takes `Login`, `Register`, `Logout` use cases. Fields: `int _failedAttempts = 0`, `Timer? _lockoutTimer`.

  Methods:

  `Future<void> performLogin(String email, String password)`: if `_failedAttempts >= 5` → emit lockedOut, return. Emit loading → call `login(LoginParams(email: email, password: password))` → fold: left → `_failedAttempts++`, if `_failedAttempts >= 5` start 30s timer that decrements and emits lockedOut each second, on complete reset to 0 and emit initial; otherwise emit error(failure.message). Right → `_failedAttempts = 0`, emit authenticated(user).

  `Future<void> performRegister(String displayName, String email, String password)`: emit loading → call `register(RegisterParams(...))` → fold: left → emit error(failure.message), right → emit authenticated(user).

  `Future<void> performLogout()`: emit loading → call `logout(NoParams())` → emit initial.

  `@override Future<void> close()`: cancel `_lockoutTimer`, call `super.close()`.

  Import freezed, bloc, dart:async, use cases, user_entity, noparams.

- [ ] T027 [P] [US2] Create `AuthFormField` widget in `lib/features/auth/presentation/widgets/auth_form_field.dart`. A reusable `StatelessWidget` wrapping `TextFormField`. Parameters: `String label`, `String? hintText`, `TextEditingController controller`, `String? Function(String?)? validator`, `bool obscureText = false`, `VoidCallback? onToggleObscure` (for show/hide password), `TextInputType keyboardType = TextInputType.text`, `bool enabled = true`. The build method returns `TextFormField` with: `decoration: InputDecoration(labelText: label, hintText: hintText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)), contentPadding: EdgeInsets.symmetric(horizontal: AppDimens.paddingM, vertical: AppDimens.paddingM), suffixIcon: obscureText != null && onToggleObscure != null ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility), onPressed: onToggleObscure) : null)`, `style: Theme.of(context).textTheme.bodyLarge`, `controller: controller`, `validator: validator`, `obscureText: obscureText`, `enabled: enabled`, `autovalidateMode: AutovalidateMode.onUserInteraction`. Use `AutoSizeText` for the label if needed. Import app_dimens, flutter/material.dart.

- [ ] T028 [US2] Create `RegisterPage` in `lib/features/auth/presentation/pages/register_page.dart`. A `StatefulWidget`. Create `TextEditingController` fields: `_nameController`, `_emailController`, `_passwordController`, `_confirmPasswordController`. Create a `GlobalKey<FormState> _formKey`. Create `bool _obscurePassword = true`, `bool _obscureConfirm = true`.

  The `build` method returns a `BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>(), child: BlocConsumer<AuthCubit, AuthState>(listener: ..., builder: ...))`.

  **Listener**: on `AuthAuthenticated` → read `SubscriptionCubit` from context, call `subscriptionCubit.setPremium(state.user)`, then `context.go(AppRoutes.home)`. On `AuthError` → show SnackBar with `state.message`.

  **Builder**: return `Scaffold(body: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(AppDimens.paddingL), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...]))))`.

  Column children: (1) `SizedBox(height: 40.h)`, (2) `AutoSizeText(AppStrings.registerTitle, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center)`, (3) `Gap(AppDimens.paddingXL)`, (4) `AuthFormField(label: AppStrings.displayName, controller: _nameController, validator: (v) => v == null || v.isEmpty ? AppStrings.nameRequired : null)`, (5) `Gap(AppDimens.paddingM)`, (6) `AuthFormField(label: AppStrings.email, controller: _emailController, keyboardType: TextInputType.emailAddress, validator: _validateEmail)`, (7) `Gap(AppDimens.paddingM)`, (8) `AuthFormField(label: AppStrings.password, controller: _passwordController, obscureText: _obscurePassword, onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword), validator: _validatePassword)`, (9) `Gap(AppDimens.paddingM)`, (10) `AuthFormField(label: AppStrings.confirmPassword, controller: _confirmPasswordController, obscureText: _obscureConfirm, onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm), validator: (v) => v != _passwordController.text ? AppStrings.passwordMismatch : null)`, (11) `Gap(AppDimens.paddingXL)`, (12) Register button: `state is AuthLoading ? Center(child: AppLoading()) : CustomButton(text: AppStrings.register, onPressed: _formKey.currentState?.validate() == true ? () => context.read<AuthCubit>().performRegister(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text) : null)`, (13) `Gap(AppDimens.paddingM)`, (14) `TextButton(onPressed: () => context.go(AppRoutes.login), child: AutoSizeText(AppStrings.hasAccount))`.

  Validation methods: `_validateEmail(String? v)` → if null or empty return `AppStrings.emailRequired`, if not matching email regex return `AppStrings.emailInvalid`, else null. `_validatePassword(String? v)` → if null or empty return `AppStrings.passwordRequired`, if length < 8 or no uppercase or no digit return `AppStrings.passwordWeak`, else null.

  Dispose all controllers in `dispose()`. Import all necessary: flutter_bloc, go_router, auto_size_text, gap, flutter_screenutil, app_strings, app_dimens, auth_cubit, auth_state, subscription_cubit, auth_form_field, custom_button, app_loading, injection_container.

- [ ] T029 [US2] Update `lib/core/routes/app_router.dart` to add the `/register` route. Add a `GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage())`. Import register_page.dart.

**Checkpoint**: Guest can navigate to Register, fill form, create account, and land on Home as premium.

---

## Phase 5: User Story 3 — User Login (Priority: P3)

**Goal**: Returning user logs in → token stored → Home loads with premium status. Lockout after 5 failures.

**Independent Test**: Navigate to Login → enter valid credentials → verify Home as premium. Enter wrong credentials 5 times → verify 30s lockout.

### Implementation for User Story 3

- [ ] T030 [US3] Create `LoginPage` in `lib/features/auth/presentation/pages/login_page.dart`. A `StatefulWidget`. Create `_emailController`, `_passwordController`, `GlobalKey<FormState> _formKey`, `bool _obscurePassword = true`.

  The `build` method returns `BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>(), child: BlocConsumer<AuthCubit, AuthState>(listener: ..., builder: ...))`.

  **Listener**: on `AuthAuthenticated` → read `SubscriptionCubit`, call `subscriptionCubit.setPremium(state.user)`, then `context.go(AppRoutes.home)`. On `AuthError` → show SnackBar with `state.message`.

  **Builder**: return `Scaffold(body: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(AppDimens.paddingL), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...]))))`.

  Column children: (1) `SizedBox(height: 60.h)`, (2) `AutoSizeText(AppStrings.loginTitle, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center)`, (3) `Gap(AppDimens.paddingXL)`, (4) `AuthFormField(label: AppStrings.email, controller: _emailController, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.isEmpty ? AppStrings.emailRequired : null)`, (5) `Gap(AppDimens.paddingM)`, (6) `AuthFormField(label: AppStrings.password, controller: _passwordController, obscureText: _obscurePassword, onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword), validator: (v) => v == null || v.isEmpty ? AppStrings.passwordRequired : null)`, (7) `Gap(AppDimens.paddingXL)`, (8) Login button or lockout timer: if `state is AuthLockedOut` show `AutoSizeText('${AppStrings.loginLockedOut} ${(state as AuthLockedOut).remainingSeconds} ${AppStrings.seconds}', style: TextStyle(color: Theme.of(context).colorScheme.error))`, else if `state is AuthLoading` show `Center(child: AppLoading())`, else `CustomButton(text: AppStrings.login, onPressed: _formKey.currentState?.validate() == true ? () => context.read<AuthCubit>().performLogin(_emailController.text.trim(), _passwordController.text) : null)`, (9) `Gap(AppDimens.paddingM)`, (10) `TextButton(onPressed: () => context.go(AppRoutes.register), child: AutoSizeText(AppStrings.noAccount))`.

  Dispose controllers in `dispose()`. Import same dependencies as RegisterPage.

- [ ] T031 [US3] Update `lib/core/routes/app_router.dart` to add the `/login` route and auth redirect. Add `GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage())`. Add a `redirect` callback to the top-level `GoRouter`: `redirect: (context, state) { final subCubit = sl<SubscriptionCubit>(); final isPremium = subCubit.isPremium; final isAuthRoute = state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.register; if (isPremium && isAuthRoute) return AppRoutes.home; return null; }`. This ensures premium users are redirected away from login/register. Import subscription_cubit, login_page, injection_container.

**Checkpoint**: User can log in, get redirected to Home as premium. 5 wrong attempts → 30s lockout.

---

## Phase 6: User Story 4 — Token Validation on Launch (Priority: P4)

**Goal**: App launch validates stored token against server → applies correct status → Home loads accordingly.

**Independent Test**: Log in → close app → reopen → verify premium Home (no re-login). Revoke token → reopen → verify guest Home.

### Implementation for User Story 4

- [ ] T032 [US4] The token validation logic is already implemented in T023 (splash update) and T022 (SubscriptionCubit.checkStatus). Verify the full flow works end-to-end: (1) `SplashPage._initializeApp()` calls `subscriptionCubit.checkStatus()`. (2) `checkStatus()` calls `validateToken` use case. (3) `ValidateToken` calls `repository.validateToken()`. (4) `AuthRepositoryImpl.validateToken()` checks `hasToken()` → calls `remoteDataSource.getSubscriptionStatus()` → handles 401/network errors. (5) SubscriptionCubit emits guest or premium. (6) Splash navigates to Home. If any step is missing or broken, fix it. This is a verification/integration task, not a new file.

- [ ] T033 [US4] Update `lib/features/splash/presentation/pages/splash_page.dart` to handle the case where the token validation call fails due to network error. In the catch block of `_initializeApp()`, if the error is a network error and a cached user exists (call `sl<GetCachedUser>()(NoParams())`), use the cached status. If no cached user, proceed as guest. Ensure the splash does NOT show the error widget for network errors during token validation — it should silently default to guest and proceed.

**Checkpoint**: Token validation works on launch. Network errors gracefully default to guest.

---

## Phase 7: User Story 5 — Profile Icon Behavior (Priority: P5)

**Goal**: Profile icon shows bottom sheet for guests, Profile page for premium users. Profile page shows advantages and unsubscribe.

**Independent Test**: As guest → tap profile → bottom sheet. As premium → tap profile → Profile page with advantages and unsubscribe.

### Implementation for User Story 5

- [ ] T034 [P] [US5] Create `GuestProfileBottomSheet` in `lib/features/auth/presentation/widgets/guest_profile_bottom_sheet.dart`. A function `void showGuestProfileBottomSheet(BuildContext context)` that calls `showModalBottomSheet(context: context, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXL))), builder: (context) => Padding(padding: EdgeInsets.all(AppDimens.paddingL), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2.r))), Gap(AppDimens.paddingL), Icon(Icons.person_outline, size: 64.w, color: Theme.of(context).colorScheme.primary), Gap(AppDimens.paddingM), AutoSizeText(AppStrings.profilePromptTitle, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center), Gap(AppDimens.paddingS), AutoSizeText(AppStrings.profilePromptSubtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center), Gap(AppDimens.paddingXL), CustomButton(text: AppStrings.login, onPressed: () { Navigator.pop(context); context.push(AppRoutes.login); }), Gap(AppDimens.paddingS), OutlinedButton(onPressed: () { Navigator.pop(context); context.push(AppRoutes.register); }, style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 48.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM))), child: AutoSizeText(AppStrings.register)), Gap(AppDimens.paddingL)])))`. Import auto_size_text, gap, flutter_screenutil, go_router, app_strings, app_dimens, custom_button.

- [ ] T035 [P] [US5] Create `GuestActionBottomSheet` in `lib/features/auth/presentation/widgets/guest_action_bottom_sheet.dart`. A function `void showGuestActionBottomSheet(BuildContext context, {required String actionName, VoidCallback? onAuthComplete})` that shows a modal bottom sheet similar to guest profile but with: Icon `Icons.lock_outline`, title `AppStrings.premiumFeature`, subtitle `'Log in or register to $actionName'`. Login/Register buttons navigate to respective screens. The `onAuthComplete` callback should be stored so it can be called after auth succeeds (this will be wired in a later phase when favorites/downloads exist). Import same as GuestProfileBottomSheet.

- [ ] T036 [US5] Create `ProfilePage` in `lib/features/auth/presentation/pages/profile_page.dart`. A `StatelessWidget`. Uses `BlocBuilder<SubscriptionCubit, SubscriptionState>` to build. When state is `SubscriptionPremium`:

  Return `Scaffold(appBar: AppBar(title: AutoSizeText(AppStrings.profile)), body: SingleChildScrollView(padding: EdgeInsets.all(AppDimens.paddingL), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Gap(AppDimens.paddingL), CircleAvatar(radius: 40.r, backgroundColor: Theme.of(context).colorScheme.primary, child: AutoSizeText(state.user.displayName[0].toUpperCase(), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary))), Gap(AppDimens.paddingM), AutoSizeText(state.user.displayName, style: Theme.of(context).textTheme.headlineMedium), Gap(AppDimens.paddingXS), AutoSizeText(state.user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor)), Gap(AppDimens.paddingM), Chip(label: AutoSizeText(AppStrings.premiumBadge), backgroundColor: Theme.of(context).colorScheme.primary, labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary)), Gap(AppDimens.paddingXL), Divider(), Gap(AppDimens.paddingM), Align(alignment: Alignment.centerLeft, child: AutoSizeText('Subscription Advantages', style: Theme.of(context).textTheme.titleMedium)), Gap(AppDimens.paddingM), _AdvantageItem(text: AppStrings.adFreeExperience), _AdvantageItem(text: AppStrings.accessPremiumWallpapers), _AdvantageItem(text: AppStrings.priorityDownloads), Gap(AppDimens.paddingXL), Divider(), Gap(AppDimens.paddingM), OutlinedButton(onPressed: () => _showUnsubscribeDialog(context), style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 48.h), foregroundColor: Theme.of(context).colorScheme.error, side: BorderSide(color: Theme.of(context).colorScheme.error)), child: AutoSizeText(AppStrings.unsubscribe)), Gap(AppDimens.paddingM), CustomButton(text: AppStrings.logout, onPressed: () => _showLogoutDialog(context))])))`.

  When state is NOT premium → navigate back to Home (edge case guard).

  Create a private `_AdvantageItem` widget: `Row(children: [Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: AppDimens.iconM), Gap(AppDimens.paddingS), Expanded(child: AutoSizeText(text, style: Theme.of(context).textTheme.bodyLarge))])` with `Padding(padding: EdgeInsets.symmetric(vertical: AppDimens.paddingXS))`.

  `_showLogoutDialog(context)`: show `AlertDialog` with title `AppStrings.logout`, content `AutoSizeText(AppStrings.logoutConfirm)`, actions: cancel TextButton, confirm TextButton that calls `context.read<SubscriptionCubit>().setGuest()` then calls `sl<Logout>()(NoParams())` then `context.go(AppRoutes.home)`.

  `_showUnsubscribeDialog(context)`: show `AlertDialog` with title `AppStrings.unsubscribe`, content `AutoSizeText(AppStrings.unsubscribeConfirm)`, actions: cancel TextButton, confirm TextButton that calls `context.read<SubscriptionCubit>().performUnsubscribe()` then `context.go(AppRoutes.home)`.

  Import flutter_bloc, go_router, auto_size_text, gap, flutter_screenutil, app_strings, app_dimens, subscription_cubit, subscription_state, custom_button, app_loading, injection_container, logout use case, noparams.

- [ ] T037 [US5] Update `lib/features/home/presentation/pages/home_page.dart` to wire the profile icon with the correct bottom sheet. Replace the placeholder `_onProfileTapped` implementation from T024: check `context.read<SubscriptionCubit>().isPremium` — if true `context.push(AppRoutes.profile)`, if false call `showGuestProfileBottomSheet(context)`. Import guest_profile_bottom_sheet.

- [ ] T038 [US5] Update `lib/core/routes/app_router.dart` to add the `/profile` route. Add `GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfilePage())`. Import profile_page.dart.

**Checkpoint**: Profile icon works for both guest (bottom sheet) and premium (Profile page). Unsubscribe and logout functional.

---

## Phase 8: User Story 6 — Logout (Priority: P6)

**Goal**: Premium user logs out → returns to Home as guest → premium items hidden, ads shown, profile icon shows guest behavior.

**Independent Test**: Log in as premium → go to Profile → tap Logout → confirm → verify Home as guest.

### Implementation for User Story 6

- [ ] T039 [US6] Logout is already implemented in the ProfilePage (T036). Verify the full flow: (1) `_showLogoutDialog` shows confirmation. (2) On confirm: `SubscriptionCubit.setGuest()` is called → state emits guest. (3) `Logout` use case is called → clears token and user from storage. (4) Navigate to Home. (5) Home rebuilds — profile icon shows guest behavior. If the logout API call fails, the local session MUST still be cleared (local-first). Verify `AuthRepositoryImpl.logout()` handles this by wrapping the remote call in try-catch and always clearing local data. This is a verification/integration task.

- [ ] T040 [US6] Verify that after logout, the GoRouter redirect still works: if the user tries to go to `/login` or `/register` they can (since they're now guest). If they were premium and the redirect was blocking auth routes, confirm the redirect now allows access since `isPremium` is false. Test by: logging out → tapping Login from profile bottom sheet → verify Login page loads (not redirected to Home).

**Checkpoint**: Full logout flow works. Premium → Logout → Guest. Login accessible again.

---

## Phase 9: Tests

**Purpose**: Unit tests for cubits, repository, and use cases per Constitution Principle VII.

- [ ] T041 [P] Create `test/features/auth/domain/usecases/login_test.dart`. Test the `Login` use case: mock `AuthRepository`. Test: (1) successful login returns `Right(userEntity)`, (2) failed login returns `Left(ServerFailure(...))`. Use mocktail: `class MockAuthRepository extends Mock implements AuthRepository {}`. Verify `repository.login` is called with correct params.

- [ ] T042 [P] Create `test/features/auth/domain/usecases/register_test.dart`. Same pattern: mock repo, test success returns `Right(userEntity)`, failure returns `Left(...)`.

- [ ] T043 [P] Create `test/features/auth/domain/usecases/logout_test.dart`. Mock repo, test success returns `Right(null)`.

- [ ] T044 [P] Create `test/features/auth/domain/usecases/validate_token_test.dart`. Mock repo, test: valid premium → `Right(true)`, invalid/expired → `Right(false)`, error → `Left(...)`.

- [ ] T045 [P] Create `test/features/auth/presentation/cubit/subscription_cubit_test.dart`. Use `bloc_test` package. Mock `ValidateToken`, `GetCachedUser`, `Unsubscribe`. Test: (1) initial state is guest, (2) `checkStatus` with valid premium token emits [loading, premium], (3) `checkStatus` with no token emits [loading, guest], (4) `performUnsubscribe` success emits [loading, guest], (5) `setGuest` emits [guest], (6) `setPremium` emits [premium].

- [ ] T046 [P] Create `test/features/auth/presentation/cubit/auth_cubit_test.dart`. Use `bloc_test`. Mock `Login`, `Register`, `Logout`. Test: (1) initial state is initial, (2) `performLogin` success emits [loading, authenticated], (3) `performLogin` failure emits [loading, error], (4) `performLogin` 5 failures emits lockedOut with 30s, (5) `performRegister` success emits [loading, authenticated], (6) `performRegister` failure emits [loading, error], (7) `performLogout` emits [loading, initial].

- [ ] T047 [P] Create `test/features/auth/data/repositories/auth_repository_impl_test.dart`. Mock `AuthRemoteDataSource`, `AuthLocalDataSource`, `NetworkInfo`. Test: (1) login success → saves token + user → returns Right(entity), (2) login network error → returns Left(NetworkFailure), (3) login server error → returns Left(ServerFailure), (4) logout success → clears local data, (5) logout network error → still clears local data (local-first), (6) validateToken with valid token → returns Right(true), (7) validateToken with 401 → clears token → returns Right(false), (8) validateToken with no token → returns Right(false).

**Checkpoint**: All tests written and passing.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Code generation, formatting, analysis, and final validation.

- [ ] T048 Run `dart run build_runner build --delete-conflicting-outputs` to regenerate all `.freezed.dart`, `.g.dart` files including new auth models, cubits, and Retrofit data source. Fix any errors.

- [ ] T049 Run `dart format .` on the entire project for consistent formatting.

- [ ] T050 Run `flutter analyze` and fix ALL warnings. Zero warnings required per constitution. Common issues: unused imports, missing return types, uninitialized fields.

- [ ] T051 Verify the complete flow end-to-end: (1) Fresh launch → splash → Home as guest. (2) Tap profile icon → bottom sheet. (3) Tap Register → fill form → register → Home as premium. (4) Close app → reopen → splash validates → Home as premium. (5) Tap profile → Profile page → advantages shown. (6) Tap Unsubscribe → confirm → Home as guest. (7) Tap profile → bottom sheet → Login → Home as premium. (8) Profile → Logout → Home as guest. (9) Wrong password 5x → lockout timer shown.

- [ ] T052 Run `flutter test` to verify all unit tests pass. Fix any failures.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (strings and routes must exist)
- **US1 (Phase 3)**: Depends on Phase 2 (needs SubscriptionCubit, which needs use cases and repo)
- **US2 (Phase 4)**: Depends on Phase 2 + US1 (needs AuthCubit + SubscriptionCubit at app root)
- **US3 (Phase 5)**: Depends on Phase 2 + US1 (needs SubscriptionCubit). Can run parallel with US2.
- **US4 (Phase 6)**: Depends on US1 (splash validation already set up)
- **US5 (Phase 7)**: Depends on US1 (profile icon) + US2 or US3 (needs auth pages to link to)
- **US6 (Phase 8)**: Depends on US5 (logout is on Profile page)
- **Tests (Phase 9)**: Depends on Phase 2 (tests the foundational code). Can start as soon as Phase 2 completes.
- **Polish (Phase 10)**: Depends on all phases complete

### User Story Dependencies

- **US1 (P1)**: MVP target. Only depends on Phase 2.
- **US2 (P2)**: Depends on US1 (needs SubscriptionCubit wired at app root).
- **US3 (P3)**: Depends on US1. Can run parallel with US2.
- **US4 (P4)**: Verification task — depends on US1 splash changes.
- **US5 (P5)**: Depends on US1 + (US2 or US3) for auth pages to link to.
- **US6 (P6)**: Verification of logout — depends on US5 Profile page.

### Parallel Opportunities

- T002, T003 can run in parallel (Phase 1 — different files)
- T004–T016 (domain + models) can ALL run in parallel (Phase 2 — different files)
- T017, T018 can run in parallel (data sources — different files)
- T022, T026, T027 can run in parallel (SubscriptionCubit, AuthCubit, AuthFormField — different files)
- T034, T035 can run in parallel (bottom sheet widgets — different files)
- T041–T047 can ALL run in parallel (tests — different files)
- US2 and US3 can run in parallel after US1 completes

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational (T004–T021) — CRITICAL, blocks everything
3. Complete Phase 3: User Story 1 (T022–T025)
4. **STOP and VALIDATE**: `flutter run` — splash loads, Home renders as guest, profile icon visible

### Incremental Delivery

1. Setup + Foundational → Infrastructure ready
2. Add US1 → Guest Home experience (MVP!)
3. Add US2 → Registration works
4. Add US3 → Login + lockout works
5. Add US4 → Token validation on relaunch
6. Add US5 → Profile page + bottom sheets
7. Add US6 → Logout verified
8. Tests → All cubits/repos/use cases covered
9. Polish → Zero warnings, formatted, e2e verified

---

## Notes

- Two user types only: Guest and Premium. No "free authenticated" tier.
- Home is ALWAYS accessible — no auth gate.
- Premium items are hidden from guests (not locked/badged).
- Profile icon: guest → bottom sheet, premium → Profile page.
- Unsubscribe takes effect immediately.
- Logout navigates to Home (not Login) since Home is guest-accessible.
- After guest auth from premium-action prompt → return to exact item (wired when favorites/downloads are built in Phase 4 of roadmap).
- Constitution requires `AutoSizeText` instead of `Text`, ScreenUtil `.w/.h/.sp/.r` for all sizes, `CachedNetworkImage` for network images.
- All generated files require `dart run build_runner build --delete-conflicting-outputs`.
- Commit after each completed phase or logical task group.
