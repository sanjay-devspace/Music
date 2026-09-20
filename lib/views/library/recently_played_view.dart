import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/controllers/library_controller.dart';
import 'package:tunehive/widgets/empty_state.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';
import 'package:tunehive/widgets/song_card.dart';

class RecentlyPlayedView extends StatelessWidget {
  const RecentlyPlayedView({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();

    return Scaffold(
      backgroundColor: TuneHiveColors.charcoalBlack,
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
                    color: TuneHiveColors.coolWhite,
                  ),
                  Text(
                    'Recently Played',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: TuneHiveColors.coolWhite,
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
                if (library.recentlyPlayed.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'Nothing played yet',
                    message: 'Your recently played songs will appear here.',
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: library.recentlyPlayed.length,
                  itemBuilder: (context, index) {
                    final song = library.recentlyPlayed[index];
                    return FadeSlide(
                      delay: Duration(milliseconds: index * 40),
                      child: SongCard(
                        song: song,
                        variant: SongCardVariant.list,
                        onTap: () => library.playSong(
                          song,
                          fromList: library.recentlyPlayed,
                        ),
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
