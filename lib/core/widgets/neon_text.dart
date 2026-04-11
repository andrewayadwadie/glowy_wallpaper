import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Text with a layered neon glow effect using the app's primary cyan.
///
/// Uses 3 shadow layers at increasing blur radii for a realistic
/// neon tube look — no third-party package needed.
class NeonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int maxLines;
  final Color glowColor;

  const NeonText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines = 1,
    this.glowColor = AppColors.darkPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ??
        Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white);

    return AutoSizeText(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      style: baseStyle?.copyWith(
        shadows: [
          // Inner crisp glow
          Shadow(color: glowColor.withValues(alpha: 0.8), blurRadius: 8),
          // Mid-range bloom
          Shadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 20),
          // Outer ambient glow
          Shadow(color: glowColor.withValues(alpha: 0.3), blurRadius: 40),
        ],
      ),
    );
  }
}
