import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/services/music/music_service.dart';

class ConnectedProvidersView extends StatefulWidget {
  const ConnectedProvidersView({super.key});

  @override
  State<ConnectedProvidersView> createState() => _ConnectedProvidersViewState();
}

class _ConnectedProvidersViewState extends State<ConnectedProvidersView> {
  final Map<String, bool> _toggling = {};

  @override
  Widget build(BuildContext context) {
    final service = Get.find<MusicService>();
    final providers = service.providers;

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
                  FadeSlide(
                    delay: const Duration(milliseconds: 80),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TuneHiveColors.elevatedSurface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        'Connect your music services to import '
                        'libraries and get personalized recommendations.',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          color: TuneHiveColors.coolWhite,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(providers.length, (index) {
                    final provider = providers[index];
                    final isActive = provider.id == service.activeProviderId;
                    final toggling = _toggling[provider.id] ?? false;

                    return FadeSlide(
                      delay: Duration(milliseconds: 120 + index * 60),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: TuneHiveColors.cardSurface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isActive
                                    ? TuneHiveColors.electricBlue
                                    : TuneHiveColors.elevatedSurface,
                                width: isActive ? 1.5 : 0.5,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: _ProviderIcon(id: provider.id),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      provider.displayName,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: TuneHiveColors.coolWhite,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: TuneHiveColors.electricBlue,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                      ),
                                      child: Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: TuneHiveColors.coolWhite,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(
                                isActive ? 'Active catalog' : 'Not connected',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13,
                                  color: TuneHiveColors.mutedText,
                                ),
                              ),
                              trailing: toggling
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: TuneHiveColors.electricBlue,
                                      ),
                                    )
                                  : Switch(
                                      value: isActive,
                                      onChanged: (value) =>
                                          _onToggle(provider.id, value),
                                      activeThumbColor: TuneHiveColors.electricBlue,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onToggle(String id, bool turnOn) async {
    final service = Get.find<MusicService>();
    setState(() => _toggling[id] = true);

    await Future.delayed(const Duration(milliseconds: 400));

    if (turnOn) {
      await service.selectProvider(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connected to ${service.providerFor(id).displayName}',
              style: const TextStyle(fontFamily: AppTypography.fontFamily),
            ),
            backgroundColor: TuneHiveColors.cardSurface,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Disconnected from ${service.providerFor(id).displayName}',
              style: const TextStyle(fontFamily: AppTypography.fontFamily),
            ),
            backgroundColor: TuneHiveColors.cardSurface,
          ),
        );
      }
    }

    if (mounted) setState(() => _toggling[id] = false);
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
              'Connected Providers',
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
}

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;

    switch (id) {
      case 'spotify':
        color = const Color(0xFF1DB954);
        icon = Icons.music_note_rounded;
        break;
      case 'apple_music':
        color = TuneHiveColors.coolWhite;
        icon = Icons.apple_rounded;
        break;
      case 'local':
        color = Colors.orange;
        icon = Icons.folder_rounded;
        break;
      case 'mock':
        color = TuneHiveColors.electricBlue;
        icon = Icons.equalizer_rounded;
        break;
      default:
        color = TuneHiveColors.coolWhite;
        icon = Icons.library_music_rounded;
        break;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
