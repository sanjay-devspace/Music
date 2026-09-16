import 'package:flutter/material.dart';

/// Shadow presets — soft depth on navy, never heavy.
abstract class AppShadows {
  /// Standard card shadow, used beneath editorial music cards.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  /// Subtle elevation for list rows and small tiles.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Upward shadow for floating bars (mini player, bottom nav).
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 28,
      offset: Offset(0, -6),
    ),
  ];

  /// Coral glow for primary actions and the hero play button.
  static const List<BoxShadow> coralGlow = [
    BoxShadow(
      color: Color(0x59FF5B63),
      blurRadius: 44,
      spreadRadius: -6,
    ),
  ];
}