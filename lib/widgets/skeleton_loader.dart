import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';

/// App-level loading indicator that respects the current theme.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 3,
        color: AppColors.primary,
      ),
    );
  }
}

/// Shimmer / skeleton loader for card placeholders.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Circular placeholder for an artist image.
class CircleAvatarPlaceholder extends StatelessWidget {
  const CircleAvatarPlaceholder({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: AppColors.textMuted,
        size: size * 0.5,
      ),
    );
  }
}

/// Placeholder artwork card.
class ArtworkPlaceholder extends StatelessWidget {
  const ArtworkPlaceholder({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.textMuted,
          size: 36,
        ),
      ),
    );
  }
}

/// Skeleton loader for a horizontal list of cards.
class HorizontalSkeleton extends StatelessWidget {
  const HorizontalSkeleton({super.key, this.cardWidth = 140});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth + 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: cardWidth, height: cardWidth, borderRadius: 16),
              const SizedBox(height: AppSpacing.sm),
              const ShimmerBox(width: 90, height: 14),
              const SizedBox(height: AppSpacing.xs),
              const ShimmerBox(width: 60, height: 12),
            ],
          );
        },
      ),
    );
  }
}