// TODO(ads-disabled-018): entire ad layer paused — restore by removing this
// header and the closing block comment below. See specs/018-disable-ads-isolate-downloads/.
/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../features/auth/presentation/cubit/subscription_cubit.dart';
import '../../../features/auth/presentation/cubit/subscription_state.dart';
import '../../di/injection_container.dart';
import '../../utils/app_dimens.dart';
import '../ad_ids.dart';

/// Seam for [AdSize.getAnchoredAdaptiveBannerAdSize] (static — not mockable
/// directly in widget tests).
typedef BannerSizeResolver = Future<AdSize?> Function(int truncatedWidth);

/// Seam for constructing the [BannerAd] so tests can fake load outcomes.
typedef BannerAdBuilder =
    BannerAd Function(AdSize size, BannerAdListener listener);

/// Self-contained anchored adaptive banner for the Home bottom slot
/// (US3, FR-011–FR-013). Replaces `BannerAdWidget`.
///
/// - Reserves [AppDimens.bannerSlotFallbackHeight] while resolving/loading
///   so the layout doesn't jump.
/// - On load failure (after one retry) the slot collapses — no grey box.
/// - Premium users get no slot at all.
/// - Owns and disposes its [BannerAd] (constitution VI).
class AnchoredAdaptiveBanner extends StatefulWidget {
  const AnchoredAdaptiveBanner({
    super.key,
    @visibleForTesting this.sizeResolver,
    @visibleForTesting this.adBuilder,
  });

  final BannerSizeResolver? sizeResolver;
  final BannerAdBuilder? adBuilder;

  @override
  State<AnchoredAdaptiveBanner> createState() => _AnchoredAdaptiveBannerState();
}

enum _BannerStatus { loading, loaded, failed }

class _AnchoredAdaptiveBannerState extends State<AnchoredAdaptiveBanner> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  _BannerStatus _status = _BannerStatus.loading;
  bool _retried = false;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Needs MediaQuery — runs here (once) instead of initState.
    if (!_loadStarted) {
      _loadStarted = true;
      _resolveSizeAndLoad();
    }
  }

  Future<void> _resolveSizeAndLoad() async {
    final width = MediaQuery.of(context).size.width.truncate();
    final resolver =
        widget.sizeResolver ??
        (int w) =>
            AdSize.getAnchoredAdaptiveBannerAdSize(Orientation.portrait, w);

    AdSize? size;
    try {
      size = await resolver(width);
    } catch (e) {
      debugPrint('Banner size resolution failed: $e');
    }

    if (!mounted) return;
    if (size == null) {
      setState(() => _status = _BannerStatus.failed);
      return;
    }

    _adSize = size;
    _loadBanner(size);
  }

  void _loadBanner(AdSize size) {
    final listener = BannerAdListener(
      onAdLoaded: (_) {
        debugPrint('AnchoredAdaptiveBanner loaded');
        if (mounted) setState(() => _status = _BannerStatus.loaded);
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('AnchoredAdaptiveBanner failed to load: $error');
        ad.dispose();
        if (!mounted) return;
        if (!_retried) {
          // One retry, then collapse (FR-012).
          _retried = true;
          _loadBanner(size);
        } else {
          setState(() {
            _bannerAd = null;
            _status = _BannerStatus.failed;
          });
        }
      },
    );

    final builder =
        widget.adBuilder ??
        (AdSize size, BannerAdListener listener) => BannerAd(
          adUnitId: sl<AdIds>().idFor(AdPlacement.homeBanner),
          size: size,
          request: const AdRequest(),
          listener: listener,
        );

    _bannerAd = builder(size, listener);
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionPremium) {
          return const SizedBox.shrink();
        }

        switch (_status) {
          case _BannerStatus.failed:
            return const SizedBox.shrink();
          case _BannerStatus.loading:
            return SafeArea(
              child: SizedBox(height: AppDimens.bannerSlotFallbackHeight),
            );
          case _BannerStatus.loaded:
            final ad = _bannerAd;
            final size = _adSize;
            if (ad == null || size == null) return const SizedBox.shrink();
            return SafeArea(
              child: SizedBox(
                width: size.width.toDouble(),
                height: size.height.toDouble(),
                child: AdWidget(ad: ad),
              ),
            );
        }
      },
    );
  }
}
*/
