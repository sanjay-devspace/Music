/// Horizontal / vertical spacing tokens.
///
/// All spacing values used in layouts are sourced here. The responsive
/// system may multiply these by a factor, but raw pixel values should never
/// appear in view code.
abstract class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

/// Spacing scale strings for section rhythm.
abstract class AppGrid {
  /// Maximum comfortable content width on desktop.
  static const double maxContentWidth = 1440;
}