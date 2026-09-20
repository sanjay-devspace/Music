import 'package:flutter/material.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';

/// Desktop sidebar navigation — deep navy, coral accent.
class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.expanded = true,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool expanded;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.expanded;
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.large,
      curve: AppMotion.easeOut,
      width: _expanded ? 220 : 72,
      decoration: const BoxDecoration(
        color: TuneHiveColors.charcoalBlack,
        border: Border(right: BorderSide(color: TuneHiveColors.elevatedSurface)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _expanded ? 16 : 12),
            child: Row(
              children: [
                if (!_expanded)
                  IconButton(
                    onPressed: _toggle,
                    icon: const Icon(Icons.menu_rounded, color: TuneHiveColors.electricBlue),
                  )
                else ...[
                  const Icon(Icons.equalizer_rounded, color: TuneHiveColors.electricBlue, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          child: Text(
                            'TUNE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: TuneHiveColors.coolWhite,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Flexible(
                          child: Text(
                            'HIVE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: TuneHiveColors.electricBlue,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggle,
                          icon: const Icon(Icons.menu_rounded, color: TuneHiveColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SidebarItem(
            expanded: _expanded,
            icon: Icons.home_rounded,
            label: 'Home',
            selected: widget.currentIndex == 0,
            onTap: () => widget.onTap(0),
          ),
          _SidebarItem(
            expanded: _expanded,
            icon: Icons.search_rounded,
            label: 'Search',
            selected: widget.currentIndex == 1,
            onTap: () => widget.onTap(1),
          ),
          _SidebarItem(
            expanded: _expanded,
            icon: Icons.library_music_rounded,
            label: 'Library',
            selected: widget.currentIndex == 2,
            onTap: () => widget.onTap(2),
          ),
          _SidebarItem(
            expanded: _expanded,
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            selected: widget.currentIndex == 4,
            onTap: () => widget.onTap(4),
          ),
          const Spacer(),
          _SidebarItem(
            expanded: _expanded,
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: widget.currentIndex == 3,
            onTap: () => widget.onTap(3),
          ),
          _SidebarItem(
            expanded: _expanded,
            icon: Icons.settings_rounded,
            label: 'Settings',
            selected: widget.currentIndex == 5,
            onTap: () => widget.onTap(5),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.expanded,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final bool expanded;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? TuneHiveColors.electricBlue.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            height: 48,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 22,
                          color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.mutedText,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.coolWhite,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Icon(
                      icon,
                      size: 22,
                      color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.mutedText,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}