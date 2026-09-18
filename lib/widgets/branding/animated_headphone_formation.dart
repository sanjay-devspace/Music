
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

    // 4.5s total duration for the center animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    // Float & Assemble Phase (0.0s to 2.5s) -> 0.0 to 0.555
    _p1Progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.555, curve: Curves.easeInOutCubic),
    );

    _p2Progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.02, 0.555, curve: Curves.easeInOutCubic),
    );

    _p3Progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.04, 0.555, curve: Curves.easeInOutCubic),
    );

    _p4Progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.06, 0.555, curve: Curves.easeInOutCubic),
    );

    // Headphone Reveal (2.5s to 3.0s) -> 0.555 to 0.666
    _headphoneOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.555, 0.666, curve: Curves.easeOutCubic),
      ),
    );

    _headphoneScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.555, 0.666, curve: Curves.easeOutBack),
      ),
    );

    // Merge Glow (3.0s to 3.8s) -> 0.666 to 0.844
    _mergeGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.666, 0.844),
    ));
    
    // Idle Pulse (3.8s to 4.5s) -> 0.844 to 1.0
    _idlePulse = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.844, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
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
