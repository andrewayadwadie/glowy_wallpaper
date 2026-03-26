# Research: Fix Runtime Bugs

**Branch**: `008-fix-runtime-bugs` | **Date**: 2026-03-26

## Research Tasks

### R1: Flutter setState on Disposed Widget — Best Practice

**Decision**: Use `if (!mounted) return;` guard before any `setState()` call in callbacks that may fire after the widget is disposed.

**Rationale**: This is the standard Flutter pattern documented in the Flutter framework itself. The `mounted` property is available on all `State<T>` objects and returns `false` after `dispose()` has been called. This is preferred over try/catch or custom lifecycle flags.

**Alternatives considered**:
- Custom `_isDisposed` flag — redundant since `mounted` already exists.
- Canceling visibility detector subscriptions in `dispose()` — `VisibilityDetector` doesn't expose a subscription handle; `mounted` check is simpler.
- Using `WidgetsBindingObserver` — over-engineered for this use case.

### R2: Classification API — Dio Instance & Response Parsing

**Decision**: Verify whether the classification endpoint requires authentication. The endpoint `GET /api/v1/mobile/apps/{appId}/categories/{categoryId}/classifications` follows the same public pattern as other category content endpoints. If the server rejects unauthenticated requests, switch to the authenticated Dio instance.

**Rationale**: The plan.md API collection shows classifications as a public endpoint (no auth header mentioned). The network error may stem from response envelope mismatch — the data source may parse `response.data['data']` as `Map<String, dynamic>` but the `classifications` key might be at a different path (e.g., `data.classifications` vs `data.items`).

**Alternatives considered**:
- Always use authenticated Dio for all category endpoints — unnecessarily couples categories to auth state.
- Add a separate Dio instance for classifications — violates SOLID (same concern, same instance).

### R3: GoRouter Navigation Parameter Contract

**Decision**: All wallpaper detail navigation callers must pass `extra: {'wallpapers': List<WallpaperEntity>, 'initialIndex': int}`. This is the contract established in `app_router.dart` and used correctly by `downloads_page.dart`.

**Rationale**: The wallpaper detail page uses a `PageView.builder` carousel that requires the full list and initial index. Passing a single entity breaks this contract.

**Alternatives considered**:
- Modify the router to accept both formats (single entity or map) — adds complexity and divergent behavior.
- Pass only the wallpaper ID and fetch data in the detail page — breaks offline/cache flow and adds latency.

### R4: ContentPage — Accepting Dynamic Content

**Decision**: Modify `ContentPage` to accept the content body as a constructor parameter (String). The drawer passes the appropriate `appMetadata` field based on the content type. Remove the hardcoded `_body` getter.

**Rationale**: This is the simplest change — ContentPage already receives `contentType` for the title; adding a `content` String parameter follows the same pattern. No new widgets, no new state management.

**Alternatives considered**:
- Have ContentPage read from a Cubit — over-engineered for static read-only content.
- Use a WebView for HTML content — the API returns plain text strings, not HTML.
- Create separate pages for each content type — violates DRY.
