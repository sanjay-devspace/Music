import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
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
import 'package:tunehive/widgets/genre_card.dart';
import 'package:tunehive/widgets/preference_chip.dart';

/// Search for songs, artists, albums and playlists with live, debounced
/// results and explore elements.
class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final search = Get.find<SearchController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
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
                        color: TuneHiveColors.electricBlue,
                      ),
                    );
                  }
                  return _SearchResults(search: search);
                }
                return _SearchExplore(search: search);
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
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              color: TuneHiveColors.coolWhite,
            ),
            cursorColor: TuneHiveColors.electricBlue,
            decoration: InputDecoration(
              hintText: 'Songs, artists, albums, moods',
              hintStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TuneHiveColors.mutedText,
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: TuneHiveColors.coolWhite),
              suffixIcon: Obx(() => search.hasQuery.value
                  ? IconButton(
                      onPressed: search.clearSearch,
                      icon: const Icon(Icons.close_rounded,
                          color: TuneHiveColors.mutedText),
                    )
                  : const SizedBox.shrink()),
              filled: true,
              fillColor: TuneHiveColors.cardSurface,
              contentPadding: EdgeInsets.symmetric(
                  vertical: 14, horizontal: r.isPhoneSmall ? 10 : 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: TuneHiveColors.elevatedSurface),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: TuneHiveColors.elevatedSurface),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: TuneHiveColors.electricBlue, width: 1.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Explore — music discovery & preferences
// ---------------------------------------------------------------------------

class _SearchExplore extends StatelessWidget {
  const _SearchExplore({required this.search});

  final SearchController search;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    
    return Obx(() {
      if (search.isLoadingExplore.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: TuneHiveColors.electricBlue,
          ),
        );
      }
      
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120), // Leave space for navbar/player
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: TuneHiveColors.coolWhite,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                
                // Quick Search
                _ChipGroup(
                  title: 'Quick Search',
                  chips: search.trendingSearches,
                  icon: Icons.local_fire_department_rounded,
                  onTap: (term) => search.onSearchChanged(term),
                ),
                const SizedBox(height: 32),
                
                // Browse by Genre
                if (search.exploreGenres.isNotEmpty) ...[
                  const _SectionTitle('Browse by Genre'),
                  const SizedBox(height: 12),
                  _GenreGrid(search: search, r: r),
                  const SizedBox(height: 32),
                ],
                
                // Languages
                const _SectionTitle('Languages'),
                const SizedBox(height: 12),
                _PreferenceChips(
                  items: search.availableLanguages,
                  selectedItems: search.selectedLanguages,
                  onToggle: search.toggleLanguage,
                ),
                const SizedBox(height: 32),
                
                // Moods
                const _SectionTitle('Choose Your Mood'),
                const SizedBox(height: 12),
                _PreferenceChips(
                  items: search.availableMoods,
                  selectedItems: search.selectedMoods,
                  onToggle: search.toggleMood,
                ),
                const SizedBox(height: 32),
                
                // Popular Artists
                if (search.popularArtists.isNotEmpty) ...[
                  const _SectionTitle('Popular Artists'),
                  const SizedBox(height: 12),
                  _PopularArtistsCarousel(search: search),
                  const SizedBox(height: 32),
                ],
                
                // Trending Songs
                if (search.trendingSongs.isNotEmpty) ...[
                  const _SectionTitle('Trending Songs'),
                  const SizedBox(height: 12),
                  _TrendingSongsCarousel(search: search),
                  const SizedBox(height: 32),
                ],
                
                // New Releases
                if (search.newReleases.isNotEmpty) ...[
                  const _SectionTitle('New Releases'),
                  const SizedBox(height: 12),
                  _NewReleasesCarousel(search: search, r: r),
                  const SizedBox(height: 32),
                ],
                
                // Recommended For You
                if (search.recommendedSongs.isNotEmpty) ...[
                  const _SectionTitle('Recommended For You'),
                  const SizedBox(height: 12),
                  _RecommendedCarousel(search: search),
                  const SizedBox(height: 32),
                ],
                
                // Recent Searches
                _RecentSearchesGroup(search: search),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TuneHiveColors.coolWhite,
        ),
      ),
    );
  }
}

