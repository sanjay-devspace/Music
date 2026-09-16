import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_shadows.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/widgets/branding/animated_headphone_formation.dart';
import 'package:tunehive/widgets/branding/animated_tunehive_logo.dart';
import 'onboarding_responsive.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _descOpacity;
  late final Animation<Offset> _descSlide;

  late final Animation<double> _buttonOpacity;
  late final Animation<double> _buttonScale;
  late final Animation<Offset> _buttonSlide;

  bool _reducedMotion = false;
  int _restartKey = 0;

  @override
  void reassemble() {
    super.reassemble();
    assert(() {
      _controller.stop();
      _controller.reset();
      if (!_reducedMotion) {
        _controller.forward();
      }
      setState(() {
        _restartKey++;
      });
      return true;
    }());
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // The headphone formation handles its own 2.0s lifecycle internally.

    // Title: 0.95s (0.475) to 1.45s (0.725)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.475, 0.725, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.475, 0.725, curve: Curves.easeOutCubic),
      ),
    );

    // Description: 1.25s (0.625) to 1.75s (0.875)
    _descOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.625, 0.875, curve: Curves.easeOutCubic),
      ),
    );
    _descSlide = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.625, 0.875, curve: Curves.easeOutCubic),
      ),
    );

    // Button: 1.55s (0.775) to 2.0s (1.0)
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.775, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _buttonScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.775, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.775, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    
    if (_reducedMotion) {
      _controller.value = 1.0;
    } else {
      if (!_controller.isAnimating && !_controller.isCompleted) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = OnboardingResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient radial glow (coral)
          Positioned(
            top: -100,
            left: -100,
            right: -100,
            height: responsive.glowHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: responsive.padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  const SizedBox(height: 24),
                  // Animated Logo
                  AnimatedTuneHiveLogo(
                    key: ValueKey('logo_$_restartKey'),
                    animateEntrance: true,
                    loopWaveform: true,
                    textSize: responsive.fontSize.title * 0.9,
                  ),

                  const Spacer(),

                  // The Premium 4-Element Headphone Formation
                  Center(
                    child: AnimatedHeadphoneFormation(
                      key: ValueKey('headphone_$_restartKey'),
                    ),
                  ),

                  const Spacer(),

                  // Headline
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _titleOpacity.value,
                        child: FractionalTranslation(
                          translation: _titleSlide.value,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'Start Your\nSonic Journey',
                      style: responsive.headlineStyle,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _descOpacity.value,
                        child: FractionalTranslation(
                          translation: _descSlide.value,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'Dive into a world of music — millions of songs, custom playlists, and every genre you love.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                        fontSize: responsive.fontSize.body,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Primary CTA
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _buttonOpacity.value,
                        child: FractionalTranslation(
                          translation: _buttonSlide.value,
                          child: Transform.scale(
                            scale: _buttonScale.value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.go(RoutePaths.home),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          textStyle: AppTextStyles.label.copyWith(fontSize: responsive.fontSize.body),
                        ),
                        child: const Text('Turn on your music'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}