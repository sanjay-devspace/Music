import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';

class AppBackground extends StatefulWidget {
  const AppBackground({
    super.key,
    required this.scrollOffset,
  });

  final ValueNotifier<double> scrollOffset;

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _breathingCtrl;
  late AnimationController _particlesCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _breathingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _particlesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _breathingCtrl.dispose();
    _particlesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if reduced motion is enabled
    final reducedMotion = MediaQuery.accessibleNavigationOf(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceCtrl,
        if (!reducedMotion) _breathingCtrl,
        widget.scrollOffset,
      ]),
      builder: (context, child) {
        final entranceScale = Tween<double>(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .evaluate(_entranceCtrl);
        final entranceOpacity = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .evaluate(_entranceCtrl);

        final breathingScale = reducedMotion
            ? 0.0
            : Tween<double>(begin: 0.0, end: 0.015).evaluate(_breathingCtrl);

        return Opacity(
          opacity: entranceOpacity,
          child: Transform.scale(
            scale: entranceScale + breathingScale,
            child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Image
                  Image.asset(
                    'assets/images/musbg1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: TuneHiveColors.charcoalBlack),
                  ),

                  // 2. Dark Gradient Overlay (Cinematic Navy/Black)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xB80B1115),
                          Color(0xD915262D),
                          Color(0xF20B171B),
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),

                  // 3. Cinematic Vignette (Edges darker)
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),

                  // 4. Coral Glow
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TuneHiveColors.electricBlue.withValues(
                                alpha: reducedMotion
                                    ? 0.1
                                    : 0.08 + (0.08 * _breathingCtrl.value)),
                            blurRadius: 150,
                            spreadRadius: 100,
                          )
                        ],
                      ),
                    ),
                  ),

                  // 5. Particles (Only if no reduced motion)
                  if (!reducedMotion)
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _particlesCtrl,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _MusicParticlesPainter(_particlesCtrl.value),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
        );
      },
    );
  }
}

class _MusicParticlesPainter extends CustomPainter {
  _MusicParticlesPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // fixed seed for consistent layout

    final particleCount = 15;
    for (var i = 0; i < particleCount; i++) {
      // Randomize initial properties
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final speed = 0.5 + random.nextDouble() * 0.5;
      final particleSize = 2.0 + random.nextDouble() * 2.0;

      // Color selection
      final colorType = random.nextInt(3);
      if (colorType == 0) {
        paint.color = TuneHiveColors.electricBlue.withValues(alpha: 0.2); // coral
      } else if (colorType == 1) {
        paint.color = Colors.white.withValues(alpha: 0.15); // soft white
      } else {
        paint.color = TuneHiveColors.electricBlue.withValues(alpha: 0.1); // subtle blue
      }

      // Calculate current position based on progress
      // Particles move UP (y decreases)
      final movementY = speed * size.height * progress;
      var currentY = startY - movementY;

      // Wrap around
      if (currentY < -10) {
        currentY = size.height + 10 - (-currentY % (size.height + 20));
      }

      // Sine wave X movement
      final wave = math.sin((progress * math.pi * 2 * speed) + i) * 15;
      final currentX = startX + wave;

      canvas.drawCircle(Offset(currentX, currentY), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_MusicParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
