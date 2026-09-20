import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/controllers/shell_controller.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/core/responsive/responsive_layout.dart';
import 'package:tunehive/widgets/app_sidebar.dart';
import 'package:tunehive/widgets/mini_player.dart';
import 'package:tunehive/controllers/auth_controller.dart';
import 'package:tunehive/widgets/navigation/floating_pill_navigation.dart';
import 'package:tunehive/views/shell/app_background.dart';

/// The application shell — shared chrome around the tab surfaces.
///
/// Mobile: bottom navigation + mini player above it.
/// Tablet/Desktop: animated sidebar + main content + mini player docked.
/// Music continues playing across tabs because the shell never rebuilds the
/// player controller.
class AppShellView extends StatelessWidget {
  const AppShellView({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goToBranch(int index, ShellController shell) {
    shell.onIndexChanged(index);
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    return ResponsiveLayoutBuilder(
      child: Obx(() {
        final responsive = Responsive.of(context);
        final index = shell.currentIndex.value;
        final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

        final player = Get.find<PlayerController>();
        final bottomBar = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.standard,
              switchInCurve: AppMotion.easeOut,
              switchOutCurve: AppMotion.easeInOut,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: player.hasSong
                  ? Obx(
                      () => MiniPlayer(
                        key: ValueKey(player.song.value?.id),
                        artworkUrl: player.song.value?.artworkUrl,
                        title: player.song.value?.title ?? '',
                        artist: player.song.value?.artistName ?? '',
                        isPlaying: player.isPlaying.value,
                        isFavorited: player.song.value != null &&
                            player.isLiked(player.song.value!.id),
                        progress: player.progress.value,
                        onTap: () => context.push('/player'),
                        onFavorite: () => player.toggleFavorite(),
                        onPlayPause: player.togglePlayPause,
                        onNext: player.next,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (!isDesktop) FloatingPillNavigation(
              currentIndex: index,
              onTap: (i) => _goToBranch(i, shell),
            ),
          ],
        );

        if (isDesktop) {
          return Scaffold(
            backgroundColor: TuneHiveColors.charcoalBlack,
            body: Row(
              children: [
                AppSidebar(
                  currentIndex: index,
                  onTap: (i) => _goToBranch(i, shell),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: navigationShell),
                      if (player.hasSong)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            child: Obx(
                              () => MiniPlayer(
                                artworkUrl: player.song.value?.artworkUrl,
                                title: player.song.value?.title ?? '',
                                artist: player.song.value?.artistName ?? '',
                                isPlaying: player.isPlaying.value,
                                isFavorited: player.song.value != null &&
                                    player.isLiked(player.song.value!.id),
                                progress: player.progress.value,
                                onTap: () => context.push('/player'),
                                onFavorite: () => player.toggleFavorite(),
                                onPlayPause: player.togglePlayPause,
                                onNext: player.next,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate the total height of all floating overlays to inset the page content.
        final isSmall = responsive.isPhoneSmall;
        final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
        
        final navHeight = isSmall ? 52.0 : responsive.isPhone ? 56.0 : 62.0;
        final navBottomGap = isSmall ? 16.0 : responsive.isPhone ? 20.0 : 24.0;
        
        // MiniPlayer Height (64 container + 8 padding = 72.0)
        final miniPlayerTotalHeight = player.hasSong ? 72.0 : 0.0;
        
        // Add 16px of visual breathing room so content ends slightly before the overlay
        final totalBottomInset = navHeight + safeBottom + navBottomGap + miniPlayerTotalHeight + 16.0;

        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent, // Background handled by AppBackground
          resizeToAvoidBottomInset: false, // Prevents floating nav from jumping above keyboard
          body: Stack(
            children: [
              Positioned.fill(
                child: AppBackground(
                  scrollOffset: shell.backgroundScrollOffset,
                ),
              ),
              Positioned.fill(
                child: Obx(() {
                  final loggingOut = Get.find<AuthController>().isLoggingOut.value;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    opacity: loggingOut ? 0.0 : 1.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      scale: loggingOut ? 0.98 : 1.0,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          padding: MediaQuery.paddingOf(context).copyWith(
                            bottom: totalBottomInset,
                          ),
                        ),
                        child: navigationShell,
                      ),
                    ),
                  );
                }),
              ),
              Positioned(
                left: isSmall ? 10.0 : 16.0,
                right: isSmall ? 10.0 : 16.0,
                bottom: safeBottom + navBottomGap,
                child: Obx(() {
                  final loggingOut = Get.find<AuthController>().isLoggingOut.value;
                  return AnimatedSlide(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeIn,
                    offset: loggingOut ? const Offset(0, 0.6) : Offset.zero,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      opacity: loggingOut ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: loggingOut,
                        child: bottomBar,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}