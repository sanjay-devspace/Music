import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/controllers/library_controller.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/widgets/empty_state.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';
import 'package:tunehive/widgets/song_card.dart';

enum _LibraryTab { songs, playlists, albums, artists, favorites }

/// Library — Liked Songs, Playlists, Albums, Artists and Favorites.
class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  _LibraryTab _tab = _LibraryTab.songs;

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();
    final r = Responsive.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: FadeSlide(
                duration: AppMotion.standard,
                offset: const Offset(0, -0.02),
                child: Row(
                  children: [
                    const Icon(Icons.library_music_rounded,
                        color: TuneHiveColors.electricBlue, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Your Library',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: TuneHiveColors.coolWhite,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useWrap = constraints.maxWidth < 360;
                  final cards = [
                    _buildFeatureCard(
                      context,
                      'Liked Songs',
                      Icons.favorite_rounded,
                      RoutePaths.likedSongs,
                    ),
                    _buildFeatureCard(
                      context,
                      'Playlists',
                      Icons.queue_music_rounded,
                      RoutePaths.playlists,
                    ),
                    _buildFeatureCard(
                      context,
                      'Recent', // Shortened for space
                      Icons.history_rounded,
                      RoutePaths.recentlyPlayed,
                    ),
                  ];

                  if (useWrap) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: cards.map((c) => SizedBox(width: (constraints.maxWidth - 12) / 2, child: c)).toList(),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[1]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[2]),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _TabBar(
              tab: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            Expanded(
              child: Obx(() {
                if (library.isLoading.value) return const HomeSkeleton();
                return _buildTab(context, library);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, String route) {
    return Material(
      color: TuneHiveColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: TuneHiveColors.elevatedSurface),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: TuneHiveColors.electricBlue, size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TuneHiveColors.coolWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, LibraryController library) {
    switch (_tab) {
      case _LibraryTab.playlists:
      case _LibraryTab.albums:
      case _LibraryTab.artists:
        return const EmptyState(
          title: 'Nothing here yet',
          icon: Icons.folder_open_rounded,
          message: 'Your collections will appear here.',
        );
      case _LibraryTab.favorites:
        return _buildFavoriteSongs(library);
      case _LibraryTab.songs:
        return _buildSongs(library);
    }
  }

  Widget _buildSongs(LibraryController library) {
    if (library.recentlyPlayed.isEmpty) {
      return const EmptyState(
        title: 'Start listening',
        icon: Icons.queue_music_rounded,
        message: 'Songs you play will show up here.',
      );
    }
    return RefreshIndicator(
      onRefresh: library.refreshLibrary,
      color: TuneHiveColors.electricBlue,
      backgroundColor: TuneHiveColors.cardSurface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: library.recentlyPlayed.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 12),
              child: Text(
                'Recently Played',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TuneHiveColors.coolWhite,
                ),
              ),
            );
          }
          final song = library.recentlyPlayed[index - 1];
          return SongCard(
            song: song,
            variant: SongCardVariant.compact,
            onTap: () => library.playSong(
              song,
              fromList: library.recentlyPlayed,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteSongs(LibraryController library) {
    final favorites = library.likedSongs;
    if (favorites.isEmpty) {
      return EmptyState(
        title: 'No favorites yet',
        icon: Icons.favorite_border_rounded,
        message: 'Tap the heart on any song to keep it here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: favorites.length,
      itemBuilder: (_, index) {
        final song = favorites[index];
        return SongCard(
          song: song,
          variant: SongCardVariant.list,
          onTap: () => library.playSong(song, fromList: favorites),
          onFavorite: () => Get.find<PlayerController>().toggleFavorite(song),
        );
      },
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.tab, required this.onChanged});

  final _LibraryTab tab;
  final ValueChanged<_LibraryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final entries = [
      (_LibraryTab.songs, 'Songs', Icons.music_note_rounded),
      (_LibraryTab.playlists, 'Playlists', Icons.queue_music_rounded),
      (_LibraryTab.albums, 'Albums', Icons.album_rounded),
      (_LibraryTab.artists, 'Artists', Icons.person_rounded),
      (_LibraryTab.favorites, 'Favorites', Icons.favorite_rounded),
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final (value, label, icon) = entries[index];
          return _PillTab(
            label: label,
            icon: icon,
            selected: tab == value,
            onTap: () => onChanged(value),
          );
        },
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.cardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? TuneHiveColors.electricBlue : TuneHiveColors.elevatedSurface,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? TuneHiveColors.coolWhite : TuneHiveColors.mutedText,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? TuneHiveColors.coolWhite : TuneHiveColors.coolWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}