import 'package:get/get.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/music_service.dart';

import 'player_controller.dart';

/// Library screen controller — tracks user-owned collections (liked songs,
/// playlists, recently played). For the first build these are populated from
/// the mock provider catalog.
class LibraryController extends GetxController {
  LibraryController(this._musicService);

  final MusicService _musicService;
  late final PlayerController _player;

  final RxList<SongModel> likedSongs = <SongModel>[].obs;
  final RxList<SongModel> recentlyPlayed = <SongModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _player = Get.find<PlayerController>();
    load();
    // Sync liked songs whenever the player's favorites change.
    ever(_player.likedIds, (_) => _syncLiked());
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _musicService.getRecentlyPlayed(),
      ]);
      recentlyPlayed.value = results[0];
    } catch (_) {
      // Library shows empty state — no user-facing error needed.
    } finally {
      isLoading.value = false;
    }
    _syncLiked();
  }

  void _syncLiked() {
    final allSongs = [
      ..._musicService.activeProvider.isConfigured ? <SongModel>[] : <SongModel>[],
      ...recentlyPlayed,
    ];
    // For the first build, derive liked songs from the player likedIds set.
    // In production this would persist to Supabase.
    final liked = <SongModel>[];
    for (final song in allSongs) {
      if (_player.isLiked(song.id)) liked.add(song);
    }
    likedSongs.value = liked;
  }

  Future<void> refreshLibrary() => load();

  Future<void> playSong(SongModel song, {List<SongModel>? fromList}) =>
      _player.play(song, fromList: fromList);
}