import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/app_strings.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                Icon(
                  Icons.wallpaper,
                  size: 48.sp,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                SizedBox(height: 8.h),
                AutoSizeText(
                  AppStrings.appName,
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
          const Divider(),
          _buildMenuItem(
            context,
            Icons.settings_outlined,
            AppStrings.settings,
            () {
              Navigator.pop(context);
              context.push(AppRoutes.settings);
            },
          ),
          _buildMenuItem(context, Icons.info_outline, AppStrings.about, () {
            Navigator.pop(context);
            context.push(AppRoutes.about);
          }),
          const Divider(),
          _buildMenuItem(context, Icons.star_outline, AppStrings.rateApp, () {
            Navigator.pop(context);
          }),
          _buildMenuItem(
            context,
            Icons.share_outlined,
            AppStrings.shareApp,
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AutoSizeText(AppStrings.comingSoon)),
              );
            },
          ),
          _buildMenuItem(
            context,
            Icons.email_outlined,
            AppStrings.sendFeedback,
            () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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
