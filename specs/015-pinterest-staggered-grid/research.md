# Research: Pinterest-Style Staggered Grid

**Feature**: 015-pinterest-staggered-grid  
**Date**: 2026-04-09

---

## Decision 1: Masonry API in flutter_staggered_grid_view ^0.7.0

**Decision**: Use `MasonryGridView.count` for standalone scrolling grids (Favorites, Downloads, Similar) and `SliverMasonryGrid.count` for grids embedded in `CustomScrollView` (WallpaperGrid, VideoGrid).

**Rationale**: `MasonryGridView` is the widget equivalent of `GridView` — it manages its own scroll controller and physics. `SliverMasonryGrid` is the sliver equivalent of `SliverGrid` — it must live inside a `CustomScrollView` alongside other slivers (e.g., the loading indicator). Both use `SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2)` as their delegate. Unlike `SliverGridDelegateWithFixedCrossAxisCount`, there is no `childAspectRatio` — each child provides its own height.

**Alternatives considered**:
- `StaggeredGrid.count` (same package): lower-level, requires explicit extent per tile, unsuitable for dynamic heights.
- `flutter_layout_grid`: more powerful but far heavier; overkill for a two-column masonry layout.

---

## Decision 2: Image Aspect Ratio Decoding

**Decision**: Use `CachedNetworkImageProvider(url).resolve(const ImageConfiguration())` and attach an `ImageStreamListener` inside the card's `initState`. Store the result as `_aspectRatio` in widget state. Cancel the listener in `dispose`.

**Rationale**: `CachedNetworkImageProvider` (from `cached_network_image`) is the project-mandated image provider (raw `NetworkImage` is forbidden by the constitution). Resolving it gives an `ImageStream`; the `ImageStreamListener` callback receives `ImageInfo` which exposes `image.width` and `image.height` as integers. The aspect ratio `= width / height` (as a double). This integrates with the existing `CachedNetworkImage` cache — the image is not downloaded twice.

**Key detail**: `ImageInfo.image` is a `dart:ui Image`. Width and height are in logical pixels of the decoded image, not screen pixels. The ratio is content-intrinsic and device-independent.

**Alternatives considered**:
- Parsing image headers (JPEG EXIF / PNG IHDR) via `http` byte-range request: avoids full download but adds complexity, unreliable across CDNs, and images are downloaded anyway by `CachedNetworkImage`.
- Storing ratios in a global `Map<String, double>` singleton: premature optimization; local widget state is sufficient since `CachedNetworkImage` caches the pixel data — re-decode is cheap on cache hit.

---

## Decision 3: Height Transition Animation

**Decision**: `TweenAnimationBuilder<double>` wrapping an `AspectRatio` widget. Tween goes from `3/4` (0.75 — fallback portrait ratio) to the decoded aspect ratio. Duration: 300 ms, curve: `Curves.easeOutCubic`.

**Rationale**: `TweenAnimationBuilder` is fire-and-forget — it automatically re-runs its animation whenever the target `end` value changes (i.e., when the decoded ratio arrives). No `AnimationController` lifecycle to manage. The `AspectRatio` widget drives the card height from the column width, so MasonryGridView recomputes column balance automatically. `Curves.easeOutCubic` decelerates toward the final height, making the resize feel intentional.

**Alternatives considered**:
- `AnimatedContainer` with explicit height: requires knowing the card's pixel width, which needs `LayoutBuilder` — adds a frame of layout cost.
- `AnimatedSize` widget: useful for intrinsic-size children, but aspect-ratio changes require the child to report its new intrinsic size first, causing a one-frame lag.
- No animation (instant snap): rejected in clarification (user chose Option A).

---

## Decision 4: Shimmer Placeholder

**Decision**: While `_aspectRatio == null` (pre-decode), render `Shimmer.fromColors(baseColor: ..., highlightColor: ..., child: Container(...))` sized via `AspectRatio(aspectRatio: 3/4)`. Colors pulled from `Theme.of(context).colorScheme.surfaceContainerHighest` (base) and `Theme.of(context).colorScheme.surface` (highlight) — no hardcoded hex values.

**Rationale**: `shimmer` package is already a mandatory dependency (Package & Dependency Standards). Theme-sourced colors automatically adapt to light/dark mode (Constitution IV). `AspectRatio(3/4)` gives a stable 3:4 placeholder height consistent with the fallback ratio, so the layout does not change height twice (once shimmer → placeholder → decoded; instead: shimmer @ 3/4 → decoded via animation).

**Alternatives considered**:
- Solid color box: simpler, but provides no "loading" affordance to the user.
- Blurred low-res thumbnail: adds a two-stage download (thumbnail then full); rejected because the cache only stores the final image.

---

## Decision 5: Video Thumbnail Aspect Ratio

**Decision**: For video wallpapers (`VideoThumbnail`), the same `StaggeredWallpaperCard` approach applies using the video thumbnail URL (still image) for aspect ratio decoding. The `VideoThumbnail` widget becomes the overlay child of the card. The `VisibilityDetector` wraps the entire `StaggeredWallpaperCard`.

**Rationale**: Video thumbnails are still images (JPEG/PNG); the decode path is identical. Auto-play logic (visibility detection, `_autoPlayIndices`) lives in `VideoGrid`'s state and does not change — `VideoThumbnail` remains the leaf widget responsible for video playback.

**Alternatives considered**:
- Decoding video dimensions from the video file: requires `video_player` initialization, which is expensive and causes audio/resource allocation per cell — completely unsuitable.

---

## No NEEDS CLARIFICATION items remain

All technical unknowns resolved via research and clarification session (2026-04-09).
