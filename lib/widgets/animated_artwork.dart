import 'package:flutter/material.dart';

/// Rotating/pulsing artwork used for the full player hero.
class AnimatedArtwork extends StatelessWidget {
  const AnimatedArtwork({
    super.key,
    required this.child,
    this.isPlaying = false,
  });

  final Widget child;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return _TweenAnimationBuilder(
      child: child,
      isPlaying: isPlaying,
    );
  }
}

class _TweenAnimationBuilder extends StatefulWidget {
  const _TweenAnimationBuilder({required this.child, required this.isPlaying});

  final Widget child;
  final bool isPlaying;

  @override
  State<_TweenAnimationBuilder> createState() =>
      _TweenAnimationBuilderState();
}

class _TweenAnimationBuilderState extends State<_TweenAnimationBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(_TweenAnimationBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.forward();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wrapped = widget.child;

    // Subtle breathing scale to suggest "alive" artwork while playing.
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.03)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: wrapped,
    );
  }
}