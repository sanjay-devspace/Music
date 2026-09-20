import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:flutter/material.dart';

/// TUNEHIVE centralized color system — Deep Navy + Coral + White.
///
/// All widgets must reference colors from this file — never hardcode hex
/// values directly in views.
abstract class AppColors {
  // ---- Brand accents -----------------------------------------------------
  static const Color primary = TuneHiveColors.electricBlue; // Coral
  static const Color primaryDark = Color(0xFFE94B54); // Coral dark
  static const Color primaryLight = Color(0xFFFF767D); // Coral light
  static const Color onPrimary = Color(0xFF050708); // Black on coral

  // ---- Backgrounds (deep navy) ------------------------------------------
  static const Color background = TuneHiveColors.cardSurface; // Primary navy
  static const Color backgroundDeep = Color(0xFF0D181D); // Deep navy
  static const Color surface = Color(0xFF1B2D34); // Surface
  static const Color surfaceLight = Color(0xFF24383F); // Surface light

  // ---- Text --------------------------------------------------------------
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB9C0C3);
  static const Color textMuted = Color(0xFF7C878B);

  // ---- White --- black surfaces -------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF6F7F5);
  static const Color black = Color(0xFF050708);

  // ---- Utility ------------------------------------------------------------
  static const Color divider = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color dividerStrong = Color(0x29FFFFFF);
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CD964);
  static const Color warning = Color(0xFFFFB020);

  // ---- Player palette ------------------------------------------------------
  /// Signature contrast: deep navy backdrop, off-white player surface and
  /// black playback controls.
  static const Color playerBackground = background;
  static const Color playerSurface = offWhite;
  static const Color playerControls = black;

  // ---- Gradients ------------------------------------------------------------
  static const Color backgroundGradientStart = Color(0xFF1B2D34);
  static const Color backgroundGradientEnd = backgroundDeep;

  static const List<Color> onboardingGradient = [
    Color(0xFF1B2D34),
    Color(0xFF0D181D),
  ];

  /// Overlay placed on top of artwork-derived backgrounds to keep the UI
  /// readable.
  static const Color playerScrim = Color(0xCC0D181D);
}

/// Semantic color shortcuts for dark theme context.
abstract class ThemeColors {
  static const background = TuneHiveColors.charcoalBlack;
  static const backgroundDeep = TuneHiveColors.charcoalBlack;
  static const surface = TuneHiveColors.cardSurface;
  static const surfaceLight = TuneHiveColors.elevatedSurface;
  static const textPrimary = TuneHiveColors.coolWhite;
  static const textSecondary = TuneHiveColors.coolWhite;
  static const textMuted = TuneHiveColors.mutedText;
  static const primary = TuneHiveColors.electricBlue;
  static const divider = TuneHiveColors.elevatedSurface;
}