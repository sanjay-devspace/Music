import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/widgets/artwork_image.dart';
import 'package:tunehive/widgets/favorite_button.dart';

/// Song card supporting multiple layout variants.
class SongCard extends StatelessWidget {
  const SongCard({
    super.key,
    required this.song,
    this.onTap,
    this.onPlay,
    this.onFavorite,
    this.onMore,
    this.variant = SongCardVariant.horizontal,
    this.width,
  });

  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final VoidCallback? onMore;
  final SongCardVariant variant;
  final double? width;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case SongCardVariant.compact:
        return CompactSongItem(song: song, onTap: onTap);
      case SongCardVariant.list:
        return ListSongItem(song: song, onTap: onTap, onPlay: onPlay, onMore: onMore);
      case SongCardVariant.horizontal:
      case SongCardVariant.grid:
        return ArtworkSongCard(
          song: song,
          onTap: onTap,
          onPlay: onPlay,
          onMore: onMore,
          onFavorite: onFavorite,
          width: width,
        );
    }
  }
}

enum SongCardVariant { compact, horizontal, grid, list }

/// Compact horizontal row with artwork, title, artist.
class CompactSongItem extends StatelessWidget {
  const CompactSongItem({super.key, required this.song, this.onTap});

  final SongModel song;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            ArtworkImage(imageUrl: song.artworkUrl, width: 44, height: 44, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (song.duration > Duration.zero)
              Text(
                song.durationText,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card with prominent artwork used in horizontal scrolling sections / grids.
class ArtworkSongCard extends StatelessWidget {
  const ArtworkSongCard({
    super.key,
    required this.song,
    this.onTap,
    this.onPlay,
    this.onMore,
    this.onFavorite,
    this.width,
  });

  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onMore;
  final VoidCallback? onFavorite;
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
                  imageUrl: song.artworkUrl,
                  width: cardWidth,
                  height: cardWidth,
                  borderRadius: AppRadius.lg,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _PlayOverlay(onPlay: onPlay, size: 40),
                ),
                if (onFavorite != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0x33050807),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(1),
                      child: FavoriteButton(
                        isFavorited: song.isFavorited,
                        onPressed: onFavorite,
                        size: 16,
                        iconColor: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                song.title,
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
                song.artistName,
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

class _PlayOverlay extends StatelessWidget {
  const _PlayOverlay({this.onPlay, this.size = 40});

  final VoidCallback? onPlay;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPlay,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.play_arrow_rounded, color: AppColors.onPrimary, size: size * 0.55),
        ),
      ),
    );
  }
}

/// Full-width list row with favorite toggle and more menu.
class ListSongItem extends StatelessWidget {
  const ListSongItem({
    super.key,
    required this.song,
    this.onTap,
    this.onPlay,
    this.onMore,
    this.onFavorite,
  });

  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onMore;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            ArtworkImage(imageUrl: song.artworkUrl, width: 48, height: 48, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (song.duration > Duration.zero)
              Text(
                song.durationText,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onFavorite,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                song.isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: song.isFavorited ? AppColors.primary : AppColors.textMuted,
                size: 20,
              ),
            ),
            IconButton(
              onPressed: onMore,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}