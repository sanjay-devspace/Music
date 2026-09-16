import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_shadows.dart';

/// Neon lime gradient primary action button.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
    this.size = AppButtonSize.large,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      AppButtonSize.small => 40.0,
      AppButtonSize.medium => 48.0,
      AppButtonSize.large => 56.0,
    };

    final child = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.glow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0E1500),
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );

    return AnimatedScale(
      scale: onPressed == null ? 1 : 1,
      duration: const Duration(milliseconds: 150),
      child: expanded ? SizedBox(width: double.infinity, child: child) : child,
    );
  }
}

enum AppButtonSize { small, medium, large }