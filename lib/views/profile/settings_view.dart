import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/controllers/auth_controller.dart';
import 'package:tunehive/core/animation/fade_slide.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _gaplessPlayback = true;
  bool _crossfade = false;
  bool _normalizeVolume = true;
  bool _pushNotifications = true;
  bool _newReleases = true;
  bool _weeklyPlaylists = false;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.user.value;

    return Scaffold(
      backgroundColor: TuneHiveColors.charcoalBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),
                  _buildSection(
                    header: 'Account',
                    children: [
                      ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${user?.displayName ?? 'User'} · ${user?.email ?? ''}',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: TuneHiveColors.cardSurface,
                            ),
                          );
                        },
                        title: Text(
                          'Profile',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        subtitle: Text(
                          '${user?.displayName ?? 'User'} · ${user?.email ?? ''}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: TuneHiveColors.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: TuneHiveColors.mutedText,
                          size: 20,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Subscription management coming soon',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: TuneHiveColors.cardSurface,
                            ),
                          );
                        },
                        title: Text(
                          'Subscription',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Free',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                color: TuneHiveColors.mutedText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: TuneHiveColors.mutedText,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    header: 'Playback',
                    children: [
                      SwitchListTile(
                        value: _gaplessPlayback,
                        onChanged: (v) => setState(() => _gaplessPlayback = v),
                        title: Text(
                          'Gapless Playback',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        activeThumbColor: TuneHiveColors.electricBlue,
                      ),
                      SwitchListTile(
                        value: _crossfade,
                        onChanged: (v) => setState(() => _crossfade = v),
                        title: Text(
                          'Crossfade',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        activeThumbColor: TuneHiveColors.electricBlue,
                      ),
                      SwitchListTile(
                        value: _normalizeVolume,
                        onChanged: (v) => setState(() => _normalizeVolume = v),
                        title: Text(
                          'Normalize Volume',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        activeThumbColor: TuneHiveColors.electricBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    header: 'Quality',
                    children: [
                      ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Quality settings coming soon',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: TuneHiveColors.cardSurface,
                            ),
                          );
                        },
                        title: Text(
                          'Streaming Quality',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'High',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                color: TuneHiveColors.mutedText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: TuneHiveColors.mutedText,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Download quality settings coming soon',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: TuneHiveColors.cardSurface,
                            ),
                          );
                        },
                        title: Text(
                          'Download Quality',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'High',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                color: TuneHiveColors.mutedText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: TuneHiveColors.mutedText,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    header: 'Notifications',
                    children: [
                      SwitchListTile(
                        value: _pushNotifications,
                        onChanged: (v) =>
                            setState(() => _pushNotifications = v),
                        title: Text(
                          'Push Notifications',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        activeThumbColor: TuneHiveColors.electricBlue,
                      ),
                      SwitchListTile(
                        value: _newReleases,
                        onChanged: (v) => setState(() => _newReleases = v),
                        title: Text(
                          'New Releases',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        activeThumbColor: TuneHiveColors.electricBlue,
                      ),
                      SwitchListTile(
                        value: _weeklyPlaylists,
                        onChanged: (v) => setState(() => _weeklyPlaylists = v),
                        title: Text(
                          'Weekly Playlists',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        activeThumbColor: TuneHiveColors.electricBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    header: 'Appearance',
                    children: [
                      ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Theme switching coming soon',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: TuneHiveColors.cardSurface,
                            ),
                          );
                        },
                        title: Text(
                          'Theme',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Dark',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                color: TuneHiveColors.mutedText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: TuneHiveColors.mutedText,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'English',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: TuneHiveColors.cardSurface,
                            ),
                          );
                        },
                        title: Text(
                          'Language',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'English',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                color: TuneHiveColors.mutedText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: TuneHiveColors.mutedText,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    header: 'About',
                    children: [
                      ListTile(
                        title: Text(
                          'Version',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: TuneHiveColors.mutedText,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Terms of Use coming soon',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: TuneHiveColors.cardSurface,
                            ),
                          );
                        },
                        title: Text(
                          'Terms of Use',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: TuneHiveColors.mutedText,
                          size: 20,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Privacy Policy coming soon',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: TuneHiveColors.cardSurface,
                            ),
                          );
                        },
                        title: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: TuneHiveColors.mutedText,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FadeSlide(
                    delay: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => _showLogoutDialog(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: TuneHiveColors.electricBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: TuneHiveColors.electricBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: TuneHiveColors.coolWhite,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Settings',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: TuneHiveColors.coolWhite,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String header,
    required List<Widget> children,
  }) {
    return FadeSlide(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              header,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TuneHiveColors.mutedText,
              ),
            ),
          ),
          Material(
            color: TuneHiveColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    const Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: TuneHiveColors.elevatedSurface,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TuneHiveColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TuneHiveColors.coolWhite,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            color: TuneHiveColors.coolWhite,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: TuneHiveColors.coolWhite,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Get.find<AuthController>().logout();
              if (context.mounted) {
                context.go(RoutePaths.onboarding);
              }
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w700,
                color: TuneHiveColors.electricBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
