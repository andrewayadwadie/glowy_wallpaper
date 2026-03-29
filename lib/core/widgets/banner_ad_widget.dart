import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowy_wallpaper/core/services/ad_helper.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_state.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    AdHelper.instance.loadBannerAd();
    AdHelper.instance.bannerAdLoaded.addListener(_onBannerStateChanged);
  }

  void _onBannerStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AdHelper.instance.bannerAdLoaded.removeListener(_onBannerStateChanged);
    AdHelper.instance.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionPremium) {
          return const SizedBox.shrink();
        }

        final banner = AdHelper.instance.bannerAd;
        if (banner == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: AdSize.banner.width.toDouble(),
          height: AdSize.banner.height.toDouble(),
          child: AdWidget(ad: banner),
        );
      },
    );
  }
}
