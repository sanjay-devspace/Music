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

    final height = isSmall ? 64.0 : responsive.isPhone ? 68.0 : 72.0;
    final iconSize = isSmall ? 22.0 : 24.0;
    
    return _NavbarEntrance(
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
            items: _items,
          ),
        ],
      ),
    );
  }
}

class _NavbarEntrance extends StatefulWidget {
  const _NavbarEntrance({required this.child});
  final Widget child;

  @override
  State<_NavbarEntrance> createState() => _NavbarEntranceState();
}

class _NavbarEntranceState extends State<_NavbarEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Stack(
          children: [

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++)
                  NavigationItem(
                    icon: items[i].$1,
                    label: items[i].$2,
                    selected: currentIndex == items[i].$3,
                    onTap: () => onTap(items[i].$3),
                    iconSize: iconSize,
                    itemHeight: height - 14,
                    labelMaxWidth: isSmall ? 72 : 96,
                    activePadding: isSmall ? 16 : 20,
                    inactivePadding: isSmall ? 14 : 16,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}