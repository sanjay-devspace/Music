
import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_shadows.dart';

class BezierTween extends Tween<Offset> {
  final Offset control;

  BezierTween({
    required Offset begin,
    required Offset end,
    required this.control,
  }) : super(begin: begin, end: end);

  @override
  Offset lerp(double t) {
    final double t1 = 1 - t;
    return Offset(
      t1 * t1 * begin!.dx + 2 * t1 * t * control.dx + t * t * end!.dx,
      t1 * t1 * begin!.dy + 2 * t1 * t * control.dy + t * t * end!.dy,
    );
  }
}

class AnimatedHeadphoneFormation extends StatefulWidget {
  const AnimatedHeadphoneFormation({super.key});

  @override
  State<AnimatedHeadphoneFormation> createState() =>
      _AnimatedHeadphoneFormationState();
}

class _AnimatedHeadphoneFormationState extends State<AnimatedHeadphoneFormation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Each element has its own animation curve (0.0 to 1.0 logic mapped from controller)
  late final Animation<double> _p1Progress;
  late final Animation<double> _p2Progress;
  late final Animation<double> _p3Progress;
  late final Animation<double> _p4Progress;

  // The merge glow and final headphone reveal
  late final Animation<double> _mergeGlow;
  late final Animation<double> _headphoneScale;
  late final Animation<double> _headphoneOpacity;

  // Continuous subtle pulse after formation
  late final Animation<double> _idlePulse;

  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Path 1 (Top Left): 0ms -> 1000ms
    _p1Progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.50, curve: Curves.easeInOutCubic),
    );

    // Path 2 (Top Right): 70ms -> 1070ms
    _p2Progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.035, 0.535, curve: Curves.easeInOutCubic),
    );

    // Path 3 (Bottom Left): 120ms -> 1120ms
    _p3Progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.060, 0.560, curve: Curves.easeInOutCubic),
    );

    // Path 4 (Bottom Right): 180ms -> 1180ms
    _p4Progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.090, 0.590, curve: Curves.easeInOutCubic),
    );

    // Merge Glow: Peaks exactly as they converge around 1.1s (0.55), fades by 1.35s (0.675)
    _mergeGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.675),
    ));

    // Headphone Reveal: 1.15s (0.575) to 1.5s (0.75)
    _headphoneOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.575, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _headphoneScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.575, 0.75, curve: Curves.easeOutBack),
      ),
    );
    
    // Idle Pulse: 1.6s to 2.0s
    _idlePulse = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOutSine),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    
    if (_reducedMotion) {
      _controller.value = 1.0;
    } else if (!_controller.isAnimating && !_controller.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reducedMotion) {
      return const SizedBox(
        width: 220,
        height: 220,
        child: Center(
          child: _FinalHeadphoneIcon(),
        ),
      );
    }

    // Determine safe radius boundaries (mostly for tablets)
    final double radius = 100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Create the 4 tweens using the radius
        final t1 = BezierTween(
          begin: Offset(-radius, -radius),
          end: Offset.zero,
          control: Offset(-radius, 0),
        ).transform(_p1Progress.value);

        final t2 = BezierTween(
          begin: Offset(radius, -radius),
          end: Offset.zero,
          control: Offset(0, -radius),
        ).transform(_p2Progress.value);

        final t3 = BezierTween(
          begin: Offset(-radius, radius),
          end: Offset.zero,
          control: Offset(0, radius),
        ).transform(_p3Progress.value);

        final t4 = BezierTween(
          begin: Offset(radius, radius),
          end: Offset.zero,
          control: Offset(radius, 0),
        ).transform(_p4Progress.value);

        // Opacity/Scale of the particles fade out as they reach the center
        double calcParticleOpacity(double p) => p < 0.1 ? (p * 10) : (p > 0.85 ? (1.0 - p) * (1 / 0.15) : 1.0);
        double calcParticleScale(double p) => p < 0.1 ? (p * 10) : (1.0 - (p * 0.35));

        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow
              if (_mergeGlow.value > 0.0)
                Container(
                  width: 140 * _mergeGlow.value,
                  height: 140 * _mergeGlow.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.4 * _mergeGlow.value),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.8 * _mergeGlow.value),
                        blurRadius: 40 * _mergeGlow.value,
                        spreadRadius: 10 * _mergeGlow.value,
                      )
                    ],
                  ),
                ),

              // Particles
              if (_p1Progress.value < 1.0 && _p1Progress.value > 0.0)
                Transform.translate(
                  offset: t1,
                  child: Transform.scale(
                    scale: calcParticleScale(_p1Progress.value),
                    child: Opacity(
                      opacity: calcParticleOpacity(_p1Progress.value).clamp(0.0, 1.0),
                      child: const _MusicParticle(icon: Icons.music_note_rounded),
                    ),
                  ),
                ),

              if (_p2Progress.value < 1.0 && _p2Progress.value > 0.0)
                Transform.translate(
                  offset: t2,
                  child: Transform.scale(
                    scale: calcParticleScale(_p2Progress.value),
                    child: Opacity(
                      opacity: calcParticleOpacity(_p2Progress.value).clamp(0.0, 1.0),
                      child: const _MusicParticle(icon: Icons.surround_sound_rounded, size: 28),
                    ),
                  ),
                ),

              if (_p3Progress.value < 1.0 && _p3Progress.value > 0.0)
                Transform.translate(
                  offset: t3,
                  child: Transform.scale(
                    scale: calcParticleScale(_p3Progress.value),
                    child: Opacity(
                      opacity: calcParticleOpacity(_p3Progress.value).clamp(0.0, 1.0),
                      child: const _MusicParticle(icon: Icons.graphic_eq_rounded, size: 32),
                    ),
                  ),
                ),

              if (_p4Progress.value < 1.0 && _p4Progress.value > 0.0)
                Transform.translate(
                  offset: t4,
                  child: Transform.scale(
                    scale: calcParticleScale(_p4Progress.value),
                    child: Opacity(
                      opacity: calcParticleOpacity(_p4Progress.value).clamp(0.0, 1.0),
                      child: const _MusicParticle(icon: Icons.audiotrack_rounded),
                    ),
                  ),
                ),

              // Final Headphone
              if (_headphoneOpacity.value > 0.0)
                Opacity(
                  opacity: _headphoneOpacity.value,
                  child: Transform.scale(
                    scale: _headphoneScale.value * _idlePulse.value,
                    child: const _FinalHeadphoneIcon(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MusicParticle extends StatelessWidget {
  const _MusicParticle({required this.icon, this.size = 24});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: AppShadows.coralGlow,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.primary, size: size),
    );
  }
}

class _FinalHeadphoneIcon extends StatelessWidget {
  const _FinalHeadphoneIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: AppShadows.coralGlow,
        border: Border.all(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
          width: 4,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.headphones_rounded,
        size: 72,
        color: AppColors.onPrimary,
      ),
    );
  }
}
