import 'package:flutter/material.dart';

abstract class AppColors {
  // Light theme
  static const Color primary = Color(0xFF06B6D4);
  static const Color onPrimary = Colors.white;
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF0F172A);
  static const Color error = Color(0xFFEF4444);

  // Dark theme
  static const Color darkPrimary = Color(0xFF22D3EE);
  static const Color darkOnPrimary = Color(0xFF0F172A);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFF1F5F9);
  static const Color darkError = Color(0xFFF87171);

  // Semantic text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color border = Color(0xFFE2E8F0);

  // Semantic status
  static const Color success = Color(0xFF10B981);
  static const Color darkSuccess = Color(0xFF34D399);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
  static const Color darkShimmerBase = Color(0xFF334155);
  static const Color darkShimmerHighlight = Color(0xFF475569);
}
