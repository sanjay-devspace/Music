import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';

/// Single pill-shaped navigation item inside a floating group.
///
/// The selected item expands to reveal `ICON + LABEL` on a coral pill; every
/// other item stays compact as `ICON ONLY`. Expansion is driven by
/// [AnimatedSize] so it remains smooth and subtle across all device widths.
class NavigationItem extends StatelessWidget {
  const NavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.iconSize,
    required this.itemHeight,
    this.labelMaxWidth = 96,
    this.activePadding = 16,
    this.inactivePadding = 12,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double iconSize;
  final double itemHeight;
  final double labelMaxWidth;
  final double activePadding;
  final double inactivePadding;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppRadius.full));

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: AnimatedSize(
        duration: AppMotion.standard,
        curve: AppMotion.easeOut,
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: Colors.white.withValues(alpha: 0.16),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: AppMotion.standard,
              curve: AppMotion.easeOut,
              height: itemHeight,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? activePadding : inactivePadding,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: radius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: iconSize,
                    color: selected ? AppColors.white : AppColors.textMuted,
                  ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: labelMaxWidth),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}