import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography definitions matching DESIGN.md with Be Vietnam Pro and Noto Sans.
class AppTypography {
  AppTypography._();

  static TextStyle headlineLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 36 / 28,
      color: color,
    );
  }

  static TextStyle headlineMedium({Color color = AppColors.onSurface}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 28 / 22,
      color: color,
    );
  }

  static TextStyle headlineSmall({Color color = AppColors.onSurface}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 24 / 18,
      color: color,
    );
  }

  static TextStyle bodyLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.notoSans(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 26 / 18,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.notoSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: color,
    );
  }

  static TextStyle bodySmall({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.notoSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: color,
    );
  }

  static TextStyle labelLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 20 / 16,
      color: color,
    );
  }

  static TextStyle labelMedium({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 16 / 14,
      color: color,
    );
  }

  static TextStyle labelSmall({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      color: color,
    );
  }
}
