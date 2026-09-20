import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';

/// A selectable listening mood used by the "Your Mood" row on Home.
class MoodModel {
  const MoodModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    this.label,
    this.description,
  });

  final String id;
  final String name;
  final IconData icon;
  final String imageUrl;

  /// Short caption displayed under the mood (e.g. "Late night").
  final String? label;
  final String? description;
}

/// Editorial hero card shown at the top of Home.
class HeroFeature {
  const HeroFeature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.artworkUrl,
    this.accent = TuneHiveColors.electricBlue,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String artworkUrl;

  /// Secondary accent used for the "PLAY NOW" pill.
  final Color accent;
}