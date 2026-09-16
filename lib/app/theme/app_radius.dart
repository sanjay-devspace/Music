/// Border-radius tokens — layered radius language (not everything rounded).
///
/// Small for inline chips, medium for list rows, large for cards, hero for
/// featured surfaces, bottom nav and the player get their own signatures.
abstract class AppRadius {
  static const double xs = 6;
  static const double sm = 10; // Small (spec)
  static const double md = 14;
  static const double lg = 16; // Medium (spec)
  static const double xl = 20;
  static const double xxl = 24; // Large (spec)
  static const double hero = 28; // Hero (spec)
  static const double bottomNav = 28; // Bottom navigation (spec)
  static const double player = 32; // Player (spec)
  static const double full = 999;
}