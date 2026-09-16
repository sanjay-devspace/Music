import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_radius.dart';

/// Primary application button with neon lime treatment and press feedback.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      mainAxisSize: expanded ? MainAxisSize.min : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: onPressed,
          child: content,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: onPressed,
          child: content,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: onPressed,
          child: content,
        ),
    };

    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 150),
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

enum AppButtonVariant { primary, outline, ghost }

/// Rounded icon button used throughout navigation.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 44,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: size * 0.44,
      color: Theme.of(context).iconTheme.color);

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
        child: InkWell(
          onTap: onPressed,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
          child: SizedBox(
            width: size,
            height: size,
            child: IconTheme.merge(
              data: Theme.of(context).iconTheme,
              child: Center(child: iconWidget),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism surface used by the mini player and floating bars.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.color,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: color ?? const Color(0x991C270D),
          border: Border.all(color: const Color(0x14FFFFFF)),
          boxShadow: const [
            BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}