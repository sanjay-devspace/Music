import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
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
      duration: const Duration(milliseconds: 5000),
    );

    // Title: 3.8s (0.76) to 4.3s (0.86)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.86, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.86, curve: Curves.easeOutCubic),
      ),
    );

    // Description: 4.0s (0.80) to 4.5s (0.90)
    _descOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 0.90, curve: Curves.easeOutCubic),
      ),
    );
    _descSlide = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // Button: 4.2s (0.84) to 4.7s (0.94)
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.84, 0.94, curve: Curves.easeOutCubic),
      ),
    );
    _buttonScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.84, 0.94, curve: Curves.easeOutCubic),
      ),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.84, 0.94, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
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
      backgroundColor: TuneHiveColors.charcoalBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Static background image
          Image.asset(
            'assets/images/musbg2.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: TuneHiveColors.charcoalBlack);
            },
          ),
          // Subtle dark overlay to ensure text readability
          Container(
            color: Colors.black.withOpacity(0.40),
          ),
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
                    TuneHiveColors.electricBlue.withValues(alpha: 0.12),
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
                        color: TuneHiveColors.coolWhite,
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
                      child: _PremiumButton(
                        onPressed: () => context.go(RoutePaths.home),
                        text: 'Turn on your music',
                        fontSize: responsive.fontSize.body,
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

class _PremiumButton extends StatefulWidget {
  const _PremiumButton({
    required this.onPressed,
    required this.text,
    required this.fontSize,
  });

  final VoidCallback onPressed;
  final String text;
  final double fontSize;

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            backgroundColor: TuneHiveColors.electricBlue,
            foregroundColor: TuneHiveColors.coolWhite,
            textStyle: AppTextStyles.label.copyWith(fontSize: widget.fontSize),
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}