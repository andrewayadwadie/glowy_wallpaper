import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_strings.dart';

/// A small "Exclusive" flag with a star icon, shown on top-rated wallpapers.
///
/// Place inside a [Stack] positioned at the desired corner.
class ExclusiveBadge extends StatelessWidget {
  const ExclusiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 10.sp,
            color: colorScheme.onPrimary,
          ),
          SizedBox(width: 2.w),
          Text(
            AppStrings.exclusive,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
