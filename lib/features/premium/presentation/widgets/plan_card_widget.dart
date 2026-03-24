import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150.w,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              product.billingPeriod == BillingPeriod.monthly
                  ? 'Monthly'
                  : 'Yearly',
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
                  ? '/month'
                  : '/year',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    );
  }
}
