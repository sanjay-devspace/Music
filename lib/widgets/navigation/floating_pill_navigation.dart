import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_shadows.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/widgets/navigation/navigation_item.dart';

/// TUNEHIVE floating pill navigation — TuneHive's main tab navigation.
///
/// Replaces the old full-width bottom bar with two separated dark capsules
/// that float above the bottom edge:
///
/// ```
///   [ 🏠 Home ]   [ 🔍  🎵  👤 ]
/// ```
///
/// The active item expands (`ICON + LABEL`) while the inactive ones collapse
/// to `ICON ONLY`. The widget only handles presentation and tap callbacks —
/// the shell owns routing and controller state.
class FloatingPillNavigation extends StatelessWidget {
  const FloatingPillNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <(IconData, String, int)>[
    (Icons.home_rounded, 'Home', 0),
    (Icons.search_rounded, 'Search', 1),
    (Icons.library_music_rounded, 'Library', 2),
    (Icons.person_rounded, 'Profile', 3),
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final isSmall = responsive.isPhoneSmall;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    final height = isSmall ? 52.0 : responsive.isPhone ? 56.0 : 62.0;
    final iconSize = isSmall ? 20.0 : 22.0;
    final horizontalMargin = isSmall ? 10.0 : 16.0;
    final groupGap = isSmall ? 8.0 : 12.0;
    final bottomGap = isSmall ? 8.0 : 10.0;

    final leading = _items.where((t) => t.$3 == 0).toList();
    final secondary = _items.where((t) => t.$3 != 0).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        safeBottom + bottomGap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillGroup(
            height: height,
            iconSize: iconSize,
            isSmall: isSmall,
            currentIndex: currentIndex,
            onTap: onTap,
            items: leading,
          ),
          SizedBox(width: groupGap),
          _PillGroup(
            height: height,
            iconSize: iconSize,
            isSmall: isSmall,
            currentIndex: currentIndex,
            onTap: onTap,
            items: secondary,
          ),
        ],
      ),
    );
  }
}

/// One dark capsule holding a row of pill items.
class _PillGroup extends StatelessWidget {
  const _PillGroup({
    required this.height,
    required this.iconSize,
    required this.isSmall,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final double height;
  final double iconSize;
  final bool isSmall;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<(IconData, String, int)> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.floating,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++)
              NavigationItem(
                icon: items[i].$1,
                label: items[i].$2,
                selected: currentIndex == items[i].$3,
                onTap: () => onTap(items[i].$3),
                iconSize: iconSize,
                itemHeight: height - 8,
                labelMaxWidth: isSmall ? 72 : 96,
                activePadding: isSmall ? 14 : 16,
                inactivePadding: isSmall ? 10 : 12,
              ),
          ],
        ),
      ),
    );
  }
}