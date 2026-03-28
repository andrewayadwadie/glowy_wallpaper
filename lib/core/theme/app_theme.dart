import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

abstract class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge(),
      headlineMedium: AppTextStyles.headlineMedium(),
      titleLarge: AppTextStyles.titleLarge(),
      titleMedium: AppTextStyles.titleMedium(),
      bodyLarge: AppTextStyles.bodyLarge(),
      bodyMedium: AppTextStyles.bodyMedium(),
      labelLarge: AppTextStyles.labelLarge(),
      labelSmall: AppTextStyles.labelSmall(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(color: AppColors.surface, elevation: 0),
    iconTheme: IconThemeData(color: AppColors.onSurface),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      error: AppColors.darkError,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge(),
      headlineMedium: AppTextStyles.headlineMedium(),
      titleLarge: AppTextStyles.titleLarge(),
      titleMedium: AppTextStyles.titleMedium(),
      bodyLarge: AppTextStyles.bodyLarge(),
      bodyMedium: AppTextStyles.bodyMedium(),
      labelLarge: AppTextStyles.labelLarge(),
      labelSmall: AppTextStyles.labelSmall(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(color: AppColors.darkSurface, elevation: 0),
    iconTheme: IconThemeData(color: AppColors.darkOnSurface),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkShimmerBase,
    ),
  );
}
