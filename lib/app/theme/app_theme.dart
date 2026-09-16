import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Centralized Material 3 theme for TUNEHIVE — Deep Navy + Coral + White.
///
/// Wires the color tokens, typography and component styles into the
/// framework. Custom widgets reference the tokens directly; framework
/// surfaces (buttons, inputs, overlays) pick their look up from here.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceLight,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.divider,
        error: AppColors.error,
      ),
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary)
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
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: AppTextStyles.label,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: AppTextStyles.label,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: const TextStyle(color: AppColors.textPrimary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.dividerStrong,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.dividerStrong,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        trackHeight: 3,
      ),
    );
  }
}