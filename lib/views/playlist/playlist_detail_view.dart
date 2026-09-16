import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/models/playlist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/mock_data.dart';
import 'package:tunehive/widgets/artwork_image.dart';
import 'package:tunehive/widgets/empty_state.dart';
import 'package:tunehive/widgets/favorite_button.dart';

/// Full-screen playlist detail — cover, description, actions and track list.
/// Resolves the playlist from mock collections and degrades to an empty state
/// when the id is unknown.
class PlaylistDetailView extends StatefulWidget {
  const PlaylistDetailView({super.key, required this.id});

  final String id;

  @override
  State<PlaylistDetailView> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends State<PlaylistDetailView> {
  PlaylistModel? _playlist;

  @override
  void initState() {
    super.initState();
    _playlist = _findPlaylist(widget.id);
  }

  static PlaylistModel? _findPlaylist(String id) {
    final collections = <List<PlaylistModel>>[
      MockData.playlists,
      MockData.dailyMixes,
      MockData.editorialPlaylists,
    ];
    for (final collection in collections) {
      for (final playlist in collection) {
        if (playlist.id == id) return playlist;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _playlist;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: playlist == null
            ? _PlaylistNotFound(onBack: () => _goBack(context))
            : _PlaylistDetailBody(playlist: playlist),
      ),
    );
  }

  static void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }
}

class _PlaylistNotFound extends StatelessWidget {
  const _PlaylistNotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onBack,
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
        ),
        Expanded(
          child: EmptyState(
            icon: Icons.queue_music_rounded,
            title: 'Playlist not found',
            message:
                "This playlist may have been removed or the link is "
                "broken.",
            actionLabel: 'Go back',
            onAction: onBack,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loaded body
// ---------------------------------------------------------------------------

class _PlaylistDetailBody extends StatelessWidget {
  const _PlaylistDetailBody({required this.playlist});

  final PlaylistModel playlist;

  String get _durationText {
    final total = playlist.songs.fold<Duration>(
      Duration.zero,
      (sum, song) => sum + song.duration,
    );
    if (total == Duration.zero) return '';
    return '${total.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        final hPad = isWide ? AppSpacing.xxl : AppSpacing.lg;
        final artSize = isWide
            ? 260.0
            : math.min(constraints.maxWidth * 0.58, 240.0);

        final header = _PlaylistHeader(
          playlist: playlist,
          artSize: artSize,
          durationText: _durationText,
          centered: !isWide,
        );
        final tracks = _TrackList(playlist: playlist);

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
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
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
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({
    required this.playlist,
    required this.artSize,
    required this.durationText,
    required this.centered,
  });

  final PlaylistModel playlist;
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
          imageUrl: playlist.coverUrl,
          width: artSize,
          height: artSize,
          borderRadius: AppRadius.xl,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          playlist.name,
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.1,
            color: AppColors.textPrimary,
          ),
        ),
        if (playlist.description != null &&
            playlist.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            playlist.description!,
            textAlign: textAlign,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          '•  ${playlist.songCount} songs'
          '${durationText.isEmpty ? '' : '  •  $durationText'}',
          textAlign: textAlign,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PlaylistActions(playlist: playlist),
      ],
    );
  }
}

class _PlaylistActions extends StatelessWidget {
  const _PlaylistActions({required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    final songs = playlist.songs;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PrimaryAction(
          icon: Icons.play_arrow_rounded,
          label: 'Play',
          onTap: songs.isEmpty
              ? null
              : () => player.play(songs.first, fromList: songs),
        ),
        const SizedBox(width: AppSpacing.md),
        _SecondaryAction(
          icon: Icons.shuffle_rounded,
          label: 'Shuffle',
          onTap: songs.isEmpty
              ? null
              : () => player.play(
                  songs[math.Random().nextInt(songs.length)],
                  fromList: songs,
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
      color: onTap == null ? AppColors.surfaceLight : AppColors.primary,
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
                    ? AppColors.textMuted
                    : AppColors.onPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: onTap == null
                      ? AppColors.textMuted
                      : AppColors.onPrimary,
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

class _TrackList extends StatelessWidget {
  const _TrackList({required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    final songs = playlist.songs;
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Text(
          'This playlist has no tracks yet.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textMuted,
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < songs.length; i++)
          _TrackRow(
            index: i + 1,
            song: songs[i],
            onTap: () => player.play(songs[i], fromList: songs),
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
                  color: AppColors.textMuted,
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
                      color: AppColors.textPrimary,
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
                      color: AppColors.textMuted,
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
                  color: AppColors.textMuted,
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
