import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/responsive/responsive.dart';

class AnimatedHomeLogo extends StatefulWidget {
  const AnimatedHomeLogo({super.key, required this.responsive});

  final Responsive responsive;

  @override
  State<AnimatedHomeLogo> createState() => _AnimatedHomeLogoState();
}

class _AnimatedHomeLogoState extends State<AnimatedHomeLogo> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _waveController;

  // Entrance animations
  late final Animation<double> _iconOpacity;
  late final Animation<double> _iconScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _glowOpacity;

  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _setupEntranceAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);

    if (_reducedMotion) {
      _entranceController.value = 1.0;
      _waveController.stop();
    } else {
      if (!_entranceController.isAnimating && _entranceController.value != 1.0) {
        _entranceController.forward().then((_) {
          if (mounted && !_reducedMotion) {
            _waveController.repeat();
          }
        });
      } else if (_entranceController.isCompleted && !_waveController.isAnimating) {
        _waveController.repeat();
      }
    }
  }

  void _setupEntranceAnimations() {
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _iconScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.82, curve: Curves.easeOutBack), // ~700ms
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.176, 1.0, curve: Curves.easeOut), // 150ms - 850ms
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(-10, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.176, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.4).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 1.0),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        const SizedBox(width: 8),
        Flexible(child: _buildText()),
      ],
    );
  }

  Widget _buildIcon() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Opacity(
          opacity: _iconOpacity.value,
          child: Transform.scale(
            scale: _iconScale.value,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Micro glow
                if (_glowOpacity.value > 0.0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TuneHiveColors.electricBlue.withValues(alpha: _glowOpacity.value),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                // Icon
                _reducedMotion
                    ? const Icon(Icons.equalizer_rounded, color: TuneHiveColors.electricBlue, size: 26)
                    : SizedBox(
                        width: 24,
                        height: 24,
                        child: _EqualizerWave(
                          animation: _waveController,
                          entrance: _entranceController,
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildText() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: Transform.translate(
            offset: _textSlide.value,
            child: Text(
              'TUNEHIVE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: widget.responsive.isPhone ? 18 : 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: TuneHiveColors.coolWhite,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EqualizerWave extends StatelessWidget {
  const _EqualizerWave({
    required this.animation,
    required this.entrance,
  });

  final Animation<double> animation;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([animation, entrance]),
      builder: (context, child) {
        // As the logo wakes up, bars grow from 0 to their current wave height
        final wakeUpProgress = Curves.easeOut.transform(entrance.value);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (index) {
            // Calculate a continuous smooth wave phase for each bar.
            // Using a combination of sines to look organic.
            final phase = animation.value * 2 * math.pi;
            final offset = index * (math.pi / 2.5); // Stagger
            
            // Complex wave: sin(x) + 0.5*cos(2x)
            final v1 = math.sin(phase - offset);
            final v2 = math.cos((phase - offset) * 1.5);
            // Normalize to 0.0 - 1.0 roughly
            double heightFactor = ((v1 + v2 * 0.5) + 1.5) / 3.0;
            // Clamp and adjust
            heightFactor = heightFactor.clamp(0.2, 1.0);
            
            final height = 24.0 * heightFactor * wakeUpProgress;
            
            return Container(
              width: 3.5,
              height: height.clamp(2.0, 24.0),
              decoration: BoxDecoration(
                color: TuneHiveColors.electricBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
