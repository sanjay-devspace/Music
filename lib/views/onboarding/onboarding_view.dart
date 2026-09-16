import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/widgets/neon_button.dart';
import 'onboarding_responsive.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = OnboardingResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient glow (mocking premium artwork glow)
          Positioned(
            top: -100,
            left: -100,
            right: -100,
            height: responsive.glowHeight,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: responsive.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Logo / App Name
                  Row(
                    children: [
                      Icon(Icons.hive, color: AppColors.primary, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'TUNEHIVE',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Visual (placeholder for headphone/music visual)
                  Center(
                    child: Container(
                      width: responsive.artworkSize,
                      height: responsive.artworkSize,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.headphones_rounded,
                        size: responsive.artworkSize * 0.4,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Headline
                  Text(
                    'Start Your\nSonic Journey',
                    style: responsive.headlineStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Dive into a world of music — millions of songs, custom playlists, and every genre you love.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Primary CTA
                  NeonButton(
                    label: 'Turn on your music',
                    onPressed: () {
                      context.go(RoutePaths.home);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
