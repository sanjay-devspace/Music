import 'package:flutter/animation.dart';
import 'package:tunehive/app/theme/app_motion.dart';

/// Motion constants used across the animation layer.
///
/// Thin alias over [AppMotion] so animation code reads consistently.
abstract class AnimationConstants {
  static const Duration micro = AppMotion.micro;
  static const Duration standard = AppMotion.standard;
  static const Duration large = AppMotion.large;
  static const Duration hero = AppMotion.hero;
  static const Duration slow = AppMotion.slow;

  static const Curve easeOut = AppMotion.easeOut;
  static const Curve easeInOut = AppMotion.easeInOut;
  static const Curve fastOutSlowIn = AppMotion.fastOutSlowIn;
  static const Curve press = AppMotion.press;
  static const Curve entrance = AppMotion.entrance;

  static const Duration staggerStep = AppMotion.staggerStep;
  static const Duration staggerBase = AppMotion.staggerBase;
}

/// Standard vertical offset used by entrance transitions (px).
const double entranceOffset = 18.0;

/// Standard scale range for content entrances.
const double entranceScaleFrom = 0.96;