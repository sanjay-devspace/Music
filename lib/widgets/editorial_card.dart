import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';

/// Large editorial playlist card — artwork fill, dark gradient overlay,
/// title + description + optional play button.
///
/// Used by both "Recommended For You" and "Your Daily Mix" sections.
class EditorialCard extends StatefulWidget {
  const EditorialCard({
    super.key,
    required this.title,
    this.description,
    required this.artworkUrl,
    this.width,
    this.height,
    this.onTap,
    this.onPlay,
    this.showPlayButton = true,
  });

  final String title;
  final String? description;
  final String artworkUrl;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final bool showPlayButton;

  @override
  State<EditorialCard> createState() => _EditorialCardState();
}

class _EditorialCardState extends State<EditorialCard> {
  double _pressScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? 170;
    final height = widget.height ?? 220;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressScale = 0.97),
      onTapUp: (_) {
        setState(() => _pressScale = 1.0);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressScale = 1.0),
      child: AnimatedScale(
        scale: _pressScale,
        duration: AppMotion.micro,
        curve: AppMotion.press,
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Artwork
                CachedNetworkImage(
                  imageUrl: widget.artworkUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) => const _ArtworkPlaceholder(),
                  errorWidget: (_, __, ___) => const _ArtworkPlaceholder(),
                ),

                // Bottom gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.45, 1],
                      ),
                    ),
                  ),
                ),

                // Play button overlay
                if (widget.showPlayButton && widget.onPlay != null)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Material(
                      color: TuneHiveColors.electricBlue,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: widget.onPlay,
                        child: const SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: TuneHiveColors.coolWhite,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Text
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: TuneHiveColors.coolWhite,
                          letterSpacing: -0.2,
                          height: 1.15,
                        ),
                      ),
                      if (widget.description != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: TuneHiveColors.coolWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: TuneHiveColors.elevatedSurface),
      child: Center(
        child: Icon(Icons.music_note_rounded,
            color: TuneHiveColors.mutedText, size: 32),
      ),
    );
  }
}