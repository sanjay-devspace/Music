import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_shadows.dart';
import 'package:tunehive/app/theme/app_typography.dart';

/// Premium circular play/pause control.
///
/// - Coral fill with a soft glow.
/// - Press feedback via [AnimatedScale].
/// - Icon morphs between play, pause and a loading spinner.
class PlayButton extends StatefulWidget {
  const PlayButton({
    super.key,
    this.size = 56,
    this.isPlaying = false,
    this.isLoading = false,
    this.filled = true,
    this.onPressed,
  });

  final double size;
  final bool isPlaying;
  final bool isLoading;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.size * 0.46;
    final background = widget.filled ? TuneHiveColors.electricBlue : TuneHiveColors.coolWhite;
    final foreground = widget.filled ? TuneHiveColors.coolWhite : TuneHiveColors.charcoalBlack;

    final Widget inner = widget.isLoading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: foreground,
            ),
          )
        : AnimatedSwitcher(
            duration: AppMotion.micro,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              key: ValueKey(widget.isPlaying),
              size: iconSize,
              color: foreground,
            ),
          );

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: AppMotion.micro,
        curve: AppMotion.press,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            boxShadow: widget.filled ? AppShadows.coralGlow : null,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(child: inner),
          ),
        ),
      ),
    );
  }
}

/// Small pill "PLAY NOW" action used inside the hero card.
class PlayNowPill extends StatelessWidget {
  const PlayNowPill({
    super.key,
    this.onPressed,
    this.backgroundColor = TuneHiveColors.electricBlue,
  });

  final VoidCallback? onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow_rounded,
                  size: 18, color: TuneHiveColors.coolWhite),
              const SizedBox(width: 6),
              Text(
                'PLAY NOW',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: TuneHiveColors.coolWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}