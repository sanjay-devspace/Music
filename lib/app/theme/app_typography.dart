import 'package:flutter/material.dart';

/// Typography tokens for TUNEHIVE.
///
/// Named styles are used everywhere instead of raw `TextStyle`s so the font
/// system can evolve in one place. Sizes here are base values — responsive
/// screens scale them through the responsive engine.
abstract class AppTypography {
  static const String fontFamily = 'Inter';

  static const double displayLargeSize = 56;
  static const double displayMediumSize = 44;
  static const double headlineSize = 32;
  static const double titleSize = 20;
  static const double bodySize = 16;
  static const double labelSize = 14;
  static const double captionSize = 12;

  static const FontWeight displayWeight = FontWeight.w800;
  static const FontWeight headlineWeight = FontWeight.w700;
  static const FontWeight titleWeight = FontWeight.w600;
  static const FontWeight labelWeight = FontWeight.w700;
}

/// Static base text styles (non-responsive, for tokens that rarely change).
abstract class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.displayLargeSize,
    fontWeight: AppTypography.displayWeight,
    letterSpacing: -1.5,
    height: 1.05,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.displayMediumSize,
    fontWeight: AppTypography.displayWeight,
    letterSpacing: -1,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.headlineSize,
    fontWeight: AppTypography.headlineWeight,
    letterSpacing: -0.5,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.titleSize,
    fontWeight: AppTypography.titleWeight,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySize,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.labelSize,
    fontWeight: AppTypography.labelWeight,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.captionSize,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: AppColors.textMuted,
  );
}