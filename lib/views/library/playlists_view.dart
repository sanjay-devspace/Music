import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/models/playlist_model.dart';
import 'package:tunehive/services/music/music_service.dart';
import 'package:tunehive/services/music/mock_data.dart';
import 'package:tunehive/widgets/editorial_card.dart';
import 'package:tunehive/widgets/error_state.dart';
import 'package:tunehive/widgets/empty_state.dart';
import 'package:tunehive/widgets/skeleton_loader.dart';

class PlaylistsView extends StatefulWidget {
  const PlaylistsView({super.key});

  @override
  State<PlaylistsView> createState() => _PlaylistsViewState();
}

class _PlaylistsViewState extends State<PlaylistsView> {
  static const String _fallbackArtwork =
      'https://picsum.photos/seed/tunehive-playlists/600/600';

  final MusicService _musicService = Get.find<MusicService>();
  List<PlaylistModel> _playlists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _musicService.getEditorialPlaylists(),
        _musicService.getDailyMixes(),
      ]);

      final editorial = results[0];
      final dailyMixes = results[1];
      final mock = MockData.playlists;

      final all = <PlaylistModel>{};
      all.addAll(editorial);
      all.addAll(dailyMixes);
      all.addAll(mock);

      if (mounted) {
        setState(() {
          _playlists = all.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load playlists.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TuneHiveColors.charcoalBlack,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'Playlists',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: TuneHiveColors.coolWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingGrid();
    }
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _loadPlaylists);
    }
    if (_playlists.isEmpty) {
      return const EmptyState(
        icon: Icons.queue_music_rounded,
        title: 'No playlists',
        message: 'Create a playlist to get started.',
      );
    }
    return _buildPlaylistGrid();
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumns(constraints.maxWidth);
        final cardWidth =
            (constraints.maxWidth - AppSpacing.md * (columns + 1)) / columns;
        return Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: List.generate(
              columns * 2,
              (index) => Shimmer(
                child: ShimmerBox(
                  width: cardWidth,
                  height: 220,
                  borderRadius: AppRadius.lg,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylistGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumns(constraints.maxWidth);
        final cardWidth =
            (constraints.maxWidth - AppSpacing.md * (columns + 1)) / columns;
        final items = [
          _buildNewPlaylistCard(context, cardWidth),
          ...List.generate(
            _playlists.length,
            (index) => FadeSlide(
              delay: Duration(milliseconds: index * 40),
              child: EditorialCard(
                title: _playlists[index].name,
                description: _playlists[index].description,
                artworkUrl: _playlists[index].coverUrl ?? _fallbackArtwork,
                width: cardWidth,
                height: 220,
                onTap: () =>
                    context.go(RoutePaths.playlistWith(_playlists[index].id)),
              ),
            ),
          ),
        ];
        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: items,
          ),
        );
      },
    );
  }

  Widget _buildNewPlaylistCard(BuildContext context, double cardWidth) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist creation coming soon')),
        );
      },
      child: Container(
        width: cardWidth,
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(
            color: TuneHiveColors.elevatedSurface,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 36, color: TuneHiveColors.mutedText),
            SizedBox(height: AppSpacing.sm),
            Text(
              'New Playlist',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TuneHiveColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getColumns(double width) {
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }
}