class _GenreGrid extends StatelessWidget {
  const _GenreGrid({required this.search, required this.r});
  final SearchController search;
  final Responsive r;

  @override
  Widget build(BuildContext context) {
    if (search.exploreGenres.isEmpty) return const SizedBox.shrink();
    
    // Calculate columns based on width
    int crossAxisCount = r.isPhoneSmall ? 2 : r.isPhone ? 2 : r.isTablet ? 3 : 4;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: search.exploreGenres.length,
        itemBuilder: (context, index) {
          final genre = search.exploreGenres[index];
          return Obx(() => GenreCard(
            genre: genre,
            selected: search.selectedGenres.contains(genre.id),
            onTap: () => search.toggleGenre(genre.id),
          ));
        },
      ),
    );
  }
}

class _PreferenceChips extends StatelessWidget {
  const _PreferenceChips({
    required this.items,
    required this.selectedItems,
    required this.onToggle,
  });

  final List<String> items;
  final RxSet<String> selectedItems;
  final Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) {
          return Obx(() => PreferenceChip(
            label: item,
            selected: selectedItems.contains(item),
            onTap: () => onToggle(item),
          ));
        }).toList(),
      ),
    );
  }
}

class _PopularArtistsCarousel extends StatelessWidget {
  const _PopularArtistsCarousel({required this.search});
  final SearchController search;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: search.popularArtists.length,
        itemBuilder: (context, index) {
          final artist = search.popularArtists[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 100,
              child: ArtistCard(
                artist: artist,
                onTap: () => context.go(RoutePaths.artistWith(artist.id)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrendingSongsCarousel extends StatelessWidget {
  const _TrendingSongsCarousel({required this.search});
  final SearchController search;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: search.trendingSongs.length,
        itemBuilder: (context, index) {
          final song = search.trendingSongs[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 140,
              child: SongCard(
                song: song,
                variant: SongCardVariant.grid,
                onTap: () => context.push(RoutePaths.songWith(song.id)),
                onPlay: () => search.playSong(song, fromList: search.trendingSongs),
                onFavorite: () => search.toggleFavorite(song),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecommendedCarousel extends StatelessWidget {
  const _RecommendedCarousel({required this.search});
  final SearchController search;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: search.recommendedSongs.length,
        itemBuilder: (context, index) {
          final song = search.recommendedSongs[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 140,
              child: SongCard(
                song: song,
                variant: SongCardVariant.grid,
                onTap: () => context.push(RoutePaths.songWith(song.id)),
                onPlay: () => search.playSong(song, fromList: search.recommendedSongs),
                onFavorite: () => search.toggleFavorite(song),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NewReleasesCarousel extends StatelessWidget {
  const _NewReleasesCarousel({required this.search, required this.r});
  final SearchController search;
  final Responsive r;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: search.newReleases.length,
        itemBuilder: (context, index) {
          final album = search.newReleases[index];
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
              Icon(icon, size: 20, color: TuneHiveColors.electricBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TuneHiveColors.coolWhite,
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

class _RecentSearchesGroup extends StatelessWidget {
  const _RecentSearchesGroup({required this.search});
  final SearchController search;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (search.recentSearches.isEmpty) return const SizedBox.shrink();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, size: 20, color: TuneHiveColors.electricBlue),
                const SizedBox(width: 8),
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TuneHiveColors.coolWhite,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: search.recentSearches.clear,
                  style: TextButton.styleFrom(
                    foregroundColor: TuneHiveColors.mutedText,
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          ...search.recentSearches.map((term) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: const Icon(Icons.access_time_rounded, color: TuneHiveColors.mutedText, size: 20),
            title: Text(
              term,
              style: const TextStyle(color: TuneHiveColors.coolWhite, fontSize: 16),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, color: TuneHiveColors.mutedText, size: 18),
              onPressed: () => search.clearRecentSearch(term),
            ),
            onTap: () {
              search.onSearchChanged(term);
            },
          )),
          const SizedBox(height: 32),
        ],
      );
    });
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
          color: TuneHiveColors.coolWhite,
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
                size: 52, color: TuneHiveColors.mutedText),
            const SizedBox(height: 14),
            const Text(
              'No matches found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TuneHiveColors.coolWhite,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different song, artist or album.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: TuneHiveColors.coolWhite.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
