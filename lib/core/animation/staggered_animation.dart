import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'fade_slide.dart';

/// Drop-in staggered entrance for lists / grids.
///
/// Wraps each child in a [FadeSlide] with an incremental delay so content
/// "arrives" in sequence without forcing users to wait. Delays stay tiny —
/// the whole column completes well under a second.
class StaggeredAnimation extends StatelessWidget {
  const StaggeredAnimation({
    super.key,
    required this.count,
    required this.itemBuilder,
    this.duration = AppMotion.standard,
    this.baseDelay = AppMotion.staggerBase,
    this.step = AppMotion.staggerStep,
    this.enabled = true,
  });

  final int count;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Duration duration;
  final Duration baseDelay;
  final Duration step;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final child = itemBuilder(context, index);
        if (!enabled) return child;
        final delay = baseDelay + step * index;
        return FadeSlide(
          key: ValueKey('stagger-$index'),
          duration: duration,
          delay: delay,
          child: child,
        );
      }),
    );
  }
}

/// Produces the delay for the [index]-th staged child.
Duration staggerDelay(int index) =>
    AppMotion.staggerBase + AppMotion.staggerStep * index;