import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/mock_data.dart';
import 'package:tunehive/services/music/music_service.dart';
import 'package:tunehive/widgets/artwork_image.dart';
import 'package:tunehive/widgets/error_state.dart';
import 'package:tunehive/widgets/favorite_button.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';

/// Full-screen album detail — large artwork, actions and track list. Uses a
/// two-column layout on tablet/desktop and a centered single column on phones.
class AlbumDetailView extends StatefulWidget {
  const AlbumDetailView({super.key, required this.id});

  final String id;

  @override
  State<AlbumDetailView> createState() => _AlbumDetailViewState();
}

class _AlbumDetailViewState extends State<AlbumDetailView> {
  AlbumModel? _album;
  bool _loading = true;
  bool _error = false;

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
      final album = await Get.find<MusicService>().getAlbum(widget.id);
      if (!mounted) return;
      setState(() {
        _album = album;
        _loading = false;
        _error = album == null;
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
    return Scaffold(backgroundColor: TuneHiveColors.charcoalBlack, body: _buildBody());
  }

  Widget _buildBody() {
    if (_loading) return const _AlbumSkeleton();
    final album = _album;
    if (_error || album == null) {
      return SafeArea(
        child: ErrorState(
          title: 'Album unavailable',
          message: "We couldn't load this album. Try again in a moment.",
          onRetry: _load,
        ),
      );
    }
    return _AlbumDetailBody(album: album);
  }
}

// ---------------------------------------------------------------------------
// Loaded body
// ---------------------------------------------------------------------------

class _AlbumDetailBody extends StatelessWidget {
  const _AlbumDetailBody({required this.album});

  final AlbumModel album;

  List<SongModel> get _tracks {
    if (album.songs.isNotEmpty) return album.songs;
    return MockData.songs.where((s) => s.albumId == album.id).toList();
  }

  String get _durationText {
    final total = _tracks.fold<Duration>(
      Duration.zero,
      (sum, song) => sum + song.duration,
    );
    if (total == Duration.zero) return '';
    final minutes = total.inMinutes;
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final hPad = isWide ? AppSpacing.xxl : AppSpacing.lg;
          final artSize = isWide
              ? 260.0
              : math.min(constraints.maxWidth * 0.58, 240.0);

          final header = _AlbumHeader(
            album: album,
            tracks: _tracks,
            artSize: artSize,
            durationText: _durationText,
            centered: !isWide,
          );
          final tracks = _TrackList(album: album, tracks: _tracks);

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    AppSpacing.sm,
                    hPad,
                    AppSpacing.huge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TopBar(),
                      const SizedBox(height: AppSpacing.lg),
                      FadeSlide(
                        duration: const Duration(milliseconds: 260),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 300, child: header),
                                  const SizedBox(width: AppSpacing.xxxl),
                                  Expanded(child: tracks),
                                ],
                              )
                            : Column(
                                children: [
                                  header,
                                  const SizedBox(height: AppSpacing.xl),
                                  tracks,
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TuneHiveColors.cardSurface,
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
            color: TuneHiveColors.coolWhite,
          ),
        ),
      ),
    );
  }
}

class _AlbumHeader extends StatelessWidget {
  const _AlbumHeader({
    required this.album,
    required this.tracks,
    required this.artSize,
    required this.durationText,
    required this.centered,
  });

  final AlbumModel album;
  final List<SongModel> tracks;
  final double artSize;
  final String durationText;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        ArtworkImage(
          imageUrl: album.artworkUrl,
          width: artSize,
          height: artSize,
          borderRadius: AppRadius.xl,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          album.name,
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.1,
            color: TuneHiveColors.coolWhite,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (album.artistId != null)
          InkWell(
            onTap: () => context.go(RoutePaths.artistWith(album.artistId!)),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Text(
              album.artistName,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TuneHiveColors.electricBlue,
              ),
            ),
          )
        else
          Text(
            album.artistName,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: TuneHiveColors.coolWhite,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          [
            if (album.releaseYear != null) '${album.releaseYear}',
            '${album.displayTrackCount} songs',
            if (durationText.isNotEmpty) durationText,
          ].join('  •  '),
          textAlign: textAlign,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: TuneHiveColors.mutedText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _AlbumActions(album: album, tracks: tracks),
      ],
    );
  }
}

class _AlbumActions extends StatelessWidget {
  const _AlbumActions({required this.album, required this.tracks});

  final AlbumModel album;
  final List<SongModel> tracks;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PrimaryAction(
          icon: Icons.play_arrow_rounded,
          label: 'Play',
          onTap: tracks.isEmpty
              ? null
              : () => player.play(tracks.first, fromList: tracks),
        ),
        const SizedBox(width: AppSpacing.md),
        _SecondaryAction(
          icon: Icons.shuffle_rounded,
          label: 'Shuffle',
          onTap: tracks.isEmpty
              ? null
              : () => player.play(
                  tracks[math.Random().nextInt(tracks.length)],
                  fromList: tracks,
                ),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? TuneHiveColors.elevatedSurface : TuneHiveColors.electricBlue,
      borderRadius: BorderRadius.circular(AppRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: onTap == null
                    ? TuneHiveColors.mutedText
                    : TuneHiveColors.coolWhite,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: onTap == null
                      ? TuneHiveColors.mutedText
                      : TuneHiveColors.coolWhite,
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
        foregroundColor: TuneHiveColors.coolWhite,
        side: const BorderSide(color: TuneHiveColors.elevatedSurface),
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

class _TrackList extends StatelessWidget {
  const _TrackList({required this.album, required this.tracks});

  final AlbumModel album;
  final List<SongModel> tracks;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Text(
          'No tracks available.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: TuneHiveColors.mutedText,
          ),
        ),
      );
    }
    final player = Get.find<PlayerController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tracks',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: TuneHiveColors.coolWhite,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < tracks.length; i++)
          _TrackRow(
            index: i + 1,
            song: tracks[i],
            onTap: () => player.play(tracks[i], fromList: tracks),
          ),
      ],
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.index,
    required this.song,
    required this.onTap,
  });

  final int index;
  final SongModel song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$index',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TuneHiveColors.mutedText,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TuneHiveColors.coolWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: TuneHiveColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            if (song.duration > Duration.zero)
              Text(
                song.durationText,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: TuneHiveColors.mutedText,
                ),
              ),
            const SizedBox(width: AppSpacing.sm),
            Obx(
              () => FavoriteButton(
                size: 18,
                isFavorited: player.isLiked(song.id),
                onPressed: () => player.toggleFavorite(song),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton
// ---------------------------------------------------------------------------

class _AlbumSkeleton extends StatelessWidget {
  const _AlbumSkeleton();

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return SafeArea(
      child: Shimmer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ShimmerBox(
                  width: r.isPhone ? 220 : 260,
                  height: r.isPhone ? 220 : 260,
                  borderRadius: AppRadius.xl,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const ShimmerBox(width: 200, height: 26, borderRadius: 10),
              const SizedBox(height: AppSpacing.md),
              const ShimmerBox(width: 140, height: 16, borderRadius: 8),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < 6; i++) ...[
                const ShimmerBox(
                  width: double.infinity,
                  height: 52,
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
