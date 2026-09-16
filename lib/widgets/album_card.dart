import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/widgets/artwork_image.dart';

/// Album artwork card with name, artist and year.
class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.onPlay,
    this.width,
  });

  final AlbumModel album;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? 140;
    return SizedBox(
      width: cardWidth,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ArtworkImage(
                  imageUrl: album.artworkUrl,
                  width: cardWidth,
                  height: cardWidth,
                  borderRadius: AppRadius.lg,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onPlay,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.play_arrow_rounded, color: Color(0xFF0B1200), size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                album.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                album.artistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}