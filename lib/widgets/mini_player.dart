import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/widgets/artwork_image.dart';

/// Global mini-player bar shown above the bottom navigation.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.artworkUrl,
    required this.title,
    required this.artist,
    this.isPlaying = false,
    this.onTap,
    this.onPlayPause,
    this.onNext,
    this.progress = 0,
  });

  final String? artworkUrl;
  final String title;
  final String artist;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xE61C270D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x14FFFFFF)),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, -2)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    ArtworkImage(
                      imageUrl: artworkUrl,
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
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onPlayPause,
                      icon: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: AppColors.textPrimary,
                        size: 30,
                      ),
                      tooltip: isPlaying ? 'Pause' : 'Play',
                    ),
                    IconButton(
                      onPressed: onNext,
                      icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary),
                      tooltip: 'Next',
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  color: AppColors.primary,
                  backgroundColor: const Color(0x29FFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}