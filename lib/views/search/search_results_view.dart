import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/music_service.dart';
import 'package:tunehive/widgets/album_card.dart';
import 'package:tunehive/widgets/artist_card.dart';
import 'package:tunehive/widgets/empty_state.dart';
import 'package:tunehive/widgets/error_state.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';
import 'package:tunehive/widgets/song_card.dart';

class SearchResultsView extends StatefulWidget {
  const SearchResultsView({super.key, required this.query});
  final String query;

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  late String _query;
  bool _isLoading = true;
  String? _error;
  List<SongModel> _songResults = [];
  List<AlbumModel> _albumResults = [];
  List<ArtistModel> _artistResults = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    _searchController.text = _query;
    _performSearch(_query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String q) async {
    if (q.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final music = Get.find<MusicService>();
      final results = await Future.wait([
        music.searchSongs(q),
        music.searchAlbums(q),
        music.searchArtists(q),
      ]);
      if (!mounted) return;
      setState(() {
        _songResults = results[0] as List<SongModel>;
        _albumResults = results[1] as List<AlbumModel>;
        _artistResults = results[2] as List<ArtistModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final hPad = r.isPhoneSmall ? 12.0 : AppSpacing.lg;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(hPad),
            Expanded(
              child: _isLoading
                  ? _buildSkeleton(hPad)
                  : _error != null
                  ? ErrorState(
                      message: _error,
                      onRetry: () => _performSearch(_query),
                    )
                  : _buildBody(hPad, r),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        hPad,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                final q = value.trim();
                if (q.isNotEmpty && q != _query) {
                  setState(() => _query = q);
                  _performSearch(q);
                }
              },
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search songs, artists, albums',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _buildSkeleton(double hPad) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: hPad),
        children: [
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              ShimmerBox(width: 100, height: 18, borderRadius: 8),
              Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < 6; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const ShimmerBox(width: 48, height: 48, borderRadius: 8),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(
                          width: double.infinity,
                          height: 14,
                          borderRadius: 6,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ShimmerBox(width: 120, height: 12, borderRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(double hPad, Responsive r) {
    final hasAny =
        _songResults.isNotEmpty ||
        _albumResults.isNotEmpty ||
        _artistResults.isNotEmpty;

    if (!hasAny) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results for "$_query"',
        message: 'Check the spelling or try a different search.',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        if (_songResults.isNotEmpty) ...[
          _buildSongSection(hPad, r),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (_albumResults.isNotEmpty) ...[
          _buildAlbumSection(hPad, r),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (_artistResults.isNotEmpty) ...[_buildArtistSection(hPad, r)],
      ],
    );
  }

  Widget _buildSongSection(double hPad, Responsive r) {
    final player = Get.find<PlayerController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlide(
          delay: const Duration(milliseconds: 40),
          duration: AppMotion.standard,
          child: _SectionHeader(label: 'Songs (${_songResults.length})'),
        ),
        SizedBox(
          height: 230,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardW = constraints.maxWidth > 720 ? 180.0 : 150.0;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: _songResults.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, i) {
                  final song = _songResults[i];
                  return SongCard(
                    song: song,
                    width: cardW,
                    onTap: () => player.play(song, fromList: _songResults),
                    onPlay: () => player.play(song, fromList: _songResults),
                    onFavorite: () => player.toggleFavorite(song),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumSection(double hPad, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlide(
          delay: const Duration(milliseconds: 130),
          duration: AppMotion.standard,
          child: _SectionHeader(label: 'Albums (${_albumResults.length})'),
        ),
        SizedBox(
          height: 230,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardW = constraints.maxWidth > 720 ? 180.0 : 150.0;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: _albumResults.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, i) {
                  final album = _albumResults[i];
                  return AlbumCard(
                    album: album,
                    width: cardW,
                    onTap: () => context.push(RoutePaths.albumWith(album.id)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArtistSection(double hPad, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlide(
          delay: const Duration(milliseconds: 220),
          duration: AppMotion.standard,
          child: _SectionHeader(label: 'Artists (${_artistResults.length})'),
        ),
        SizedBox(
          height: 160,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final avatarSize = constraints.maxWidth > 720 ? 100.0 : 96.0;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: _artistResults.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.lg),
                itemBuilder: (_, i) {
                  final artist = _artistResults[i];
                  return ArtistCard(
                    artist: artist,
                    avatarSize: avatarSize,
                    onTap: () => context.push(RoutePaths.artistWith(artist.id)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
