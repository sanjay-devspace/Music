import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';

/// Favorite heart with a small bounce + shimmer on toggle.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorited,
    this.onPressed,
    this.size = 20,
    this.color = AppColors.primary,
    this.iconColor,
  });

  final bool isFavorited;
  final VoidCallback? onPressed;
  final double size;
  final Color color;
  final Color? iconColor;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    // Grow past 1 then settle back — a gentle "pop".
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 60),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onPressed?.call();
    if (_controller.isCompleted) {
      _controller.reset();
    }
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.isFavorited;
    return ScaleTransition(
      scale: _bounce,
      child: IconButton(
        onPressed: _handleTap,
        visualDensity: VisualDensity.compact,
        tooltip: active ? 'Remove from favorites' : 'Add to favorites',
        icon: AnimatedSwitcher(
          duration: AppMotion.micro,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(active),
            size: widget.size,
            color: active ? widget.color : (widget.iconColor ?? AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}