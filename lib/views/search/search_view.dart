import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/controllers/search_controller.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/widgets/album_card.dart';
import 'package:tunehive/widgets/artist_card.dart';
import 'package:tunehive/widgets/category_chip.dart';
import 'package:tunehive/widgets/song_card.dart';

/// Search for songs, artists, albums and playlists with live, debounced
/// results and trending/recent chips when idle.
class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final search = Get.find<SearchController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _SearchField(),
            Expanded(
              child: Obx(() {
                if (search.hasQuery.value) {
                  if (search.isSearching.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    );
                  }
                  return _SearchResults(search: search);
                }
                return _SearchIdle(search: search);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final search = Get.find<SearchController>();
    final r = Responsive.of(context);
    final hPad = r.isPhoneSmall ? 12.0 : 20.0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 14),
      child: SizedBox(
        width: double.infinity,
        child: FadeSlide(
          duration: AppMotion.standard,
          offset: const Offset(0, -0.03),
          child: TextField(
            onChanged: search.onSearchChanged,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                context.go('${RoutePaths.searchResults}?q=${Uri.encodeComponent(value.trim())}');
              }
            },
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Songs, artists, albums, moods',
              hintStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textSecondary),
              suffixIcon: Obx(() => search.hasQuery.value
                  ? IconButton(
                      onPressed: search.clearSearch,
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted),
                    )
                  : const SizedBox.shrink()),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.symmetric(
                  vertical: 14, horizontal: r.isPhoneSmall ? 10 : 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Idle — trending & recent
// ---------------------------------------------------------------------------

class _SearchIdle extends StatelessWidget {
  const _SearchIdle({required this.search});

  final SearchController search;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.maxContentWidth),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Explore',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              _ChipGroup(
                title: 'Trending Searches',
                chips: search.trendingSearches,
                icon: Icons.trending_up_rounded,
                onTap: (term) => search.onSearchChanged(term),
              ),
              const SizedBox(height: 24),
              _ChipGroup(
                title: 'Recent Searches',
                chips: search.recentSearches,
                icon: Icons.history_rounded,
                onTap: (term) => search.onSearchChanged(term),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Genres',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Placeholder genre chips — replaced by live genres soon.
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.title,
    required this.chips,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final List<String> chips;
  final IconData icon;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: chips.length,
            itemBuilder: (_, index) {
              final label = chips[index];
              return CategoryChip(
                label: label,
                selected: false,
                onTap: () {
                  onTap(label);
                  Get.find<SearchController>().onSearchChanged(label);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Results
// ---------------------------------------------------------------------------

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.search});

  final SearchController search;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final hasAny = search.songResults.isNotEmpty ||
        search.artistResults.isNotEmpty ||
        search.albumResults.isNotEmpty;

    if (!hasAny) {
      return const _NoResults();
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (search.songResults.isNotEmpty) ...[
          const _ResultHeader('Songs'),
          for (final song in search.songResults)
            _ResultSongRow(search: search, song: song),
          const SizedBox(height: 12),
        ],
        if (search.artistResults.isNotEmpty) ...[
          const _ResultHeader('Artists'),
          for (final artist in search.artistResults)
            _ResultArtistRow(artist: artist),
          const SizedBox(height: 12),
        ],
        if (search.albumResults.isNotEmpty) ...[
          const _ResultHeader('Albums'),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: search.albumResults.length,
              itemBuilder: (_, index) {
                final album = search.albumResults[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AlbumCard(
                    album: album,
                    width: r.isPhone ? 148 : 180,
                    onTap: () => context.go(RoutePaths.albumWith(album.id)),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ResultSongRow extends StatelessWidget {
  const _ResultSongRow({required this.search, required this.song});

  final SearchController search;
  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return SongCard(
      song: song,
      variant: SongCardVariant.list,
      onTap: () => context.push(RoutePaths.songWith(song.id)),
      onPlay: () => search.playSong(song, fromList: search.songResults),
      onFavorite: () => search.toggleFavorite(song),
    );
  }
}

class _ResultArtistRow extends StatelessWidget {
  const _ResultArtistRow({required this.artist});

  final ArtistModel artist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ArtistChip(
        artist: artist,
        onTap: () => context.go(RoutePaths.artistWith(artist.id)),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 52, color: AppColors.textMuted),
            const SizedBox(height: 14),
            const Text(
              'No matches found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different song, artist or album.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}