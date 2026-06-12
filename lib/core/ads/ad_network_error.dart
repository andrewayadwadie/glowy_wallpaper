import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Pure classifier for network-related ad failures (research R2).
///
/// Used by the rewarded download gate to decide graceful degradation:
/// a NETWORK failure grants the download anyway; any other failure or an
/// early dismissal does not (FR-002/FR-004).
abstract final class AdNetworkError {
  /// `ERROR_CODE_NETWORK_ERROR` on Android; `GADErrorNetworkError` on iOS.
  static const int networkErrorCode = 2;

  static const List<String> _networkKeywords = <String>[
    'network',
    'internet',
    'connection',
    'offline',
    'timed out',
  ];

  /// Whether [error] (a [LoadAdError] or a show-time [AdError]) represents a
  /// network-related failure.
  static bool isNetworkError(AdError error) {
    if (error.code == networkErrorCode) return true;
    final haystack = '${error.domain} ${error.message}'.toLowerCase();
    return _networkKeywords.any(haystack.contains);
  }
}
