import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/colors.dart';

class AppShimmerWidget extends StatelessWidget {
  final Widget child;

  const AppShimmerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase,
      highlightColor: isDark
          ? AppColors.darkShimmerHighlight
          : AppColors.shimmerHighlight,
      child: child,
    );
  }
}
