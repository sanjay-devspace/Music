import 'package:flutter/material.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';

/// Desktop sidebar navigation with compact + expanded modes.
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
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: _expanded ? 220 : 72,
      decoration: const BoxDecoration(
        color: AppColors.backgroundAlt,
        border: Border(right: BorderSide(color: AppColors.divider)),
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
                    icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
                  )
                else ...[
                  const Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TUNE',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                        const Text(
                          'HIVE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggle,
                          icon: const Icon(Icons.menu_rounded, color: AppColors.textMuted),
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
        color: selected ? const Color(0x1AC7FF19) : Colors.transparent,
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
                        Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.textMuted),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            color: selected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.textMuted),
                  ),
          ),
        ),
      ),
    );
  }
}