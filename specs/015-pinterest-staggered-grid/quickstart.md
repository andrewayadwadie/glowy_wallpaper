# Quickstart: Pinterest-Style Staggered Grid

**Feature**: 015-pinterest-staggered-grid | **Date**: 2026-04-09

---

## What Changed

All wallpaper grid surfaces now use a two-column Pinterest-style masonry layout where each card's height matches the wallpaper's natural aspect ratio. The core change is two new widgets in `lib/core/widgets/`:

| Widget | Purpose |
|--------|---------|
| `StaggeredWallpaperCard` | A single grid card: shimmer while loading, decodes aspect ratio, animates to correct height |
| `StaggeredWallpaperGrid<T>` | Drop-in sliver adapter (for `CustomScrollView` surfaces) replacing `SliverGrid` |

---

## Using StaggeredWallpaperCard

The card is self-contained — pass it a URL and it handles everything internally.

```dart
// Minimal usage
StaggeredWallpaperCard(
  imageUrl: wallpaper.url,
  onTap: () => navigateToDetail(wallpaper),
)

// With hero tag and overlay badge
StaggeredWallpaperCard(
  imageUrl: wallpaper.url,
  onTap: () => navigateToDetail(wallpaper),
  heroTag: 'wallpaper_${wallpaper.id}',
  overlay: const ExclusiveBadge(),
  semanticLabel: AppStrings.wallpaperDetail,
)
```

The card:
1. Shows a shimmer skeleton at 3:4 ratio immediately
2. Decodes the image aspect ratio in the background
3. Animates (resize + fade-in, 300 ms) to the correct height

---

## Using StaggeredWallpaperGrid (CustomScrollView surfaces)

Replaces the old `SliverGrid` block. Drop it inside a `CustomScrollView` alongside other slivers.

```dart
CustomScrollView(
  slivers: [
    StaggeredWallpaperGrid<WallpaperEntity>(
      items: wallpapers,
      isLoadingMore: isLoadingMore,
      hasReachedEnd: hasReachedEnd,
      onLoadMore: onLoadMore,
      itemBuilder: (context, wallpaper, index) => StaggeredWallpaperCard(
        imageUrl: wallpaper.url,
        onTap: () => onWallpaperTapped(wallpaper),
        heroTag: 'wallpaper_${wallpaper.id}',
      ),
    ),
    // other slivers...
  ],
)
```

---

## Using MasonryGridView (standalone scroll surfaces)

For `FavoritesGrid`, `DownloadsGrid`, and `SimilarWallpapersSheet`, replace `GridView.builder` with:

```dart
MasonryGridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: AppDimens.gridSpacing,
  mainAxisSpacing: AppDimens.gridSpacing,
  padding: EdgeInsets.all(AppDimens.paddingM),
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return StaggeredWallpaperCard(
      imageUrl: item.imageUrl,
      onTap: () => onTap(item),
      heroTag: 'wallpaper_${item.id}',
    );
  },
)
```

> Import: `import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';`

---

## What NOT to Change

- `classification_bento_grid.dart` — out of scope, retains its current layout.
- Domain entities (`WallpaperEntity`, `FavoriteEntity`, `DownloadRecordEntity`) — not touched.
- Use cases, repositories, data sources — not touched.
- `VideoGrid` visibility detection logic (`_autoPlayIndices`) — preserved as-is.
- `AppDimens.gridSpacing` / `AppDimens.paddingM` — same values, same constants.

---

## Running After Changes

```bash
flutter pub get          # pick up flutter_staggered_grid_view
flutter analyze          # must be zero warnings
dart format .
flutter test             # all existing tests must pass
```
