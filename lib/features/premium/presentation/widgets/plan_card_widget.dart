import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_strings.dart';
import '../../domain/entities/premium_product_entity.dart';

class PlanCardWidget extends StatelessWidget {
  final PremiumProductEntity product;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCardWidget({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.dividerColor;

    final periodLabel = product.billingPeriod == BillingPeriod.monthly
        ? AppStrings.monthly
        : AppStrings.yearly;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$periodLabel ${product.price}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 150.w,
          padding: EdgeInsets.all(AppDimens.paddingM),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                periodLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
              SizedBox(height: 8.h),
              AutoSizeText(
                product.price,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                maxLines: 1,
              ),
              SizedBox(height: 4.h),
              AutoSizeText(
                product.billingPeriod == BillingPeriod.monthly
                    ? AppStrings.perMonth
                    : AppStrings.perYear,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
              ),
              if (isSelected) ...[
                SizedBox(height: 8.h),
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 24.r,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
