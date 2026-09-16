import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_motion.dart';

/// Subtle scale + fade entrance. Used for hero artwork, play buttons and
/// featured content so they feel like they expand onto the screen.
class ScaleIn extends StatefulWidget {
  const ScaleIn({
    super.key,
    required this.child,
    this.duration = AppMotion.standard,
    this.delay = Duration.zero,
    this.from = 0.96,
    this.curve = AppMotion.entrance,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double from;
  final Curve curve;

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final totalSpan = widget.duration + widget.delay;
    final initial = widget.delay.inMilliseconds / totalSpan.inMilliseconds;

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _scale = Tween<double>(begin: widget.from, end: 1)
        .animate(_DelayedAnimation(curved, initial));
    _opacity = Tween<double>(begin: 0, end: 1)
        .animate(_DelayedAnimation(curved, initial));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

class _DelayedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _DelayedAnimation(this.parent, this.initial);

  @override
  final Animation<double> parent;
  final double initial;

  @override
  double get value {
    final t = parent.value;
    if (t <= initial) return 0;
    return ((t - initial) / (1 - initial)).clamp(0.0, 1.0);
  }
}