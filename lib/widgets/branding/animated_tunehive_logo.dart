import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_shadows.dart';

class AnimatedTuneHiveLogo extends StatefulWidget {
  const AnimatedTuneHiveLogo({
    super.key,
    this.animateEntrance = true,
    this.loopWaveform = true,
    this.textColor = AppColors.textPrimary,
    this.iconColor = AppColors.primary,
    this.textSize = 28.0,
    this.iconSize = 30.0,
  });

  final bool animateEntrance;
  final bool loopWaveform;
  final Color textColor;
  final Color iconColor;
  final double textSize;
  final double iconSize;

  @override
  State<AnimatedTuneHiveLogo> createState() => _AnimatedTuneHiveLogoState();
}

class _AnimatedTuneHiveLogoState extends State<AnimatedTuneHiveLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _waveController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    
    if (_reducedMotion) {
      _entranceController.value = 1.0;
    } else {
      if (widget.animateEntrance && !_entranceController.isAnimating && !_entranceController.isCompleted) {
        _entranceController.forward();
      } else if (!widget.animateEntrance) {
        _entranceController.value = 1.0;
      }

      if (widget.loopWaveform && !_waveController.isAnimating) {
        _waveController.repeat();
      }
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTuneHiveLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_reducedMotion) return;
    
    if (widget.loopWaveform && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!widget.loopWaveform && _waveController.isAnimating) {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.iconSize * 0.16;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Waveform Icon
        AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) {
            return Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: widget.iconSize,
            height: widget.iconSize,
            // Subtle glow around the entire logo icon
            decoration: BoxDecoration(
              boxShadow: AppShadows.coralGlow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(5, (index) {
                return AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    // Calculate a flowing sine wave
                    double wave = 0.0;
                    if (_waveController.isAnimating) {
                      wave = math.sin((_waveController.value * 2 * math.pi) + (index * 0.8));
                    }
                    
                    // Height oscillates between ~40% and 100% of max height
                    final minH = widget.iconSize * 0.4;
                    final maxH = widget.iconSize;
                    final midH = (maxH + minH) / 2;
                    final amplitude = (maxH - minH) / 2;
                    
                    final currentHeight = midH + (amplitude * wave);

                    return Container(
                      width: barWidth,
                      height: currentHeight,
                      decoration: BoxDecoration(
                        color: widget.iconColor,
                        borderRadius: BorderRadius.circular(barWidth / 2),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ),
        SizedBox(width: widget.iconSize * 0.4),
        // Wordmark
        AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) {
            return Opacity(
              opacity: _textOpacity.value,
              child: FractionalTranslation(
                translation: _textSlide.value,
                child: child,
              ),
            );
          },
          child: Text(
            'TUNEHIVE',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: widget.textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              fontSize: widget.textSize,
            ),
          ),
        ),
      ],
    );
  }
}
