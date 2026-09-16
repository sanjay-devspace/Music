import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';

/// Animated equalizer bars used behind album art and inside the player.
class AudioWaveform extends StatefulWidget {
  const AudioWaveform({
    super.key,
    this.barCount = 48,
    this.height = 44,
    this.active = false,
    this.color = AppColors.primary,
    this.inactiveColor = AppColors.divider,
    this.barWidth = 3,
  });

  final int barCount;
  final double height;
  final bool active;
  final Color color;
  final Color inactiveColor;
  final double barWidth;

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.large,
    )..repeat();
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active && _controller.isAnimating) _controller.stop();
    if (widget.active && !_controller.isAnimating) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.barCount; i++)
                Container(
                  width: widget.barWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: widget.active
                      ? _activeHeight(t, i)
                      : widget.height * 0.14,
                  decoration: BoxDecoration(
                    color: widget.active
                        ? widget.color
                        : widget.inactiveColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _activeHeight(double t, int index) {
    // Layered sine waves + a little noise -> organic bar motion.
    final wave = math.sin(t * math.pi * 2 + index * 0.55) * 0.5 +
        math.sin(t * math.pi * 4.2 + index * 0.21) * 0.3 +
        0.2;
    final normalized = (wave.abs()).clamp(0.12, 1.0);
    return widget.height * normalized;
  }
}