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
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/mock_data.dart';
import 'package:tunehive/services/music/music_service.dart';
import 'package:tunehive/widgets/artwork_image.dart';
import 'package:tunehive/widgets/error_state.dart';
import 'package:tunehive/widgets/favorite_button.dart';
import 'package:tunehive/widgets/play_button.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';
import 'package:tunehive/widgets/song_card.dart';

/// Full-screen song detail — parallax artwork header, actions, credits and
/// related sections. Loading/error states are handled inline.
class SongDetailView extends StatefulWidget {
  const SongDetailView({super.key, required this.id});

  final String id;

  @override
  State<SongDetailView> createState() => _SongDetailViewState();
}

class _SongDetailViewState extends State<SongDetailView> {
  SongModel? _song;
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
      final song = await Get.find<MusicService>().getSong(widget.id);
      if (!mounted) return;
      setState(() {
        _song = song;
        _loading = false;
        _error = song == null;
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
    if (_loading) return const _SongSkeleton();
    final song = _song;
    if (_error || song == null) {
      return SafeArea(
        child: ErrorState(
          title: 'Song unavailable',
          message: "We couldn't load this track. Try again in a moment.",
          onRetry: _load,
        ),
      );
    }
    return _SongDetailBody(song: song);
  }
}

// ---------------------------------------------------------------------------
// Loaded body
// ---------------------------------------------------------------------------

class _SongDetailBody extends StatelessWidget {
  const _SongDetailBody({required this.song});

  final SongModel song;

  List<SongModel> get _fromArtist {
    final list = <SongModel>[song];
    list.addAll(
      MockData.songs.where(
        (s) => s.artistId == song.artistId && s.id != song.id,
      ),
    );
    return list;
  }

