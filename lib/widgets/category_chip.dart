import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';

/// Horizontal category chip (All / Party / Blues / Chill...).
///
/// Selected chip uses a neon lime background; unselected uses a dark surface.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(right: 10),
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.full),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.onPrimary : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
          ),
        ),
      ),
    );
  }
}