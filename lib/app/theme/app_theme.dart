import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/tunehive_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Centralized Material 3 theme for TUNEHIVE — Deep Navy + Royal Blue + Electric Blue.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: TuneHiveColors.charcoalBlack,
      colorScheme: const ColorScheme.dark(
        primary: TuneHiveColors.electricBlue,
        onPrimary: TuneHiveColors.coolWhite,
        secondary: TuneHiveColors.electricBlue,
        onSecondary: TuneHiveColors.coolWhite,
        surface: TuneHiveColors.cardSurface,
        onSurface: TuneHiveColors.coolWhite,
        surfaceContainerHighest: TuneHiveColors.elevatedSurface,
        onSurfaceVariant: TuneHiveColors.coolWhite,
        outline: TuneHiveColors.elevatedSurface,
        error: Colors.red,
      ),
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: TuneHiveColors.coolWhite, displayColor: TuneHiveColors.coolWhite)
          .copyWith(
            displayLarge: AppTextStyles.displayLarge,
            displayMedium: AppTextStyles.displayMedium,
            headlineLarge: AppTextStyles.headline,
            headlineMedium: AppTextStyles.headline.copyWith(fontSize: 24),
            titleLarge: AppTextStyles.title.copyWith(fontSize: 22),
            titleMedium: AppTextStyles.title.copyWith(fontSize: 20),
            bodyLarge: AppTextStyles.body,
            bodyMedium: AppTextStyles.body.copyWith(fontSize: 14),
            labelLarge: AppTextStyles.label,
            labelMedium: AppTextStyles.label.copyWith(fontSize: 12),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.title,
      ),
      iconTheme: const IconThemeData(color: TuneHiveColors.coolWhite, size: 24),
      dividerTheme: const DividerThemeData(color: TuneHiveColors.elevatedSurface, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TuneHiveColors.cardSurface,
        hintStyle: const TextStyle(color: TuneHiveColors.mutedText, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: TuneHiveColors.electricBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TuneHiveColors.electricBlue,
          foregroundColor: TuneHiveColors.coolWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: AppTextStyles.label,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TuneHiveColors.electricBlue,
          foregroundColor: TuneHiveColors.coolWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: AppTextStyles.label,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TuneHiveColors.elevatedSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        contentTextStyle: const TextStyle(color: TuneHiveColors.coolWhite),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: TuneHiveColors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: const TextStyle(color: TuneHiveColors.coolWhite),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TuneHiveColors.electricBlue,
        linearTrackColor: TuneHiveColors.elevatedSurface,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: TuneHiveColors.electricBlue,
        inactiveTrackColor: TuneHiveColors.elevatedSurface,
        thumbColor: TuneHiveColors.coolWhite,
        overlayColor: const Color(0x4D006BFF), // Glow
        trackHeight: 3,
      ),
    );
  }
}