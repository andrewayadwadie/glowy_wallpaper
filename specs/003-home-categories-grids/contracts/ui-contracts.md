# UI Contracts: Home, Categories & Content Grids

## HomePage (Rewrite)

**Route**: `/` (AppRoutes.home)
**File**: `lib/features/home/presentation/pages/home_page.dart`

### Layout

```
┌─────────────────────────────────────┐
│ AppBar                              │
│ ┌─ ☰ ─┐   Glowy Wallpapers   ┌─👤─┐│
│ └─────┘                       └────┘│
├─────────────────────────────────────┤
│ Category Selector (horizontal)      │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐│
│ │Nature│ │Live  │ │Themes│ │Sport │││
│ │(sel) │ │Scenes│ │      │ │      │││
│ └──────┘ └──────┘ └──────┘ └──────┘│
├─────────────────────────────────────┤
│ Content Area (dynamic by type)      │
│                                     │
│ [Image Grid / Video Grid / Bento]   │
│                                     │
│ ┌─────┐ ┌─────┐                    │
│ │     │ │     │                    │
│ │ img │ │ img │  ← 2/3/4 cols     │
│ │     │ │     │                    │
│ └─────┘ └─────┘                    │
│ ┌─────┐ ┌─────┐                    │
│ │     │ │     │                    │
│ └─────┘ └─────┘                    │
│         ...                         │
│ [Loading indicator at bottom]       │
├─────────────────────────────────────┤
│ Banner Ad Placeholder (guest only)  │
└─────────────────────────────────────┘
```

### State Handling

| State | Categories Area | Content Area |
|-------|----------------|--------------|
| Loading (initial) | Shimmer placeholder chips | Shimmer placeholder grid |
| Error (categories failed, no cache) | Error message + retry button | Hidden |
| Error (content failed) | Normal category selector | Error message + retry button |
| Empty (no categories) | "No categories available" + retry | Hidden |
| Empty (category has no content) | Normal category selector | "No wallpapers" + illustration |
| Success | Category chips rendered | Grid rendered with content |
| Loading more (pagination) | Normal category selector | Grid + loading indicator at bottom |

### BlocProvider Setup

```dart
BlocProvider(
  create: (context) => sl<HomeCubit>()..loadCategories(),
  child: const HomePage(),
)
```

---

## CategorySelector Widget

**File**: `lib/features/home/presentation/widgets/category_selector.dart`

### Props

| Prop | Type | Description |
|------|------|-------------|
| categories | List<CategoryEntity> | All categories |
| selectedIndex | int | Currently selected index |
| onCategorySelected | Function(int) | Callback when a chip is tapped |

### Design

- Horizontal `ListView.builder` with `Padding`.
- Each item: `GestureDetector` → `Container` with `BoxDecoration`:
  - Selected: `colorScheme.primary` background, `colorScheme.onPrimary` text.
  - Unselected: `colorScheme.surfaceContainerHighest` background, `colorScheme.onSurface` text.
- Text: `AutoSizeText(category.name)` with `maxLines: 1`.
- Padding: `AppDimens.paddingS.w` horizontal, `AppDimens.paddingXS.h` vertical.
- Border radius: `AppDimens.radiusM.r`.
- Gap between chips: `AppDimens.gapS.w`.
- Height: fixed `40.h`.

---

## ContentSwitcher Widget

**File**: `lib/features/home/presentation/widgets/content_switcher.dart`

### Props

| Prop | Type | Description |
|------|------|-------------|
| categoryType | CategoryType | Current category's type |
| wallpapers | List<WallpaperEntity> | Wallpapers (for image/video) |
| classifications | List<ClassificationEntity> | Classifications (for classification type) |
| contentStatus | Status | Current loading status |
| isLoadingMore | bool | Whether pagination is loading |
| hasReachedEnd | bool | Whether all pages loaded |
| onLoadMore | VoidCallback | Trigger next page load |
| onWallpaperTapped | Function(WallpaperEntity) | Navigate to wallpaper detail |
| onClassificationTapped | Function(ClassificationEntity) | Navigate to classification detail |
| onRetry | VoidCallback | Retry on error |
| errorMessage | String? | Error message to display |

### Behavior

- Switch on `categoryType`:
  - `CategoryType.image` → render `WallpaperGrid`
  - `CategoryType.video` → render `VideoGrid`
  - `CategoryType.classification` → render `ClassificationBentoGrid`
- If `contentStatus == Status.loading` → render shimmer placeholder matching grid type.
- If `contentStatus == Status.error` → render `AppErrorWidget` with retry.
- If `contentStatus == Status.empty` → render empty state with illustration.

---

## WallpaperGrid Widget (Image)

**File**: `lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart`

### Layout

- Uses existing `AdaptiveGrid` (2/3/4 columns based on width).
- Each cell: `WallpaperThumbnail` widget.
- Wrapped in a scrollable `CustomScrollView` with `SliverGrid` for efficient lazy rendering.
- `ScrollController` with listener: if `position.pixels >= maxScrollExtent - 200.h` → call `onLoadMore()`.
- Bottom: if `isLoadingMore` → `CircularProgressIndicator` at end (exception to constitution: this is a small inline indicator, not a full-screen loader).

### WallpaperThumbnail Widget

**File**: `lib/features/wallpapers/presentation/widgets/wallpaper_thumbnail.dart`

- `GestureDetector` → `ClipRRect(borderRadius: AppDimens.radiusS.r)` → `AppCachedImage(imageUrl: wallpaper.thumbnailUrl)`.
- Tap → `onWallpaperTapped(wallpaper)`.
- Aspect ratio: 0.75 (3:4 portrait).
- Hero animation tag: `'wallpaper_${wallpaper.id}'` (for Phase 4 detail transition).

