import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:flutter/services.dart';

class GenreCard extends StatelessWidget {
  const GenreCard({
    super.key,
    required this.genre,
    required this.selected,
    required this.onTap,
  });

  final GenreModel genre;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: genre.name,
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.elevatedSurface,
              width: 1,
            ),
            gradient: selected
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TuneHiveColors.cardSurface,
                      TuneHiveColors.cardSurface.withValues(alpha: 0.8),
                    ],
                  ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: TuneHiveColors.electricBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      genre.name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TuneHiveColors.coolWhite,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: TuneHiveColors.coolWhite,
                      size: 20,
                    ),
                ],
              ),
              if (genre.songCount > 0)
                Text(
                  '${genre.songCount} songs',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: selected ? TuneHiveColors.coolWhite.withValues(alpha: 0.8) : TuneHiveColors.mutedText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
