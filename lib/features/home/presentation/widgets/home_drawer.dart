// ignore_for_file: unused_element

import 'dart:io' show Platform;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/neon_text.dart';
import '../../../app/domain/entities/app_metadata_entity.dart';
import '../../../auth/presentation/cubit/subscription_cubit.dart';
import '../../../premium/presentation/cubit/premium_cubit.dart';
import '../../../premium/presentation/cubit/premium_state.dart';

import '../cubit/home_cubit.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appMetadata = context.watch<HomeCubit>().state.appMetadata;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 320.w),
      child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header — app icon + title side-by-side
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.paddingM,
                  AppDimens.paddingL,
                  AppDimens.paddingM,
                  AppDimens.paddingL,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.radiusL),
                      child: SvgPicture.asset(
                        AppAssets.logoSvg,
                        width: 64.w,
                        height: 64.w,
                      ),
                    ),
                    SizedBox(width: AppDimens.paddingM),
                    Expanded(
                      child: NeonText(
                        appMetadata?.name ?? AppStrings.appName,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimens.paddingS),

              // Main navigation
              _buildMenuItem(context, Icons.home_outlined, AppStrings.home, () {
                Navigator.pop(context);
                context.go(AppRoutes.home);
              }),
              _buildMenuItem(
                context,
                Icons.favorite_outline,
                AppStrings.favorites,
                () {
                  Navigator.pop(context);
                  context.push(AppRoutes.favorites);
                },
              ),
              _buildMenuItem(
                context,
                Icons.download_outlined,
                AppStrings.myDownloads,
                () {
                  Navigator.pop(context);
                  context.push(AppRoutes.downloads);
                },
              ),
              // TODO(ads-disabled-018): purchase entry point hidden — this
              // block was already commented out before this feature; the
              // marker makes it traceable and reversible with everything
              // else. Restore Purchases now has its own tile below instead.
              /*/
              if (!context.watch<SubscriptionCubit>().isPremium)
                _buildMenuItem(
                  context,
                  Icons.star_outline,
                  AppStrings.premium,
                  () {
                    Navigator.pop(context);
                    context.push(AppRoutes.premium);
                  },
                ),
              if (context.watch<SubscriptionCubit>().isPremium)
                _buildMenuItem(
                  context,
                  Icons.manage_accounts_outlined,
                  AppStrings.manageSubscription,
                  () {
                    Navigator.pop(context);
                    _openSubscriptionManagement(context);
                  },
                ),
*/
              SizedBox(height: AppDimens.paddingS),
              const Divider(),
              SizedBox(height: AppDimens.paddingS),

              // Info section
              // TODO(ads-disabled-018): standalone restore tile added — the
              // purchase entry point is hidden, so existing subscribers need
              // a way to recover entitlements without the purchase page.
              _RestorePurchasesTile(buildMenuItem: _buildMenuItem),
              _buildMenuItem(context, Icons.info_outline, AppStrings.about, () {
                Navigator.pop(context);
                context.push(AppRoutes.about, extra: appMetadata?.about ?? '');
              }),
              _buildMenuItem(
                context,
                Icons.privacy_tip_outlined,
                AppStrings.privacyPolicy,
                () {
                  Navigator.pop(context);
                  context.push(
                    AppRoutes.privacyPolicy,
                    extra: appMetadata?.privacyPolicy ?? '',
                  );
                },
              ),
              _buildMenuItem(
                context,
                Icons.description_outlined,
                AppStrings.termsOfUse,
                () {
                  Navigator.pop(context);
                  context.push(
                    AppRoutes.termsOfUse,
                    extra: appMetadata?.termsOfUse ?? '',
                  );
                },
              ),

              SizedBox(height: AppDimens.paddingS),
              const Divider(),
              SizedBox(height: AppDimens.paddingS),

              // Actions section
              _buildMenuItem(
                context,
                Icons.star_outline,
                AppStrings.rateApp,
                () {
                  Navigator.pop(context);
                  _rateApp(appMetadata);
                },
              ),
              _buildMenuItem(
                context,
                Icons.share_outlined,
                AppStrings.shareApp,
                () {
                  Navigator.pop(context);
                  _shareApp(appMetadata);
                },
              ),
              _buildMenuItem(
                context,
                Icons.email_outlined,
                AppStrings.sendFeedback,
                () {
                  Navigator.pop(context);
                  _sendFeedback(appMetadata);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rateApp(AppMetadataEntity? appMetadata) async {
    final Uri url;
    if (Platform.isIOS) {
      url = Uri.parse(
        appMetadata?.iphoneShareLink ??
            'https://apps.apple.com/app/id${AppConfig.iosAppId}?action=write-review',
      );
    } else {
      url = Uri.parse(
        appMetadata?.androidShareLink ??
            'https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}',
      );
    }
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp(AppMetadataEntity? appMetadata) {
    final String storeUrl;
    if (Platform.isIOS) {
      storeUrl =
          appMetadata?.iphoneShareLink ??
          'https://apps.apple.com/app/id${AppConfig.iosAppId}';
    } else {
      storeUrl =
          appMetadata?.androidShareLink ??
          'https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}';
    }
    Share.share(
      'Check out ${appMetadata?.name ?? AppStrings.appName}! $storeUrl',
    );
  }

  Future<void> _sendFeedback(AppMetadataEntity? appMetadata) async {
    final email = appMetadata?.contactEmail ?? AppConfig.feedbackEmail;
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': '${appMetadata?.name ?? AppStrings.appName} Feedback',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openSubscriptionManagement(BuildContext context) async {
    final Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    }
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.cannotOpenSubscriptionManager),
          ),
        );
      }
    }
  }

  ListTile _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: AutoSizeText(title, maxLines: 1),
      onTap: onTap,
    );
  }
}

/// Standalone restore-purchases entry point (FR-021, FR-022): recovers an
/// existing subscriber's entitlement without ever opening the purchase page.
/// Owns a local, short-lived [PremiumCubit] — the drawer has no app-wide
/// provider for it.
class _RestorePurchasesTile extends StatelessWidget {
  const _RestorePurchasesTile({required this.buildMenuItem});

  final ListTile Function(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  )
  buildMenuItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PremiumCubit>(
      create: (_) =>
          sl<PremiumCubit>(param1: context.read<SubscriptionCubit>()),
      child: BlocConsumer<PremiumCubit, PremiumState>(
        listener: (context, state) {
          final message = state.successMessage ?? state.errorMessage;
          if (message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) => buildMenuItem(
          context,
          Icons.restore_outlined,
          AppStrings.restorePurchase,
          () => context.read<PremiumCubit>().restore(),
        ),
      ),
    );
  }
}
