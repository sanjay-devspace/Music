import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_spacing.dart';

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
        color: TuneHiveColors.electricBlue,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer
// ---------------------------------------------------------------------------

/// Animated shimmer effect that sweeps a gradient across its child.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.enabled = true,
  });

  final Widget child;
  final Duration duration;
  final bool enabled;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.enabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final dx = _controller.value * rect.width * 2;
            return LinearGradient(
              begin: Alignment(dx / rect.width - 1, 0),
              end: Alignment(dx / rect.width, 0),
              colors: const [
                TuneHiveColors.cardSurface,
                TuneHiveColors.elevatedSurface,
                TuneHiveColors.cardSurface,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton boxes
// ---------------------------------------------------------------------------

/// Static skeleton placeholder box (no shimmer applied).
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
        color: TuneHiveColors.cardSurface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class CircleAvatarPlaceholder extends StatelessWidget {
  const CircleAvatarPlaceholder({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: TuneHiveColors.elevatedSurface,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: TuneHiveColors.mutedText, size: size * 0.5),
    );
  }
}

class ArtworkPlaceholder extends StatelessWidget {
  const ArtworkPlaceholder({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: TuneHiveColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded,
            color: TuneHiveColors.mutedText, size: 36),
      ),
    );
  }
}

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

/// Premium Home skeleton — matches the Home layout shape so loading feels
/// intentional rather than like a broken page.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          // Header row
          const Row(
            children: [
              ShimmerBox(width: 120, height: 20, borderRadius: 8),
              Spacer(),
              ShimmerBox(width: 34, height: 34, borderRadius: 17),
            ],
          ),
          const SizedBox(height: 16),

          // Greeting
          const ShimmerBox(width: 180, height: 14, borderRadius: 8),
          const SizedBox(height: 4),
          const ShimmerBox(width: 240, height: 26, borderRadius: 10),
          const SizedBox(height: 18),

          // Search bar
          const ShimmerBox(width: double.infinity, height: 48, borderRadius: 16),
          const SizedBox(height: 24),

          // Mood chips row
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => const ShimmerBox(width: 84, height: 40, borderRadius: 20),
            ),
          ),
          const SizedBox(height: 28),

          // Hero card
          const ShimmerBox(width: double.infinity, height: 234, borderRadius: 28),
          const SizedBox(height: 28),

          // Section header + card row
          const ShimmerBox(width: 140, height: 18, borderRadius: 8),
          const SizedBox(height: 14),
          const HorizontalSkeleton(cardWidth: 150),
          const SizedBox(height: 28),

          // Editorial section
          const ShimmerBox(width: 200, height: 18, borderRadius: 8),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const ShimmerBox(width: 160, height: 220, borderRadius: 24),
            ),
          ),

          const SizedBox(height: 28),

          // Artists row
          const ShimmerBox(width: 160, height: 18, borderRadius: 8),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const ShimmerBox(width: 88, height: 88, borderRadius: 44),
            ),
          ),
        ],
      ),
    );
  }
}