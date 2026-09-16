import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/widgets/artwork_image.dart';

/// Circular artist card with follow state.
class ArtistCard extends StatelessWidget {
  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
    this.onFollow,
    this.avatarSize = 110,
    this.showFollowers = true,
  });

  final ArtistModel artist;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  final double avatarSize;
  final bool showFollowers;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ArtistAvatar(imageUrl: artist.avatarUrl, size: avatarSize),
          const SizedBox(height: 10),
          Text(
            artist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (showFollowers && artist.followersText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              artist.followersText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small version of the artist card used in "Popular Artists" rows.
class ArtistChip extends StatelessWidget {
  const ArtistChip({super.key, required this.artist, this.onTap});

  final ArtistModel artist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            ArtistAvatar(imageUrl: artist.avatarUrl, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}