---

## VideoGrid Widget

**File**: `lib/features/wallpapers/presentation/widgets/video_grid.dart`

### Layout

- Same grid structure as `WallpaperGrid` but cells are `VideoThumbnail` widgets.
- Grid wraps in `CustomScrollView` with pagination scroll listener.

### VideoThumbnail Widget

**File**: `lib/features/wallpapers/presentation/widgets/video_thumbnail.dart`

- Uses `VisibilityDetector` wrapping the cell.
- If `visibleFraction > 0.5` AND manager allows (under 2-3 limit):
  - Initialize `VideoPlayerController.networkUrl(wallpaper.videoUrl!)`.
  - Set `setLooping(true)`, `setVolume(0.0)`, `play()`.
  - Show video via `VideoPlayer(controller)`.
- If not playing: show `AppCachedImage(wallpaper.thumbnailUrl)` + centered `Icon(Icons.play_circle_outline)`.
- `dispose()`: dispose controller, remove from manager.
- Tap → `onWallpaperTapped(wallpaper)`.

---

## ClassificationBentoGrid Widget

**File**: `lib/features/categories/presentation/widgets/classification_bento_grid.dart`

### Layout (repeating pattern)

```
Row 1: ┌──────────────────────────┐
        │    Large Card (2-col)    │
        │    [thumbnail + gradient │
        │     + name overlay]      │
        └──────────────────────────┘
Row 2: ┌────────────┐ ┌────────────┐
        │ Small Card │ │ Small Card │
        │ [thumb+    │ │ [thumb+    │
        │  name]     │ │  name]     │
        └────────────┘ └────────────┘
Row 3: ┌──────────────────────────┐
        │    Large Card (2-col)    │
        └──────────────────────────┘
        ... (repeat)
```

### ClassificationCard Widget

**File**: `lib/features/categories/presentation/widgets/classification_card.dart`

- `GestureDetector` → `ClipRRect(borderRadius: AppDimens.radiusM.r)` → `Stack`:
  - `AppCachedImage(classification.thumbnailUrl, fit: BoxFit.cover)` fills card.
  - `Positioned.fill` → gradient overlay (`LinearGradient` from transparent to `Colors.black54` at bottom).
  - `Positioned(bottom, left)` → `AutoSizeText(classification.name)` in white, bold.
- Large card height: `200.h`. Small card height: `150.h`.
- Tap → `onClassificationTapped(classification)`.

---

## ClassificationDetailPage

**Route**: `/classification/:id` (AppRoutes.classificationDetail)
**File**: `lib/features/categories/presentation/pages/classification_detail_page.dart`

### Layout

```
┌─────────────────────────────────────┐
│ AppBar                              │
│ ← Back    [Classification Name]    │
├─────────────────────────────────────┤
│ Wallpaper Grid (same as WallpaperGrid) │
│                                     │
│ ┌─────┐ ┌─────┐                    │
│ │     │ │     │                    │
│ │ img │ │ img │                    │
│ │     │ │     │                    │
│ └─────┘ └─────┘                    │
│         ...                         │
│ [Loading indicator at bottom]       │
└─────────────────────────────────────┘
```

### State Handling

Same four-state pattern as Home content area: loading → error (retry) → empty → success.

### BlocProvider Setup

```dart
BlocProvider(
  create: (context) => sl<ClassificationDetailCubit>(
    param1: classification,
  )..loadWallpapers(),
  child: const ClassificationDetailPage(),
)
```

---

## HomeDrawer Widget

**File**: `lib/features/home/presentation/widgets/home_drawer.dart`

### Layout

```
┌──────────────────────┐
│ DrawerHeader         │
│   App Logo           │
│   "Glowy Wallpapers" │
├──────────────────────┤
│ 🏠 Home              │
│ ❤️ Favorites          │
│ ⬇️ My Downloads      │
│ ⭐ Get Premium       │
│ ──────────── divider │
│ ⚙️ Settings           │
│ ℹ️ About              │
│ ──────────── divider │
│ ⭐ Rate App           │
│ 📤 Share App          │
│ 📧 Send Feedback      │
└──────────────────────┘
```

### Menu Items

| Item | Icon | Route/Action |
|------|------|-------------|
| Home | Icons.home_outlined | `GoRouter.go(AppRoutes.home)` |
| Favorites | Icons.favorite_outline | `GoRouter.go(AppRoutes.favorites)` (placeholder) |
| My Downloads | Icons.download_outlined | `GoRouter.go(AppRoutes.downloads)` (placeholder) |
| Get Premium | Icons.workspace_premium | `GoRouter.go(AppRoutes.premium)` (placeholder) |
| Settings | Icons.settings_outlined | `GoRouter.go(AppRoutes.settings)` (placeholder) |
| About | Icons.info_outline | `GoRouter.go(AppRoutes.about)` (placeholder) |
| Rate App | Icons.star_outline | `url_launcher` → store URL |
| Share App | Icons.share_outlined | Show "Coming Soon" snackbar (share_plus not in pubspec yet) |
| Send Feedback | Icons.email_outlined | `url_launcher` → `mailto:support@glowywallpapers.com` |

### Behavior

- Close drawer on any item tap: `Navigator.pop(context)` before navigating.
- Dividers between groups: navigation, settings, external actions.
- Each item: `ListTile(leading: Icon, title: AutoSizeText)`.
