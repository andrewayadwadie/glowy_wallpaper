import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  static TextStyle headlineLarge() =>
      GoogleFonts.plusJakartaSans(fontSize: 28.sp, fontWeight: FontWeight.w700);

  static TextStyle headlineMedium() =>
      GoogleFonts.plusJakartaSans(fontSize: 24.sp, fontWeight: FontWeight.w600);

  static TextStyle titleLarge() =>
      GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.w600);

  static TextStyle titleMedium() =>
      GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.w500);

  static TextStyle bodyLarge() =>
      GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.w400);

  static TextStyle bodyMedium() =>
      GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w400);

  static TextStyle labelLarge() =>
      GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w500);

  static TextStyle labelSmall() =>
      GoogleFonts.plusJakartaSans(fontSize: 12.sp, fontWeight: FontWeight.w400);
}
