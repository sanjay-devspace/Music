import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/controllers/library_controller.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/widgets/empty_state.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';
import 'package:tunehive/widgets/song_card.dart';

class LikedSongsView extends StatelessWidget {
  const LikedSongsView({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();
    final player = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Liked Songs',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${library.likedSongs.length} songs',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (library.isLoading.value) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Shimmer(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 72,
                            borderRadius: AppSpacing.sm,
                          ),
                        ),
                      );
                    },
                  );
                }
                if (library.likedSongs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'No liked songs yet',
                    message: 'Tap the heart on any song to save it here.',
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: library.likedSongs.length,
                  itemBuilder: (context, index) {
                    final song = library.likedSongs[index];
                    return FadeSlide(
                      delay: Duration(milliseconds: index * 40),
                      child: SongCard(
                        song: song,
                        variant: SongCardVariant.list,
                        onTap: () => library.playSong(
                          song,
                          fromList: library.likedSongs,
                        ),
                        onFavorite: () => player.toggleFavorite(song),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
