import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/models/player_state_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/widgets/artwork_image.dart';
import 'package:tunehive/widgets/audio_waveform.dart';
import 'package:tunehive/widgets/play_button.dart';

/// Full-screen player — large artwork with ambient glow, animating waveform,
/// precise seek bar and transport controls.
class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Scaffold(
      backgroundColor: TuneHiveColors.charcoalBlack,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Obx(() {
            final song = player.song.value;
            if (song == null) {
              return const _IdlePlayer();
            }
            return LayoutBuilder(builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > 720;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _PlayerHeader(),
                      if (isLandscape)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _Artwork(song: song, size: 280)),
                            const SizedBox(width: 40),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _NowPlaying(song: song),
                                  const _SeekArea(),
                                  _TransportControls(player: player),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _Artwork(song: song, size: 300),
                        const SizedBox(height: 28),
                        _NowPlaying(song: song),
                        const SizedBox(height: 18),
                        const _SeekArea(),
                        const SizedBox(height: 22),
                        _TransportControls(player: player),
                      ],
                    ],
                  ),
                ),
              );
            });
          }),
        ),
      ),
    );
  }
}

class _IdlePlayer extends StatelessWidget {
  const _IdlePlayer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.equalizer_rounded,
              size: 64, color: TuneHiveColors.electricBlue),
          const SizedBox(height: 12),
          const Text(
            'Nothing playing',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TuneHiveColors.coolWhite,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick a song from Home or Search.',
            style: TextStyle(fontSize: 13, color: TuneHiveColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
IconButton(
          onPressed: () => context.push(RoutePaths.queue),
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.queue_music_rounded,
              color: TuneHiveColors.coolWhite),
        ),
      ],
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.song, required this.size});

  final SongModel song;
  final double size;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxArtSize = constraints.maxWidth > constraints.maxHeight
              ? constraints.maxHeight * 0.8
              : constraints.maxWidth * 0.85;
          final artSize = size.clamp(100.0, maxArtSize);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: artSize,
                height: artSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.player),
                  boxShadow: [
                    BoxShadow(
                      color: TuneHiveColors.charcoalBlack.withValues(alpha: 0.5),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ArtworkImage(
                  imageUrl: song.artworkUrl,
                  width: artSize,
                  height: artSize,
                  borderRadius: AppRadius.player,
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => AudioWaveform(
                    active: player.isPlaying.value,
                    height: 32,
                    barCount: 40,
                    barWidth: 2.8,
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying({required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          song.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: TuneHiveColors.coolWhite,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final current = player.song.value;
          return Text(
            current?.artistName ?? song.artistName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: TuneHiveColors.coolWhite,
            ),
          );
        }),
        const SizedBox(height: 10),
        Obx(() {
          final liked = player.isLiked(song.id);
          return IconButton(
            onPressed: () => player.toggleFavorite(song),
            visualDensity: VisualDensity.compact,
            icon: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border,
              color: liked ? TuneHiveColors.electricBlue : TuneHiveColors.mutedText,
              size: 22,
            ),
          );
        }),
      ],
    );
  }
}

class _SeekArea extends StatelessWidget {
  const _SeekArea();

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${d.inHours > 0 ? '${d.inHours}:${m.toString().padLeft(2, '0')}' : '$m'}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: TuneHiveColors.electricBlue,
            inactiveTrackColor: TuneHiveColors.elevatedSurface,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: SliderComponentShape.noOverlay,
            thumbColor: TuneHiveColors.electricBlue,
          ),
          child: Obx(() => Slider(
                value: player.progress.value.clamp(0.0, 1.0).toDouble(),
                onChanged: player.hasSong ? player.seekToFraction : null,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  _fmt(player.position.value),
                  style: const TextStyle(
                      fontSize: 11, color: TuneHiveColors.mutedText),
                ),
              ),
              Obx(
                () => Text(
                  _fmt(player.duration.value),
                  style: const TextStyle(
                      fontSize: 11, color: TuneHiveColors.mutedText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls({required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            Obx(() {
              final hasPrev = player.hasSong && (player.queueIndex.value > 0 || player.position.value > const Duration(seconds: 3));
              return IconButton(
                onPressed: hasPrev ? player.previous : null,
                iconSize: 34,
                color: TuneHiveColors.coolWhite,
                disabledColor: TuneHiveColors.mutedText.withValues(alpha: 0.3),
                icon: const Icon(Icons.skip_previous_rounded),
                padding: const EdgeInsets.all(12), // Minimum practical touch area (44px)
              );
            }),
            const SizedBox(width: 24),
            // Play / Pause Button
            Obx(() => PlayButton(
                  size: 72,
                  isPlaying: player.isPlaying.value,
                  isLoading: player.isLoading.value,
                  onPressed: player.togglePlayPause,
                )),
            const SizedBox(width: 24),
            // Next Button
            Obx(() {
              final hasNext = player.hasSong && (player.queueIndex.value < player.queue.length - 1 || player.repeatMode.value == RepeatMode.all);
              return IconButton(
                onPressed: hasNext ? player.next : null,
                iconSize: 34,
                color: TuneHiveColors.coolWhite,
                disabledColor: TuneHiveColors.mutedText.withValues(alpha: 0.3),
                icon: const Icon(Icons.skip_next_rounded),
                padding: const EdgeInsets.all(12),
              );
            }),
          ],
        ),
      ],
    );
  }
}