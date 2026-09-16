import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_motion.dart';

/// One-shot fade + slide entrance used for content that appears on screen.
///
/// Animate the widget in once (when it becomes visible) rather than relying
/// on page-level transitions, so sections feel like they "arrive" naturally.
class FadeSlide extends StatefulWidget {
  const FadeSlide({
    super.key,
    required this.child,
    this.duration = AppMotion.standard,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.05),
    this.curve = AppMotion.entrance,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;
  final Curve curve;

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..duration = widget.duration
      ..forward();
    // From: total 0
    // To:   total 1.1 (hold at 1 for 10% of travel against the returned
    //       controller value, keeps interpolation smooth and simple)
    final hold = 0.0;
    final total = widget.duration + widget.delay;

    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      _StaggeredCurveAnimation(curved, widget.delay.inMilliseconds / total.inMilliseconds, hold),
    );
    _offset = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(
      _StaggeredCurveAnimation(curved, widget.delay.inMilliseconds / total.inMilliseconds, hold),
    );
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
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

/// Promotes an animation with an initial (delay) and optional end (hold)
/// fraction so children can be staggered without overlapping springs.
class _StaggeredCurveAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _StaggeredCurveAnimation(this.parent, this.initial, this.finalHold);

  @override
  final Animation<double> parent;
  final double initial;
  final double finalHold;

  @override
  double get value {
    final t = parent.value;
    if (t < initial) return 0;
    final traveled = 1 - initial;
    return ((t - initial) / traveled).clamp(0.0, 1.0 - finalHold);
  }
}