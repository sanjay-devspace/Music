import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_shadows.dart';
import 'package:tunehive/widgets/artwork_image.dart';

/// Global mini-player bar — deep navy surface, coral progress bar.
///
/// Shown just above the bottom navigation while music is playing.
class MiniPlayer extends StatefulWidget {
  const MiniPlayer({
    super.key,
    required this.artworkUrl,
    required this.title,
    required this.artist,
    this.isPlaying = false,
    this.onTap,
    this.onPlayPause,
    this.onNext,
    this.onFavorite,
    this.progress = 0,
    this.isFavorited = false,
  });

  final String? artworkUrl;
  final String title;
  final String artist;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onFavorite;
  final double progress;
  final bool isFavorited;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  double _pressScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressScale = 0.98),
        onTapUp: (_) {
          setState(() => _pressScale = 1.0);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressScale = 1.0),
        child: AnimatedScale(
          scale: _pressScale,
          duration: AppMotion.micro,
          curve: AppMotion.press,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: TuneHiveColors.cardSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: TuneHiveColors.elevatedSurface),
              boxShadow: AppShadows.floating,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      ArtworkImage(
                        imageUrl: widget.artworkUrl,
                        width: 48,
                        height: 48,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: TuneHiveColors.coolWhite,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: TuneHiveColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onFavorite,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          widget.isFavorited
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: widget.isFavorited
                              ? TuneHiveColors.electricBlue
                              : TuneHiveColors.mutedText,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onPlayPause,
                        icon: Icon(
                          widget.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: TuneHiveColors.coolWhite,
                          size: 30,
                        ),
                        tooltip: widget.isPlaying ? 'Pause' : 'Play',
                      ),
                      IconButton(
                        onPressed: widget.onNext,
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: TuneHiveColors.coolWhite,
                        ),
                        tooltip: 'Next',
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg),
                  ),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    minHeight: 3,
                    color: TuneHiveColors.electricBlue,
                    backgroundColor: TuneHiveColors.elevatedSurface,
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