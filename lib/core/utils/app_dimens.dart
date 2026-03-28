import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppDimens {
  static double get paddingXS => 4.w;
  static double get paddingS => 8.w;
  static double get paddingM => 16.w;
  static double get paddingL => 24.w;
  static double get paddingXL => 32.w;

  static double get radiusS => 8.r;
  static double get radiusM => 12.r;
  static double get radiusL => 16.r;
  static double get radiusXL => 24.r;

  static double get iconS => 16.w;
  static double get iconM => 24.w;
  static double get iconL => 32.w;

  static double get categoryChipHeight => 48.h;
  static double get categoryChipPaddingH => 12.w;
  static double get categoryChipPaddingV => 10.h;
  static double get categoryChipGap => 8.w;
  static double get categorySelectorHeight => 48.h;

  static double get bentoLargeCardHeight => 200.h;
  static double get bentoSmallCardHeight => 150.h;
  static double get bentoCardGap => 8.w;

  static double get gridSpacing => 8.w;
  static double get paginationThreshold => 200.h;

  /// Adaptive grid column count based on screen width.
  /// Used by content grids and loading skeletons alike.
  static int gridColumnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 400) return 2;
    if (width < 700) return 3;
    return 4;
  }
}
