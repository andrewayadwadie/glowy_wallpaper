import 'dart:io' show Platform;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../app/domain/entities/app_metadata_entity.dart';
import '../../../auth/presentation/cubit/subscription_cubit.dart';
import '../cubit/home_cubit.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appMetadata = context.watch<HomeCubit>().state.appMetadata;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 320.w),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.wallpaper,
                      size: 48.sp,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AutoSizeText(
                    appMetadata?.name ?? AppStrings.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
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
            _buildMenuItem(
              context,
              Icons.workspace_premium,
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
            const Divider(),
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
            const Divider(),
            _buildMenuItem(context, Icons.star_outline, AppStrings.rateApp, () {
              Navigator.pop(context);
              _rateApp(appMetadata);
            }),
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
      storeUrl = appMetadata?.iphoneShareLink ??
          'https://apps.apple.com/app/id${AppConfig.iosAppId}';
    } else {
      storeUrl = appMetadata?.androidShareLink ??
          'https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}';
    }
    Share.share('Check out ${appMetadata?.name ?? AppStrings.appName}! $storeUrl');
  }

  Future<void> _sendFeedback(AppMetadataEntity? appMetadata) async {
    final email = appMetadata?.contactEmail ?? AppConfig.feedbackEmail;
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': '${appMetadata?.name ?? AppStrings.appName} Feedback'},
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
          const SnackBar(content: Text(AppStrings.cannotOpenSubscriptionManager)),
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
