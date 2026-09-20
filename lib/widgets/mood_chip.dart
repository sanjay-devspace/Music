import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_shadows.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/models/mood_model.dart';

/// "Your Mood" chip — icon + label that animates to a coral selected state.
class MoodChip extends StatelessWidget {
  const MoodChip({
    super.key,
    required this.mood,
    required this.selected,
    this.onTap,
  });

  final MoodModel mood;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.97,
        duration: AppMotion.micro,
        curve: AppMotion.press,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.easeOut,
          decoration: BoxDecoration(
            color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.elevatedSurface,
            ),
            boxShadow: selected ? AppShadows.coralGlow : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: AppMotion.micro,
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        mood.icon,
                        key: ValueKey('${mood.id}-$selected'),
                        size: 18,
                        color: selected
                            ? TuneHiveColors.coolWhite
                            : TuneHiveColors.coolWhite,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mood.name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                        color: selected
                            ? TuneHiveColors.coolWhite
                            : TuneHiveColors.coolWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}