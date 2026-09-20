import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_shadows.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/models/mood_model.dart';
import 'package:tunehive/widgets/play_button.dart';

/// Hero feature card — full-width editorial with artwork, dark gradient
/// overlay, headline + subtext + "PLAY NOW" pill.
///
/// Looks like an integrated editorial card rather than a random image behind
/// text.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.feature,
    this.width,
    this.height = 234,
    this.onPlay,
    this.onFavorite,
    this.isFavorited = false,
  });

  final HeroFeature feature;
  final double? width;
  final double height;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artwork
            CachedNetworkImage(
              imageUrl: feature.artworkUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 250),
              placeholder: (_, __) => const _HeroPlaceholder(),
              errorWidget: (_, __, ___) => const _HeroPlaceholder(),
            ),

            // Gradient overlay — keeps text readable and feels integrated
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.3, 1],
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              top: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + action buttons
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          feature.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: TuneHiveColors.coolWhite,
                            height: 1.1,
                          ),
                        ),
                      ),
                      if (onFavorite != null)
                        IconButton(
                          onPressed: onFavorite,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorited
                                ? TuneHiveColors.electricBlue
                                : TuneHiveColors.coolWhite,
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Subtitle
                  Text(
                    feature.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TuneHiveColors.coolWhite.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // PLAY NOW pill
                  PlayNowPill(onPressed: onPlay),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TuneHiveColors.cardSurface, TuneHiveColors.charcoalBlack],
        ),
      ),
      child: Center(
        child: Icon(Icons.equalizer_rounded,
            color: TuneHiveColors.electricBlue, size: 40),
      ),
    );
  }
}