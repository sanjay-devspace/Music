import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';

/// Cached artwork image with placeholder and error fallbacks.
///
/// Prefers the smallest practical resolution for a given size to save memory.
class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    super.key,
    this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius,
    this.boxFit = BoxFit.cover,
    this.placeholderIcon = Icons.music_note_rounded,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final double? borderRadius;
  final BoxFit boxFit;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lg;

    Widget buildPlaceholder(BuildContext ctx) {
      return ShimmerBox(
        width: width,
        height: height,
        borderRadius: radius,
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: TuneHiveColors.cardSurface,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(placeholderIcon, size: height * 0.32, color: TuneHiveColors.mutedText),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: boxFit,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (context, url) => buildPlaceholder(context),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: TuneHiveColors.cardSurface,
          child: Icon(placeholderIcon, size: height * 0.32, color: TuneHiveColors.mutedText),
        ),
      ),
    );
  }
}

/// Circular avatar used for artists.
class ArtistAvatar extends StatelessWidget {
  const ArtistAvatar({super.key, this.imageUrl, required this.size});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: TuneHiveColors.elevatedSurface, shape: BoxShape.circle),
        child: Icon(Icons.person, size: size * 0.45, color: TuneHiveColors.mutedText),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: TuneHiveColors.elevatedSurface,
          child: Icon(Icons.person, size: size * 0.45, color: TuneHiveColors.mutedText),
        ),
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: TuneHiveColors.elevatedSurface,
          child: Icon(Icons.person, size: size * 0.45, color: TuneHiveColors.mutedText),
        ),
      ),
    );
  }
}