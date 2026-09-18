import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/core/animation/scale_transition.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/controllers/home_controller.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/models/playlist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/widgets/error_state.dart';
import 'package:tunehive/widgets/hero_card.dart';
import 'package:tunehive/widgets/mood_chip.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';
import 'package:tunehive/widgets/song_card.dart';
import 'package:tunehive/widgets/branding/animated_home_logo.dart';
import 'package:tunehive/controllers/shell_controller.dart';

import 'home_responsive.dart';

/// Premium Home — editorial hero, moods, trending, recommendations, daily
/// mixes, artists and recently played, all adapted to phones/tablets/desktops.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final shell = Get.find<ShellController>(); // Add ShellController to access shared scroll offset

    return Scaffold(
      backgroundColor: Colors.transparent, // Let global background show through
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.axis == Axis.vertical) {
            shell.backgroundScrollOffset.value = scrollInfo.metrics.pixels;
          }
          return false;
        },
        child: Obx(() {
          if (home.isLoading.value &&
              home.trending.isEmpty &&
              home.moods.isEmpty) {
            return const HomeSkeleton();
          }
          if (home.errorMessage.value != null && home.trending.isEmpty) {
            return ErrorState(
              message: home.errorMessage.value,
              onRetry: home.refreshHome,
            );
          }
          return _HomeFeed(home: home);
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feed
// ---------------------------------------------------------------------------

class _HomeFeed extends StatelessWidget {
  const _HomeFeed({required this.home});

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final hr = HomeResponsive(r);
    return RefreshIndicator(
      onRefresh: home.refreshHome,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: hr.headerTop,
                bottom: MediaQuery.paddingOf(context).bottom + 24,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hr.horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _HomeHeader(home: home, r: r),
                        SizedBox(height: r.isPhoneSmall ? 16 : 24),
                        _Greeting(home: home, r: r),
                        SizedBox(height: r.isPhoneSmall ? 16 : 20),
                        _SearchBar(r: r),
                      ],
                    ),
                  ),
                  SizedBox(height: hr.sectionGap),
                  _MoodRow(home: home, r: r, staggerStep: hr.staggerStep),
                  SizedBox(height: hr.sectionGap),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hr.horizontalPadding),
                    child: _HeroSection(home: home, r: r),
                  ),
                  SizedBox(height: hr.sectionGap),
                  _TrendingSection(home: home, r: r, hr: hr),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Entrance wrapper — staggers sections in on first frame.
// ---------------------------------------------------------------------------

class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.step,
    required this.duration,
    required this.child,
  });

  final int step;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      delay: Duration(milliseconds: step * 80),
      duration: const Duration(milliseconds: 550),
      offset: const Offset(0, 0.15),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Header + greeting + search
