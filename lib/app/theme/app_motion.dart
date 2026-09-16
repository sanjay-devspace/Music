import 'package:flutter/animation.dart';

/// Centralized motion tokens — durations + curves for the entire app.
///
/// Every animation should reference these constants so the motion language
/// stays consistent: micro interactions feel snappy, screen transitions feel
/// deliberate, and nothing ever feels bouncy by accident.
abstract class AppMotion {
  AppMotion._();

  // ---- Durations ----------------------------------------------------------
  /// Button presses, icon toggles, chip selection. 100-180ms.
  static const Duration micro = Duration(milliseconds: 140);

  /// Cards, mood selection, mini player updates. 200-300ms.
  static const Duration standard = Duration(milliseconds: 240);

  /// Screen transitions, sidebar expansion. 300-450ms.
  static const Duration large = Duration(milliseconds: 360);

  /// Hero / shared-element transitions. 350-500ms.
  static const Duration hero = Duration(milliseconds: 440);

  /// Form / loading placeholders. Gentle, slow.
  static const Duration slow = Duration(milliseconds: 600);

  // ---- Curves -------------------------------------------------------------
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// Press feedback curve (small + quick).
  static const Curve press = Curves.easeOut;

  /// Entrance curve used by staged content.
  static const Curve entrance = Curves.easeOutCubic;

  // ---- Staggered entrance -------------------------------------------------
  /// Spacing between staged children in a staggered entrance.
  static const Duration staggerStep = Duration(milliseconds: 45);

  /// Initial offset for a the first staged child.
  static const Duration staggerBase = Duration(milliseconds: 40);
}