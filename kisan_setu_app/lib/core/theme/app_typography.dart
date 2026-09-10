import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration matching Kisan Setu design system.
/// Uses 'Be Vietnam Pro' for headlines and labels, 'Noto Sans' for high-legibility body/multilingual text.
class AppTypography {
  static TextStyle headlineLg({Color color = AppColors.primary}) =>
      GoogleFonts.beVietnamPro(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle headlineMd({Color color = AppColors.primary}) =>
      GoogleFonts.beVietnamPro(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle headlineSm({Color color = AppColors.primary}) =>
      GoogleFonts.beVietnamPro(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.notoSans(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodyMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.notoSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle labelLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.beVietnamPro(
        fontSize: 16,
        height: 20 / 16,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle labelMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.beVietnamPro(
        fontSize: 14,
        height: 16 / 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle labelSm({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.beVietnamPro(
        fontSize: 12,
        height: 14 / 12,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