// ---------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.home, required this.r});

  final HomeController home;
  final Responsive r;

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      duration: AppMotion.large,
      offset: const Offset(0, -0.02),
      child: Row(
        children: [
          Expanded(
            child: AnimatedHomeLogo(responsive: r),
          ),
          const Spacer(),
          _BellButton(),
          const SizedBox(width: 4),
          _ProfileButton(home: home),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push(RoutePaths.notificationCenter),
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.notifications_none_rounded,
              color: AppColors.textSecondary, size: 26),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.home});

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    final token = home.userName.value.isNotEmpty
        ? home.userName.value.split(' ').map((w) => w[0]).take(2).join()
        : 'TH';
    return InkWell(
      onTap: () => context.go(RoutePaths.profile),
      customBorder: const CircleBorder(),
      child: ClipOval(
        child: Container(
          width: 38,
          height: 38,
          color: AppColors.primary,
          alignment: Alignment.center,
          child: Text(
            token,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.home, required this.r});

  final HomeController home;
  final Responsive r;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlide(
          duration: AppMotion.large,
          offset: const Offset(0, -0.02),
          child: Text(
            '${home.greeting},',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: r.fontSize.title * 0.72,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FadeSlide(
          delay: const Duration(milliseconds: 45),
          duration: AppMotion.large,
          offset: const Offset(0, -0.02),
          child: Text(
            home.userName.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: r.fontSize.headline,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.r});

  final Responsive r;

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 90),
      duration: AppMotion.large,
      offset: const Offset(0, -0.02),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () => context.go(RoutePaths.search),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: r.isPhone ? 50 : 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search songs, artists, moods',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const Icon(Icons.tune_rounded,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Moods
// ---------------------------------------------------------------------------

class _MoodRow extends StatelessWidget {
  const _MoodRow({required this.home, required this.r, required this.staggerStep});

  final HomeController home;
  final Responsive r;
  final Duration staggerStep;

  @override
  Widget build(BuildContext context) {
    final hr = HomeResponsive(r);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hr.horizontalPadding),
          child: _SectionTitle(r: r, text: 'Your Mood', step: 1),
        ),
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: hr.horizontalPadding, right: hr.horizontalPadding, bottom: 6),
            itemCount: home.moods.length,
            itemBuilder: (context, index) {
              final mood = home.moods[index];
              return FadeSlide(
                delay: Duration(
                    milliseconds: 120 + (index * staggerStep.inMilliseconds)),
                offset: const Offset(0.02, 0),
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: MoodChip(
                    mood: mood,
                    selected: home.selectedMoodId.value == mood.id,
                    onTap: () => home.selectMood(mood.id),
                  ),
                ),
              );
            },
          ),
        ),
        // Mood picks — appears when a mood is active.
        Obx(() {
          final songs = home.moodSongs;
          if (home.selectedMoodId.value == null || songs.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hr.horizontalPadding),
                  child: _SectionTitle(r: r, text: "Because you're feeling ${_moodName(home)}", step: 1),
                ),
                SizedBox(
                  height: hr.songCardWidth + 78,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: hr.horizontalPadding, right: hr.horizontalPadding, bottom: 8),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SongCard(
                          song: song,
                          variant: SongCardVariant.horizontal,
                          width: hr.songCardWidth,
                          onPlay: () => home.playSong(song, fromList: songs),
                          onTap: () => context.push(RoutePaths.songWith(song.id)),
                          onFavorite: () => _favorite(home, song),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static String _moodName(HomeController home) {
    final selectedId = home.selectedMoodId.value;
    if (selectedId == null) return 'this mood';
    for (final m in home.moods) {
      if (m.id == selectedId) return m.name;
    }
    return 'this mood';
  }

  static void _favorite(HomeController home, SongModel song) {
    Get.find<PlayerController>().toggleFavorite(song);
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.home, required this.r});

  final HomeController home;
  final Responsive r;

  @override
  Widget build(BuildContext context) {
    final hr = HomeResponsive(r);
    final feature = home.activeHero;
    return Column(
      children: [
        SizedBox(height: 12),
        ScaleIn(
          delay: const Duration(milliseconds: 200),
          duration: AppMotion.hero,
          curve: AppMotion.easeOut,
          child: AspectRatio(
            aspectRatio: r.isPhoneSmall ? 1.4 : r.isTablet ? 1.8 : 1.6,
            child: HeroCard(
              feature: feature,
              height: double.infinity,
              onPlay: () {
                final list = home.trending;
                if (list.isNotEmpty) home.playSong(list.first, fromList: list);
              },
              onFavorite: () => Get.find<PlayerController>()
                  .toggleFavorite(home.trending.isNotEmpty ? home.trending.first : null),
              isFavorited: home.trending.isNotEmpty &&
                  Get.find<PlayerController>().isLiked(home.trending.first.id),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < home.heroFeatures.length; i++)
              AnimatedContainer(
                duration: AppMotion.micro,
                width: i == 0 ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == 0 ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared section pieces
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.r, required this.text, this.step = 1});

  final Responsive r;
  final String text;
  final int step;

  @override
  Widget build(BuildContext context) {
    final hr = HomeResponsive(r);
    return _Entrance(
      step: step,
      duration: AppMotion.standard,
      child: Padding(
        padding: EdgeInsets.only(bottom: r.isPhoneSmall ? 10 : 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: hr.sectionTitleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselList extends StatelessWidget {
  const _CarouselList({required this.height, required this.itemCount, required this.itemBuilder, this.padding});

  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? EdgeInsets.only(bottom: 8),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trending
// ---------------------------------------------------------------------------

class _TrendingSection extends StatelessWidget {
  const _TrendingSection({
    required this.home,
    required this.r,
    required this.hr,
  });

  final HomeController home;
  final Responsive r;
  final HomeResponsive hr;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hr.horizontalPadding),
          child: _SectionTitle(
            r: r,
            text: 'Trending Now',
            step: 1,
          ),
        ),
        _CarouselList(
          height: hr.songCardWidth + 78,
          padding: EdgeInsets.only(left: hr.horizontalPadding, right: hr.horizontalPadding, bottom: 8),
          itemCount: home.trending.length,
          itemBuilder: (_, index) {
            final song = home.trending[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SongCard(
                song: song,
                variant: SongCardVariant.horizontal,
                width: hr.songCardWidth,
                onPlay: () => home.playSong(song, fromList: home.trending),
                onTap: () => context.push(RoutePaths.songWith(song.id)),
                onFavorite: () => Get.find<PlayerController>().toggleFavorite(song),
              ),
            );
          },
        ),
      ],
    );
  }
}