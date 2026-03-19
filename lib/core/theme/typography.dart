import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  static TextStyle headlineLarge() =>
      GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.w700);

  static TextStyle headlineMedium() =>
      GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w600);

  static TextStyle titleLarge() =>
      GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w600);

  static TextStyle titleMedium() =>
      GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500);

  static TextStyle bodyLarge() =>
      GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w400);

  static TextStyle bodyMedium() =>
      GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400);

  static TextStyle labelLarge() =>
      GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500);

  static TextStyle labelSmall() =>
      GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w400);
}
