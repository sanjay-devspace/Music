import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_shadows.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/core/animation/scale_transition.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/controllers/auth_controller.dart';
import 'package:tunehive/controllers/home_controller.dart';
import 'package:tunehive/controllers/player_controller.dart';

/// Profile — account card, quick stats and settings list.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final player = Get.find<PlayerController>();
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                r.isPhone ? 20 : 32,
                r.isPhone ? 20 : 32,
                r.isPhone ? 20 : 32,
                MediaQuery.paddingOf(context).bottom + (r.isPhone ? 20 : 32),
              ),
              children: [
                Center(
              child: Column(
                children: [
                  ScaleIn(
                    delay: Duration.zero,
                    duration: AppMotion.large,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TuneHiveColors.electricBlue,
                        border: Border.all(
                          color: TuneHiveColors.elevatedSurface,
                          width: 4,
                        ),
                        boxShadow: AppShadows.coralGlow,
                      ),
                      alignment: Alignment.center,
                      child: Obx(() {
                        final name = home.userName.value;
                        final token = name.isNotEmpty
                            ? name.split(' ').map((w) => w[0]).take(2).join()
                            : 'TH';
                        return Text(
                          token,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: TuneHiveColors.coolWhite,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(() => Text(
                        home.userName.value,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: TuneHiveColors.coolWhite,
                          letterSpacing: -0.3,
                        ),
                      )),
                  const SizedBox(height: 4),
                  const Text(
                    'Premium · tunehive.app/user',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TuneHiveColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: r.isPhone ? 28 : 36),
            Obx(() => Row(
                  children: [
                    _StatTile(
                      label: 'Favorites',
                      value: player.likedIds.length,
                      icon: Icons.favorite_rounded,
                      onTap: () => context.push(RoutePaths.likedSongs),
                    ),
                    const SizedBox(width: 12),
                    _StatTile(
                      label: 'Playlists',
                      value: 0,
                      icon: Icons.queue_music_rounded,
                      onTap: () => context.push(RoutePaths.playlists),
                    ),
                    const SizedBox(width: 12),
                    _StatTile(
                      label: 'Following',
                      value: 0,
                      icon: Icons.person_add_alt_1_rounded,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Following coming soon')),
                      ),
                    ),
                  ],
                )),
            SizedBox(height: r.isPhone ? 28 : 36),
            FadeSlide(
              duration: AppMotion.standard,
              offset: const Offset(0, 0.02),
              child: const _ProfileMenu(),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: TuneHiveColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: TuneHiveColors.elevatedSurface),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: TuneHiveColors.electricBlue),
              const SizedBox(height: 6),
              Text(
                '$value',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: TuneHiveColors.coolWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: TuneHiveColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.manage_accounts_rounded, 'Account'),
      (Icons.tune_rounded, 'Playback'),
      (Icons.download_for_offline_rounded, 'Downloads'),
      (Icons.sd_card_rounded, 'Audio Quality'),
      (Icons.sync_rounded, 'Connected Providers'),
      (Icons.notifications_none_rounded, 'Notifications'),
      (Icons.help_outline_rounded, 'Help & FAQ'),
      (Icons.logout_rounded, 'Log Out'),
    ];
    final actions = <VoidCallback>[
      () => context.push(RoutePaths.settings),
      () => context.push(RoutePaths.settings),
      () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Downloads coming soon')),
          ),
      () => context.push(RoutePaths.settings),
      () => context.push(RoutePaths.connectedProviders),
      () => context.push(RoutePaths.notificationCenter),
      () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Help & FAQ coming soon')),
          ),
      () => _handleLogout(context),
    ];
    return Material(
      color: TuneHiveColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: TuneHiveColors.elevatedSurface),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Column(
              children: [
                ListTile(
                  onTap: actions[i],
                  leading: Icon(items[i].$1, color: TuneHiveColors.coolWhite),
                  title: Text(
                    items[i].$2,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TuneHiveColors.coolWhite,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: TuneHiveColors.mutedText, size: 20),
                ),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 20,
                    color: TuneHiveColors.elevatedSurface,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: TuneHiveColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: TuneHiveColors.electricBlue),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final auth = Get.find<AuthController>();
    await auth.triggerLogoutTransition();
    if (context.mounted) {
      context.go(RoutePaths.onboarding);
    }
  }
}