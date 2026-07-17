import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/widgets/staggered_wallpaper_card.dart';
import '../../../../core/widgets/staggered_wallpaper_grid.dart';
import '../../domain/entities/wallpaper_entity.dart';
import 'video_thumbnail.dart';

class VideoGrid extends StatefulWidget {
  final List<WallpaperEntity> wallpapers;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final VoidCallback onLoadMore;
  final ValueChanged<WallpaperEntity> onWallpaperTapped;
  final bool isPremium;

  const VideoGrid({
    super.key,
    required this.wallpapers,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    required this.onLoadMore,
    required this.onWallpaperTapped,
    required this.isPremium,
  });

  @override
  State<VideoGrid> createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  final Set<int> _autoPlayIndices = {};
  final Map<int, double> _visibilityFractions = {};

  void _onVisibilityChanged(int index, VisibilityInfo info) {
    if (info.visibleFraction > 0.5) {
      _visibilityFractions[index] = info.visibleFraction;
    } else if (info.visibleFraction <= 0.1) {
      _visibilityFractions.remove(index);
    }

    if (!mounted) return;

    final sortedCandidates = _visibilityFractions.keys.toList()
      ..sort(
        (a, b) => (_visibilityFractions[b] ?? 0).compareTo(
          _visibilityFractions[a] ?? 0,
        ),
      );

    final newAutoPlay = sortedCandidates.take(3).toSet();
    if (!_setEquals(newAutoPlay, _autoPlayIndices)) {
      setState(() {
        _autoPlayIndices
          ..clear()
          ..addAll(newAutoPlay);
      });
    }
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredWallpaperGrid<WallpaperEntity>(
      items: widget.wallpapers,
      isLoadingMore: widget.isLoadingMore,
      hasReachedEnd: widget.hasReachedEnd,
      onLoadMore: widget.onLoadMore,
      itemBuilder: (context, wallpaper, index) => VisibilityDetector(
        key: Key('video_${wallpaper.id}'),
        onVisibilityChanged: (info) => _onVisibilityChanged(index, info),
        child: StaggeredWallpaperCard(
          imageUrl: wallpaper.thumbUrl,
          child: VideoThumbnail(
            wallpaper: wallpaper,
            onTap: () => widget.onWallpaperTapped(wallpaper),
            shouldAutoPlay: _autoPlayIndices.contains(index),
          ),
        ),
      ),
    );
  }
}
