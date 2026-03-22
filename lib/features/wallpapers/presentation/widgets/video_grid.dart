import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/widgets/app_loading.dart';
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

  int _getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;
    if (width < 700) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final displayWallpapers = widget.isPremium
        ? widget.wallpapers
        : widget.wallpapers.where((w) => !w.isPremium).toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent -
                      AppDimens.paginationThreshold &&
              !widget.hasReachedEnd &&
              !widget.isLoadingMore) {
            widget.onLoadMore();
          }
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(AppDimens.paddingM),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getColumnCount(context),
                childAspectRatio: 0.75,
                crossAxisSpacing: AppDimens.gridSpacing,
                mainAxisSpacing: AppDimens.gridSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                childCount: displayWallpapers.length,
                (context, index) {
                  final wallpaper = displayWallpapers[index];
                  return VisibilityDetector(
                    key: Key('video_${wallpaper.id}'),
                    onVisibilityChanged: (info) =>
                        _onVisibilityChanged(index, info),
                    child: VideoThumbnail(
                      wallpaper: wallpaper,
                      onTap: () => widget.onWallpaperTapped(wallpaper),
                      shouldAutoPlay: _autoPlayIndices.contains(index),
                    ),
                  );
                },
              ),
            ),
          ),
          if (widget.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.paddingM),
                child: const Center(child: AppLoading()),
              ),
            ),
        ],
      ),
    );
  }
}
