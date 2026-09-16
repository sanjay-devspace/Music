import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';

/// Library of screen transition builders.
///
/// These plug into `CustomTransitionPage.transitionsBuilder` (GoRouter) or a
/// plain `PageRouteBuilder`. Every major navigation uses one of these so the
/// motion language stays consistent across the app.
abstract class AppPageTransitions {
  AppPageTransitions._();

  /// Fade + slight upward slide. The default route transition.
  static Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) fadeSlide({
    Duration duration = AppMotion.large,
    Alignment begin = const Alignment(0, 0.03),
  }) {
    return (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.entrance,
        reverseCurve: AppMotion.easeInOut,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(begin.x, begin.y),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    };
  }

  /// Soft scale + fade entrance (used for immersive screens like the player).
  static Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) fadeScale({
    Duration duration = AppMotion.hero,
    double scaleFrom = 0.96,
  }) {
    return (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.fastOutSlowIn,
        reverseCurve: AppMotion.easeInOut,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: scaleFrom, end: 1).animate(curved),
          child: child,
        ),
      );
    };
  }

  /// Shared-axis style horizontal glide (album → detail screens).
  static Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) slideHorizontal({
    Duration duration = AppMotion.large,
  }) {
    return (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.fastOutSlowIn,
        reverseCurve: AppMotion.easeInOut,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.6, end: 1).animate(curved),
          child: child,
        ),
      );
    };
  }
}

/// Pre-built gradient background used behind immersive routes.
class ImmersiveBackground extends StatelessWidget {
  const ImmersiveBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGradientStart,
            AppColors.backgroundGradientEnd,
          ],
        ),
      ),
      child: child,
    );
  }
}