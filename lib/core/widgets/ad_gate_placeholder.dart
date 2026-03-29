import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowy_wallpaper/core/services/ad_helper.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_state.dart';

/// Rewarded ad gate for download/preview actions.
/// For premium users, immediately proceeds with the action.
/// For free users, shows a rewarded ad before allowing the action.
/// Returns true if the action should proceed, false otherwise.
Future<bool> adGatePlaceholder({
  required BuildContext context,
  required Future<void> Function() onProceed,
  required String action,
}) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (context) => AdGateWidget(action: action, onProceed: onProceed),
    ),
  );

  return result ?? false;
}

class AdGateWidget extends StatefulWidget {
  final String action;
  final Future<void> Function() onProceed;

  const AdGateWidget({
    super.key,
    required this.action,
    required this.onProceed,
  });

  @override
  State<AdGateWidget> createState() => _AdGateWidgetState();
}

class _AdGateWidgetState extends State<AdGateWidget> {
  bool _isShowingAd = false;
  bool _proceeded = false;
  String _message = 'Loading ad...';

  @override
  void initState() {
    super.initState();
    log("adGatePlaceholder initState");
    _checkAndShowAd();
  }

  Future<void> _checkAndShowAd() async {
    final subscriptionState = context.read<SubscriptionCubit>().state;

    if (subscriptionState is SubscriptionPremium) {
      log("User is premium, proceeding directly");
      await _proceedWithAction();
      return;
    }

    final adHelper = AdHelper.instance;

    if (_isShowingAd) return;
    setState(() => _isShowingAd = true);

    log("Starting to show rewarded ad for action: ${widget.action}");

    final rewardEarned = await adHelper.showRewardedInterstitialAd(action: widget.action);

    log("Reward earned: $rewardEarned");

    if (rewardEarned) {
      await _proceedWithAction();
    } else {
      log("Ad failed or not earned");
      if (mounted) {
        setState(() => _message = 'Ad not available');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.adUnavailable)));
      }
    }

    if (mounted) {
      Navigator.of(context).pop(rewardEarned);
    }
  }

  Future<void> _proceedWithAction() async {
    if (_proceeded) return;
    log("Proceeding with action");
    _proceeded = true;
    await widget.onProceed();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.scrim.withAlpha(140),
      body: Center(
        child: _isShowingAd
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
