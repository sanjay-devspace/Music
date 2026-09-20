import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';

/// Extract dominant colours from album artwork.
///
/// Fetches the artwork bytes once (callers should memoize by URL), generates
/// a palette and returns (a) the ambient background colour and (b) an accent
/// glow colour that harmonises with the artwork.
class ArtworkPalette {
  ArtworkPalette({
    required this.ambient,
    required this.glow,
  });

  final Color ambient;
  final Color glow;

  /// Deep-navy theme fallback used when artwork can't be resolved.
  static final ArtworkPalette fallback = ArtworkPalette(
    ambient: TuneHiveColors.cardSurface,
    glow: TuneHiveColors.electricBlue,
  );

  static final Map<String, ArtworkPalette> _cache = {};

  static Future<ArtworkPalette> extract(String imageUrl) async {
    final cached = _cache[imageUrl];
    if (cached != null) return cached;

    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(
            const Duration(seconds: 8),
          );
      if (response.statusCode != 200) return fallback;

      final bytes = response.bodyBytes;
      final palette = await PaletteGenerator.fromImageProvider(
        MemoryImage(bytes),
        maximumColorCount: 16,
      );

      final dominant = palette.dominantColor?.color ?? fallback.ambient;
      final vibrant = palette.vibrantColor?.color ?? fallback.glow;

      // Darken the dominant colour so text remains readable.
      final ambient = _darken(dominant, 0.62);
      final glow = vibrant;

      final result = ArtworkPalette(ambient: ambient, glow: glow);
      _cache[imageUrl] = result;
      return result;
    } catch (_) {
      return fallback;
    }
  }

  static Color _darken(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * factor).clamp(0.04, 0.55))
        .toColor();
  }
}