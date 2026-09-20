import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';

/// A single large circular playback control (play, next, shuffle, repeat).
class PlayerControl extends StatelessWidget {
  const PlayerControl({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56,
    this.active = false,
    this.activeIcon,
    this.color,
    this.activeColor = TuneHiveColors.electricBlue,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool active;
  final IconData? activeIcon;
  final Color? color;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = active ? activeColor : TuneHiveColors.coolWhite;
    final IconData effectiveIcon = active && activeIcon != null ? activeIcon! : icon;

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(effectiveIcon, size: size * 0.42, color: effectiveColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large primary play/pause toggle button.
class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    this.onPressed,
    this.size = 64,
  });

  final bool isPlaying;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TuneHiveColors.electricBlue,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedAnimatedIcon(isPlaying: isPlaying, size: size),
      ),
    );
  }
}

class SizedAnimatedIcon extends StatefulWidget {
  const SizedAnimatedIcon({
    super.key,
    required this.isPlaying,
    required this.size,
  });
  final bool isPlaying;
  final double size;

  @override
  State<SizedAnimatedIcon> createState() => _SizedAnimatedIconState();
}

class _SizedAnimatedIconState extends State<SizedAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void didUpdateWidget(SizedAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying && !_controller.isAnimating) _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.0).animate(_controller),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Icon(
          widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: TuneHiveColors.charcoalBlack,
          size: widget.size * 0.55,
        ),
      ),
    );
  }
}