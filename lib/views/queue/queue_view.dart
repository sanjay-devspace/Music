import 'package:flutter/material.dart' hide RepeatMode;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/models/player_state_model.dart';
import 'package:tunehive/models/queue_item_model.dart';
import 'package:tunehive/widgets/artwork_image.dart';
import 'package:tunehive/widgets/empty_state.dart';
import 'package:tunehive/widgets/play_button.dart';

class QueueView extends StatelessWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: TuneHiveColors.charcoalBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, player),
            if (player.hasSong) _buildNowPlaying(player),
            _buildSectionTitle(player),
            Expanded(
              child: Obx(() {
                if (player.queue.isEmpty) {
                  return const EmptyState(
                    icon: Icons.queue_music_rounded,
                    title: 'Queue is empty',
                    message: 'Play a song to start building your queue.',
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: AppSpacing.lg),
                  itemCount: player.queue.length,
                  itemBuilder: (context, index) {
                    final item = player.queue[index];
                    final isCurrent = index == player.queueIndex.value;
                    return FadeSlide(
                      delay: Duration(milliseconds: index * 40),
                      child: _buildQueueRow(
                        context,
                        player,
                        item,
                        index,
                        isCurrent,
                      ),
                    );
                  },
                );
              }),
            ),
            _buildTransportBar(player),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PlayerController player) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: TuneHiveColors.coolWhite,
          ),
          Text(
            'Queue',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: TuneHiveColors.coolWhite,
            ),
          ),
          const Spacer(),
          Obx(
            () => player.queue.isNotEmpty
                ? IconButton(
                    onPressed: () => player.clearQueue(),
                    icon: const Icon(Icons.delete_sweep_rounded),
                    color: TuneHiveColors.mutedText,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(PlayerController player) {
    return Obx(() {
      final song = player.song.value;
      if (song == null) return const SizedBox.shrink();
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: TuneHiveColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ArtworkImage(
                  imageUrl: song.artworkUrl,
                  width: 64,
                  height: 64,
                  borderRadius: AppRadius.lg,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TuneHiveColors.coolWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        song.artistName,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          color: TuneHiveColors.mutedText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: player.progress.value,
              color: TuneHiveColors.electricBlue,
              backgroundColor: TuneHiveColors.elevatedSurface,
              minHeight: 2,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    _formatDuration(player.position.value),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: TuneHiveColors.mutedText,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    _formatDuration(player.duration.value),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: TuneHiveColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(PlayerController player) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Obx(
        () => Row(
          children: [
            Text(
              'Up Next \u2022 ${player.queue.length}',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TuneHiveColors.coolWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueRow(
    BuildContext context,
    PlayerController player,
    QueueItemModel item,
    int index,
    bool isCurrent,
  ) {
    final song = item.song;
    return InkWell(
      onTap: () => player.playFromQueue(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: isCurrent
              ? Border(left: BorderSide(color: TuneHiveColors.electricBlue, width: 3))
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? TuneHiveColors.electricBlue : TuneHiveColors.mutedText,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isCurrent
                          ? TuneHiveColors.electricBlue
                          : TuneHiveColors.coolWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artistName,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: TuneHiveColors.mutedText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              song.durationText,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: TuneHiveColors.mutedText,
              ),
            ),
            IconButton(
              onPressed: () => player.removeQueueItem(index),
              icon: const Icon(Icons.close_rounded, size: 18),
              color: TuneHiveColors.mutedText,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportBar(PlayerController player) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: TuneHiveColors.cardSurface,
        border: Border(top: BorderSide(color: TuneHiveColors.elevatedSurface, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(
            () => IconButton(
              onPressed: () => player.toggleShuffle(),
              icon: Icon(
                Icons.shuffle_rounded,
                color: player.isShuffle.value
                    ? TuneHiveColors.electricBlue
                    : TuneHiveColors.mutedText,
              ),
            ),
          ),
          IconButton(
            onPressed: () => player.previous(),
            icon: const Icon(Icons.skip_previous_rounded),
            color: TuneHiveColors.coolWhite,
          ),
          Obx(
            () => PlayButton(
              size: 48,
              isPlaying: player.isPlaying.value,
              isLoading: false,
              onPressed: () => player.togglePlayPause(),
            ),
          ),
          IconButton(
            onPressed: () => player.next(),
            icon: const Icon(Icons.skip_next_rounded),
            color: TuneHiveColors.coolWhite,
          ),
          Obx(
            () => IconButton(
              onPressed: () => player.cycleRepeat(),
              icon: Icon(
                player.repeatMode.value == RepeatMode.off
                    ? Icons.repeat_rounded
                    : player.repeatMode.value == RepeatMode.all
                    ? Icons.repeat_rounded
                    : Icons.repeat_one_rounded,
                color: player.repeatMode.value != RepeatMode.off
                    ? TuneHiveColors.electricBlue
                    : TuneHiveColors.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
