import 'package:flutter/material.dart';

/// Design tokens derived from DESIGN.md and screen specifications for Kisan Setu.
class AppColors {
  AppColors._();

  // Primary Palette (Deep Green - Trust & Agriculture)
  static const Color primary = Color(0xFF00342B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF004D40);
  static const Color onPrimaryContainer = Color(0xFF7EBDAC);
  static const Color primaryFixed = Color(0xFFAFEFDD);
  static const Color primaryFixedDim = Color(0xFF94D3C1);
  static const Color onPrimaryFixed = Color(0xFF00201A);
  static const Color onPrimaryFixedVariant = Color(0xFF065043);
  static const Color inversePrimary = Color(0xFF94D3C1);
  static const Color surfaceTint = Color(0xFF29695B);

  // Secondary Palette (Bright Sunshine Yellow - Attention & Active States)
  static const Color secondary = Color(0xFF705D00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFDD400);
  static const Color onSecondaryContainer = Color(0xFF6F5C00);
  static const Color secondaryFixed = Color(0xFFFFE170);
  static const Color secondaryFixedDim = Color(0xFFE9C400);
  static const Color onSecondaryFixed = Color(0xFF221B00);
  static const Color onSecondaryFixedVariant = Color(0xFF544600);

  // Tertiary Palette (Mint White / Earthy Dark)
  static const Color tertiary = Color(0xFF253028);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF3B463E);
  static const Color onTertiaryContainer = Color(0xFFA7B4A9);
  static const Color tertiaryFixed = Color(0xFFD9E6DA);
  static const Color tertiaryFixedDim = Color(0xFFBDCABE);
  static const Color onTertiaryFixed = Color(0xFF131E17);
  static const Color onTertiaryFixedVariant = Color(0xFF3E4A41);

  // Mint Card Surface & Borders (High-Contrast rural outdoor visibility)
  static const Color mintCardSurface = Color(0xFFE8F5E9);
  static const Color mintCardBorder = Color(0xFFC8E6C9);
  static const Color mintCardAccent = Color(0xFF004D40);

  // Surface & Background Tiers
  static const Color background = Color(0xFFFCF9F8);
  static const Color onBackground = Color(0xFF1C1B1B);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color surfaceBright = Color(0xFFFCF9F8);
  static const Color surfaceDim = Color(0xFFDCD9D9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF0EDEC);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color surfaceVariant = Color(0xFFE5E2E1);
  static const Color onSurface = Color(0xFF1C1B1B);
  static const Color onSurfaceVariant = Color(0xFF3F4945);

  // Inverted surfaces
  static const Color inverseSurface = Color(0xFF313030);
  static const Color inverseOnSurface = Color(0xFFF3F0EF);

  // Outline & Dividers
  static const Color outline = Color(0xFF707975);
  static const Color outlineVariant = Color(0xFFBFC9C4);

  // Error Palette
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
}
