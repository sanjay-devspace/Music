import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/widgets/artwork_image.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.songs,
    required this.height,
  });

  final List<SongModel> songs;
  final double height;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.songs.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isUserInteracting || !mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.songs.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _onUserInteraction(bool interacting) {
    _isUserInteracting = interacting;
    if (!interacting) {
      // Resume timer after a brief pause
      _timer?.cancel();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_isUserInteracting) {
          _startTimer();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.songs.isEmpty) return SizedBox(height: widget.height);

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onPanDown: (_) => _onUserInteraction(true),
            onPanCancel: () => _onUserInteraction(false),
            onPanEnd: (_) => _onUserInteraction(false),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.songs.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final song = widget.songs[index];
                return _HeroBannerCard(
                  song: song,
                  songs: widget.songs,
                );
              },
            ),
          ),
          // Pagination Indicators
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.songs.length, (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: isActive ? 18 : 6,
                  decoration: BoxDecoration(
                    color: isActive ? TuneHiveColors.electricBlue : TuneHiveColors.silverGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBannerCard extends StatelessWidget {
  const _HeroBannerCard({
    required this.song,
    required this.songs,
  });

  final SongModel song;
  final List<SongModel> songs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<PlayerController>().play(song, fromList: songs);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F000000), // Very subtle generic shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Artwork
              ArtworkImage(
                imageUrl: song.artworkUrl,
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
              // Dark Gradient Overlay for Readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      TuneHiveColors.charcoalBlack.withValues(alpha: 0.92),
                      TuneHiveColors.charcoalBlack.withValues(alpha: 0.65),
                      TuneHiveColors.charcoalBlack.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TuneHiveColors.electricBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TRENDING',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: TuneHiveColors.coolWhite,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: TuneHiveColors.coolWhite,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Artist
                    Text(
                      song.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: TuneHiveColors.secondaryText,
                      ),
                    ),
                    const Spacer(),
                    // Actions
                    Row(
                      children: [
                        // Play Button
                        ElevatedButton.icon(
                          onPressed: () => Get.find<PlayerController>().play(song, fromList: songs),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20, color: TuneHiveColors.coolWhite),
                          label: const Text(
                            'PLAY NOW',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: TuneHiveColors.coolWhite,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TuneHiveColors.electricBlue,
                            foregroundColor: TuneHiveColors.coolWhite,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Favorite
                        Obx(() {
                          final isLiked = Get.find<PlayerController>().isLiked(song.id);
                          return IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isLiked ? TuneHiveColors.electricBlue : TuneHiveColors.coolWhite,
                            ),
                            onPressed: () => Get.find<PlayerController>().toggleFavorite(song),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 24,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12), // Space for pagination dots
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
