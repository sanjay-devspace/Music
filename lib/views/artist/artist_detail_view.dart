import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/mock_data.dart';
import 'package:tunehive/services/music/music_service.dart';
import 'package:tunehive/widgets/artwork_image.dart';
import 'package:tunehive/widgets/editorial_card.dart';
import 'package:tunehive/widgets/error_state.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';
import 'package:tunehive/widgets/song_card.dart';

/// Full-screen artist detail — gradient header, follow/shuffle actions,
/// popular tracks, album carousel and an about card.
class ArtistDetailView extends StatefulWidget {
  const ArtistDetailView({super.key, required this.id});

  final String id;

  @override
  State<ArtistDetailView> createState() => _ArtistDetailViewState();
}

class _ArtistDetailViewState extends State<ArtistDetailView> {
  ArtistModel? _artist;
  bool _loading = true;
  bool _error = false;
  bool _following = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final artist = await Get.find<MusicService>().getArtist(widget.id);
      if (!mounted) return;
      final resolved =
          artist ??
          MockData.artists
              .where((a) => a.id == widget.id)
              .cast<ArtistModel?>()
              .firstWhere((a) => true, orElse: () => null);
      setState(() {
        _artist = resolved;
        _following = resolved?.isFollowing ?? false;
        _loading = false;
        _error = resolved == null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background, body: _buildBody());
  }

  Widget _buildBody() {
    if (_loading) return const _ArtistSkeleton();
    final artist = _artist;
    if (_error || artist == null) {
      return SafeArea(
        child: ErrorState(
          title: 'Artist unavailable',
          message: "We couldn't load this artist. Try again in a moment.",
          onRetry: _load,
        ),
      );
    }
    return _ArtistDetailBody(
      artist: artist,
      following: _following,
      onToggleFollow: () => setState(() => _following = !_following),
    );
  }
}

// ---------------------------------------------------------------------------
// Loaded body
// ---------------------------------------------------------------------------

class _ArtistDetailBody extends StatelessWidget {
  const _ArtistDetailBody({
    required this.artist,
    required this.following,
    required this.onToggleFollow,
  });

  final ArtistModel artist;
  final bool following;
  final VoidCallback onToggleFollow;

  List<SongModel> get _songs {
    final matches = MockData.songs
        .where((s) => s.artistId == artist.id)
        .toList();
    if (matches.isNotEmpty) return matches;
    return MockData.songs.take(6).toList();
  }

  List<AlbumModel> get _albums =>
      MockData.albums.where((a) => a.artistId == artist.id).toList();

  String get _bio {
    final genreText = artist.genres.isEmpty
        ? 'genre-defying'
        : artist.genres.join(' and ');
    return '${artist.name} is a $genreText artist known for immersive, '
        'late-night soundscapes and genre-blurring production. Their catalog '
        'has been streamed millions of times on TuneHive.';
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final songs = _songs;
    final albums = _albums;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ArtistHeader(
                artist: artist,
                following: following,
                onToggleFollow: onToggleFollow,
                songs: songs,
                avatarSize: r.isPhone ? 148 : 180,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.isPhone ? AppSpacing.lg : AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionTitle('Popular'),
                    const SizedBox(height: AppSpacing.md),
                    FadeSlide(
                      duration: const Duration(milliseconds: 260),
                      child: Column(
                        children: [
                          for (final song in songs.take(6))
                            _PopularRow(song: song, queue: songs),
                        ],
                      ),
                    ),
                    if (albums.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      const _SectionTitle('Albums'),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
              if (albums.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: r.isPhone ? AppSpacing.lg : AppSpacing.xxl,
                    ),
                    itemCount: albums.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      return FadeSlide(
                        delay: Duration(milliseconds: 60 + index * 45),
                        duration: const Duration(milliseconds: 260),
                        child: EditorialCard(
                          title: album.name,
                          description: album.releaseYear?.toString(),
                          artworkUrl: album.artworkUrl ?? '',
                          width: 170,
                          height: 220,
                          onTap: () =>
                              context.go(RoutePaths.albumWith(album.id)),
                          onPlay: () => _playAlbum(album, songs),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.isPhone ? AppSpacing.lg : AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    const _SectionTitle('About'),
                    const SizedBox(height: AppSpacing.md),
                    _AboutCard(bio: _bio, followersText: artist.followersText),
                    const SizedBox(height: AppSpacing.huge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playAlbum(AlbumModel album, List<SongModel> fallback) {
    final player = Get.find<PlayerController>();
    final tracks = MockData.songs.where((s) => s.albumId == album.id).toList();
    if (tracks.isNotEmpty) {
      player.play(tracks.first, fromList: tracks);
    } else if (fallback.isNotEmpty) {
      player.play(fallback.first, fromList: fallback);
    }
  }
}

class _ArtistHeader extends StatelessWidget {
  const _ArtistHeader({
    required this.artist,
    required this.following,
    required this.onToggleFollow,
    required this.songs,
    required this.avatarSize,
  });

  final ArtistModel artist;
  final bool following;
  final VoidCallback onToggleFollow;
  final List<SongModel> songs;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceLight, AppColors.background],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: AppColors.black.withValues(alpha: 0.28),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RoutePaths.home);
                      }
                    },
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlide(
                duration: const Duration(milliseconds: 280),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 60,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ArtistAvatar(
                    imageUrl: artist.avatarUrl,
                    size: avatarSize,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlide(
                delay: const Duration(milliseconds: 50),
                duration: const Duration(milliseconds: 280),
                child: Text(
                  artist.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (artist.followersText.isNotEmpty)
                Text(
                  artist.followersText,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              if (artist.genres.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final genre in artist.genres) _GenreChip(genre),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  _PrimaryAction(
                    icon: following
                        ? Icons.check_rounded
                        : Icons.person_add_alt_1_rounded,
                    label: following ? 'Following' : 'Follow',
                    active: following,
                    onTap: onToggleFollow,
                  ),
                  _SecondaryAction(
                    icon: Icons.shuffle_rounded,
                    label: 'Shuffle Play',
                    onTap: songs.isEmpty
                        ? null
                        : () => player.play(songs.first, fromList: songs),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.dividerStrong),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PopularRow extends StatelessWidget {
  const _PopularRow({required this.song, required this.queue});

  final SongModel song;
  final List<SongModel> queue;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Obx(
      () => SongCard(
        song: song.copyWith(isFavorited: player.isLiked(song.id)),
        variant: SongCardVariant.list,
        onTap: () => player.play(song, fromList: queue),
        onPlay: () => player.play(song, fromList: queue),
        onFavorite: () => player.toggleFavorite(song),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.bio, required this.followersText});

  final String bio;
  final String followersText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bio,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          if (followersText.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  followersText,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final background = active ? AppColors.surface : AppColors.primary;
    final foreground = active ? AppColors.textPrimary : AppColors.onPrimary;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: active ? AppColors.dividerStrong : AppColors.primary,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.dividerStrong),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton
// ---------------------------------------------------------------------------

class _ArtistSkeleton extends StatelessWidget {
  const _ArtistSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: ShimmerBox(width: 160, height: 160, borderRadius: 80),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Center(
                child: ShimmerBox(width: 180, height: 26, borderRadius: 10),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < 5; i++) ...[
                const ShimmerBox(
                  width: double.infinity,
                  height: 60,
                  borderRadius: AppRadius.md,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
