import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_strings.dart';

class FeatureComparisonWidget extends StatelessWidget {
  const FeatureComparisonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimens.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              AppStrings.comparePlans,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            SizedBox(height: AppDimens.paddingM),
            _buildHeader(theme),
            const Divider(height: 1),
            _buildRow(theme, 'Ads', AppStrings.adsIncluded, AppStrings.adFree),
            const Divider(height: 1),
            _buildRow(
              theme,
              'Downloads',
              AppStrings.limitedDownloads,
              AppStrings.unlimitedDownloads,
            ),
            const Divider(height: 1),
            _buildRow(
              theme,
              'Previews',
              AppStrings.limitedPreviews,
              AppStrings.unlimitedPreviews,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.paddingS),
      child: Row(
        children: [
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            flex: 2,
            child: Center(
              child: AutoSizeText(
                AppStrings.free,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: AutoSizeText(
                AppStrings.premiumBadge,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    ThemeData theme,
    String feature,
    String freeValue,
    String premiumValue,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.radiusM),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AutoSizeText(
              feature,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Icon(
                Icons.close,
                color: theme.colorScheme.error,
                size: 20,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
