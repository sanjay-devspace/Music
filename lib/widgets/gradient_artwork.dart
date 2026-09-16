import 'package:flutter/material.dart';

/// Artwork with a subtle bottom gradient overlay for card heroes.
class GradientArtwork extends StatelessWidget {
  const GradientArtwork({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.stops,
  });

  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double>? stops;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: colors ??
                    const [
                      Colors.transparent,
                      Color(0x99000000),
                    ],
                stops: stops,
              ),
            ),
          ),
        ),
      ],
    );
  }
}