  List<SongModel> get _youMayAlsoLike => MockData.recommendations.first.songs;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final headerHeight = r.isPhone ? 340.0 : 420.0;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: headerHeight,
          backgroundColor: TuneHiveColors.charcoalBlack,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: const _CircleAction(icon: Icons.arrow_back_rounded),
          actions: const [_CircleAction(icon: Icons.share_rounded)],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                ArtworkImage(
                  imageUrl: song.artworkUrl,
                  width: double.infinity,
                  height: headerHeight,
                  borderRadius: 0,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x660D181D),
                        Color(0x000D181D),
                        Color(0xCC15262D),
                        TuneHiveColors.charcoalBlack,
                      ],
                      stops: [0.0, 0.35, 0.85, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlide(
                  duration: const Duration(milliseconds: 240),
                  child: const Text(
                    'NOW PLAYING',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: TuneHiveColors.electricBlue,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FadeSlide(
                  delay: const Duration(milliseconds: 40),
                  duration: const Duration(milliseconds: 240),
                  child: Text(
                    song.title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: r.isPhone ? 26 : 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      height: 1.1,
                      color: TuneHiveColors.coolWhite,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FadeSlide(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 240),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (song.artistId != null)
                        _LinkText(
                          text: song.artistName,
                          onTap: () =>
                              context.go(RoutePaths.artistWith(song.artistId!)),
                        )
                      else
                        Text(
                          song.artistName,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TuneHiveColors.coolWhite,
                          ),
                        ),
                      if (song.albumName != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            '•',
                            style: TextStyle(color: TuneHiveColors.mutedText),
                          ),
                        ),
                        _LinkText(
                          text: song.albumName!,
                          muted: true,
                          onTap: song.albumId == null
                              ? null
                              : () => context.go(
                                  RoutePaths.albumWith(song.albumId!),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ActionsRow(song: song, queue: _fromArtist),
                const SizedBox(height: AppSpacing.xl),
                _MetaRow(song: song),
                const SizedBox(height: AppSpacing.xl),
                _CreditsCard(song: song),
                const SizedBox(height: AppSpacing.xxl),
                const _SectionTitle('More From The Artist'),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _SongCarousel(
            songs: _fromArtist.where((s) => s.id != song.id).toList(),
            queue: _fromArtist,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              0,
            ),
            child: const _SectionTitle('You May Also Like'),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: _SongCarousel(songs: _youMayAlsoLike, queue: _youMayAlsoLike),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: TuneHiveColors.charcoalBlack.withValues(alpha: 0.32),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (icon == Icons.arrow_back_rounded) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.home);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming soon')),
              );
            }
          },
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: TuneHiveColors.coolWhite),
          ),
        ),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({required this.text, this.onTap, this.muted = false});

  final String text;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: muted ? TuneHiveColors.mutedText : TuneHiveColors.coolWhite,
            decoration: onTap == null ? null : TextDecoration.underline,
            decorationColor: TuneHiveColors.mutedText,
          ),
        ),
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.song, required this.queue});

  final SongModel song;
  final List<SongModel> queue;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Row(
      children: [
        Obx(() {
          final isCurrent = player.song.value?.id == song.id;
          return PlayButton(
            size: 64,
            isPlaying: isCurrent && player.isPlaying.value,
            isLoading: isCurrent && player.isLoading.value,
            onPressed: () {
              if (isCurrent) {
                player.togglePlayPause();
              } else {
                player.play(song, fromList: queue);
              }
            },
          );
        }),
        const SizedBox(width: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: TuneHiveColors.cardSurface,
            shape: BoxShape.circle,
            border: Border.all(color: TuneHiveColors.elevatedSurface),
          ),
          child: Obx(
            () => FavoriteButton(
              size: 24,
              isFavorited: player.isLiked(song.id),
              onPressed: () => player.toggleFavorite(song),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        _MetaPill(icon: Icons.schedule_rounded, label: song.durationText),
        if (song.isExplicit)
          const _MetaPill(icon: Icons.explicit_rounded, label: 'Explicit'),
        const _MetaPill(icon: Icons.graphic_eq_rounded, label: 'Lossless'),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: TuneHiveColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: TuneHiveColors.elevatedSurface),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: TuneHiveColors.mutedText),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TuneHiveColors.coolWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditsCard extends StatelessWidget {
  const _CreditsCard({required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: TuneHiveColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: TuneHiveColors.elevatedSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credits',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: TuneHiveColors.coolWhite,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _CreditRow(
            label: 'Artist',
            value: song.artistName,
            onTap: song.artistId == null
                ? null
                : () => context.go(RoutePaths.artistWith(song.artistId!)),
          ),
          if (song.albumName != null)
            _CreditRow(
              label: 'Album',
              value: song.albumName!,
              onTap: song.albumId == null
                  ? null
                  : () => context.go(RoutePaths.albumWith(song.albumId!)),
            ),
          _CreditRow(
            label: 'Source',
            value: song.sourceProvider == 'jiosaavn' 
                ? 'JioSaavn' 
                : (song.sourceProvider == 'tunehive' ? 'TuneHive Records' : song.sourceProvider.capitalizeFirst ?? 'Unknown'),
          ),
        ],
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: TuneHiveColors.mutedText,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onTap == null
                      ? TuneHiveColors.coolWhite
                      : TuneHiveColors.coolWhite,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: TuneHiveColors.mutedText,
              ),
          ],
        ),
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
        color: TuneHiveColors.coolWhite,
      ),
    );
  }
}

class _SongCarousel extends StatelessWidget {
  const _SongCarousel({required this.songs, required this.queue});

  final List<SongModel> songs;
  final List<SongModel> queue;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Text(
          'Nothing else here yet.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            color: TuneHiveColors.mutedText,
          ),
        ),
      );
    }
    final player = Get.find<PlayerController>();
    return SizedBox(
      height: 248,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: songs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final song = songs[index];
          return SongCard(
            song: song,
            variant: SongCardVariant.horizontal,
            width: 168,
            onTap: () => player.play(song, fromList: queue),
            onPlay: () => player.play(song, fromList: queue),
            onFavorite: () => player.toggleFavorite(song),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton
// ---------------------------------------------------------------------------

class _SongSkeleton extends StatelessWidget {
  const _SongSkeleton();

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return SafeArea(
      child: Shimmer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ShimmerBox(
                  width: r.isPhone ? 240 : 300,
                  height: r.isPhone ? 240 : 300,
                  borderRadius: AppRadius.xl,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const ShimmerBox(width: 220, height: 26, borderRadius: 10),
              const SizedBox(height: AppSpacing.md),
              const ShimmerBox(width: 140, height: 16, borderRadius: 8),
              const SizedBox(height: AppSpacing.xl),
              const ShimmerBox(width: 64, height: 64, borderRadius: 32),
              const SizedBox(height: AppSpacing.xl),
              const ShimmerBox(
                width: double.infinity,
                height: 140,
                borderRadius: AppRadius.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
