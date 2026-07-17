import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../utils/app_dimens.dart';
import 'app_loading.dart';

/// A generic two-column Pinterest-style masonry grid with pagination support.
///
/// Wraps [SliverMasonryGrid] inside a [CustomScrollView].  Each child
/// determines its own height (typically via [StaggeredWallpaperCard]).
/// Triggers [onLoadMore] when the user scrolls within
/// [AppDimens.paginationThreshold] of the bottom.
class StaggeredWallpaperGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final VoidCallback onLoadMore;
  final EdgeInsetsGeometry? padding;

  const StaggeredWallpaperGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    required this.onLoadMore,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent -
                      AppDimens.paginationThreshold &&
              !hasReachedEnd &&
              !isLoadingMore) {
            onLoadMore();
          }
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: padding ?? EdgeInsets.all(AppDimens.paddingM),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimens.gridSpacing,
              mainAxisSpacing: AppDimens.gridSpacing,
              childCount: items.length,
              itemBuilder: (context, index) =>
                  itemBuilder(context, items[index], index),
            ),
          ),
          if (isLoadingMore)
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
