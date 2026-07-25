import 'dart:collection';

import 'package:flutter/foundation.dart';

/// In-memory memo of decoded wallpaper aspect ratios, keyed by image URL.
///
/// A grid card ([StaggeredWallpaperCard]) is a [StatefulWidget] whose element
/// is destroyed when it scrolls out of the grid's cache-extent and recreated
/// on scroll-back. Without this memo, every recreation re-probes the image
/// stream and replays the shimmer skeleton + 300 ms resize animation even
/// though the bytes are already on disk / in memory — the "grey flash on
/// scroll-back". Caching the ratio lets a rebuilt card render its final layout
/// on the first frame: no shimmer skeleton, no re-probe, no resize animation.
///
/// Values are tiny (one [double] per URL), so growth is bounded by a simple
/// LRU purely to avoid unbounded accumulation across very long sessions.
class AspectRatioCache {
  AspectRatioCache._();

  static const int maxEntries = 2000;

  // LinkedHashMap preserves insertion order; re-inserting on access yields
  // least-recently-used eviction from the front of the map.
  static final LinkedHashMap<String, double> _ratios =
      LinkedHashMap<String, double>();

  /// Returns the cached aspect ratio for [url], or `null` if not yet decoded.
  /// A hit is promoted to most-recently-used.
  static double? get(String url) {
    final ratio = _ratios.remove(url);
    if (ratio == null) return null;
    _ratios[url] = ratio;
    return ratio;
  }

  /// Stores the decoded [ratio] for [url], evicting the oldest entry when the
  /// cache is full. Non-positive ratios are ignored (invalid/undecoded).
  static void put(String url, double ratio) {
    if (ratio <= 0) return;
    _ratios.remove(url);
    _ratios[url] = ratio;
    if (_ratios.length > maxEntries) {
      _ratios.remove(_ratios.keys.first);
    }
  }

  @visibleForTesting
  static int get length => _ratios.length;

  @visibleForTesting
  static void clear() => _ratios.clear();
}
