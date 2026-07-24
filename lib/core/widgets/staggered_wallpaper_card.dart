import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../services/aspect_ratio_cache.dart';
import '../utils/app_dimens.dart';
import 'app_cached_image.dart';
import 'app_shimmer_widget.dart';

/// A wallpaper card that decodes the image aspect ratio after download and
/// animates from the 3:4 fallback height to the correct proportional height.
///
/// While the image is loading, a shimmer skeleton is shown at 3:4 ratio.
/// Once decoded, the card resizes smoothly (300 ms, easeOutCubic) to match
/// the wallpaper's natural dimensions — creating a Pinterest-style masonry effect.
///
/// Use inside [MasonryGridView] or [SliverMasonryGrid]; the card self-sizes and
/// the grid container adapts accordingly.
class StaggeredWallpaperCard extends StatefulWidget {
  /// URL used both for aspect-ratio decoding and image display.
  final String imageUrl;

  /// Called when the user taps the card. Ignored when [child] is provided.
  final VoidCallback? onTap;

  /// If provided, the card is wrapped in a [Hero] with this tag.
  /// Ignored when [child] is provided (child handles its own Hero).
  final Object? heroTag;

  /// Widget positioned at top-left of the card (e.g. [ExclusiveBadge], play icon).
  final Widget? overlay;

  /// Accessibility label for the [Semantics] wrapper.
  /// Ignored when [child] is provided.
  final String? semanticLabel;

  /// Optional custom content rendered inside the [AspectRatio] container.
  ///
  /// When provided, replaces [AppCachedImage] as the main content.
  /// The child must be able to expand to fill its parent's constraints
  /// (e.g. use [StackFit.expand] or [SizedBox.expand]).
  /// The [onTap], [heroTag], and [semanticLabel] parameters are ignored —
  /// the child is expected to handle interaction itself.
  final Widget? child;

  const StaggeredWallpaperCard({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.heroTag,
    this.overlay,
    this.semanticLabel,
    this.child,
  });

  @override
  State<StaggeredWallpaperCard> createState() => _StaggeredWallpaperCardState();
}

class _StaggeredWallpaperCardState extends State<StaggeredWallpaperCard> {
  static const double _fallbackRatio = 3 / 4;

  double? _aspectRatio;
  ImageStream? _imageStream;
  late ImageStreamListener _listener;

  /// True when [_aspectRatio] came from [AspectRatioCache] (already decoded this
  /// session), so the card renders its final layout on the first frame with no
  /// resize animation — killing the shimmer/resize replay on scroll-back.
  bool _skipResizeAnim = false;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  @override
  void didUpdateWidget(StaggeredWallpaperCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _cancelStream();
      setState(() => _aspectRatio = null);
      _resolveAspectRatio();
    }
  }

  void _resolveAspectRatio() {
    // Fast path: ratio already decoded this session. Render the final layout on
    // the first frame — no stream re-probe, no shimmer skeleton, no resize tween.
    final cached = AspectRatioCache.get(widget.imageUrl);
    if (cached != null) {
      _aspectRatio = cached;
      _skipResizeAnim = true;
      return;
    }
    _skipResizeAnim = false;

    _listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        final w = info.image.width;
        final h = info.image.height;
        if (!mounted || h <= 0) return;
        final ratio = w / h;
        AspectRatioCache.put(widget.imageUrl, ratio);
        setState(() => _aspectRatio = ratio);
      },
      onError: (Object e, StackTrace? st) {
        // Silently keep fallback ratio; AppCachedImage shows its own error state.
      },
    );
    final provider = CachedNetworkImageProvider(
      widget.imageUrl,
      cacheManager: GetIt.I<CacheManager>(
        instanceName: 'wallpaperThumbnailCacheManager',
      ),
    );
    _imageStream = provider.resolve(const ImageConfiguration());
    _imageStream!.addListener(_listener);
  }

  void _cancelStream() {
    _imageStream?.removeListener(_listener);
    _imageStream = null;
  }

  @override
  void dispose() {
    _cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetRatio = (_aspectRatio != null && _aspectRatio! > 0)
        ? _aspectRatio!
        : _fallbackRatio;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _fallbackRatio, end: targetRatio),
      duration: _skipResizeAnim
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, ratio, _) {
        if (widget.child != null) {
          return _buildCustomChild(ratio);
        }
        return _buildImageCard(context, ratio);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Custom child (e.g. VideoThumbnail)
  // ---------------------------------------------------------------------------

  Widget _buildCustomChild(double ratio) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusS),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child!,
            if (widget.overlay != null)
              Positioned(top: 6.h, left: 6.w, child: widget.overlay!),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Standard image card (shimmer → AppCachedImage)
  // ---------------------------------------------------------------------------

  Widget _buildImageCard(BuildContext context, double ratio) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusS),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Use shimmer until the aspect ratio is decoded, then show the
            // actual image (AppCachedImage has its own per-image shimmer).
            _aspectRatio != null
                ? LayoutBuilder(
                    builder: (_, constraints) => AppCachedImage(
                      imageUrl: widget.imageUrl,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      fit: BoxFit.cover,
                      // No fade on rebuild — a warm cache hit must swap in
                      // instantly, not fade over 500 ms (reads as a flash).
                      fadeInDuration: Duration.zero,
                    ),
                  )
                : AppShimmerWidget(
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
            if (widget.overlay != null)
              Positioned(top: 6.h, left: 6.w, child: widget.overlay!),
          ],
        ),
      ),
    );

    if (widget.heroTag != null) {
      card = Hero(tag: widget.heroTag!, child: card);
    }

    if (widget.semanticLabel != null) {
      card = Semantics(button: true, label: widget.semanticLabel, child: card);
    }

    return GestureDetector(onTap: widget.onTap, child: card);
  }
}
