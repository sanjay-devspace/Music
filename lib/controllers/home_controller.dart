import 'package:get/get.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/mood_model.dart';
import 'package:tunehive/models/playlist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/music_service.dart';

import 'player_controller.dart';

/// Home screen controller — loads every section on the premium Home feed and
/// exposes granular, observable state per section so the view rebuilds only
/// what changed.
class HomeController extends GetxController {
  HomeController(this._musicService);

  final MusicService _musicService;
  late final PlayerController _player;

  final RxString userName = 'ANTONY DAS'.obs;
  final RxnString errorMessage = RxnString(null);
  final RxBool isLoading = true.obs;

  // ---- Sections -----------------------------------------------------------
  final RxList<MoodModel> moods = <MoodModel>[].obs;
  final RxList<HeroFeature> heroFeatures = <HeroFeature>[].obs;
  final RxList<SongModel> trending = <SongModel>[].obs;
  final RxList<PlaylistModel> recommendedPlaylists = <PlaylistModel>[].obs;
  final RxList<PlaylistModel> dailyMixes = <PlaylistModel>[].obs;
  final RxList<ArtistModel> popularArtists = <ArtistModel>[].obs;
  final RxList<SongModel> recentlyPlayed = <SongModel>[].obs;
  final RxList<AlbumModel> newAlbums = <AlbumModel>[].obs;

  // ---- Mood selection ------------------------------------------------------
  final RxnString selectedMoodId = RxnString(null);
  final RxList<SongModel> moodSongs = <SongModel>[].obs;

  /// Editorial hero shown first. Rotates if multiple features exist.
  HeroFeature get activeHero {
    final list = heroFeatures;
    return list.isEmpty
        ? HeroFeature(
            id: 'hero-fallback',
            title: 'TUNEHIVE ORIGINALS',
            subtitle: 'Fresh music chosen for you.',
            description: 'Hand-picked tracks from artists on the rise.',
            artworkUrl: 'https://picsum.photos/seed/hero-fallback/600/600',
          )
        : list[0];
  }

  /// Personalized greeting based on local time.
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void onInit() {
    super.onInit();
    _player = Get.find<PlayerController>();
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _musicService.getMoods(),
        _musicService.getHeroFeatures(),
        _musicService.getTrendingSongs(),
        _musicService.getEditorialPlaylists(),
        _musicService.getDailyMixes(),
        _musicService.getPopularArtists(),
        _musicService.getRecentlyPlayed(),
        _musicService.getNewAlbums(),
      ]);
      moods.value = results[0] as List<MoodModel>;
      heroFeatures.value = results[1] as List<HeroFeature>;
      trending.value = results[2] as List<SongModel>;
      recommendedPlaylists.value = results[3] as List<PlaylistModel>;
      dailyMixes.value = results[4] as List<PlaylistModel>;
      popularArtists.value = results[5] as List<ArtistModel>;
      recentlyPlayed.value = results[6] as List<SongModel>;
      newAlbums.value = results[7] as List<AlbumModel>;
    } catch (_) {
      errorMessage.value = 'Unable to load music.\nTry again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHome() async => load();

  Future<void> selectMood(String id) async {
    if (selectedMoodId.value == id) {
      selectedMoodId.value = null;
      moodSongs.clear();
      return;
    }
    selectedMoodId.value = id;
    try {
      final songs = await _musicService.getSongsForMood(id);
      moodSongs.value = songs;
    } catch (_) {
      moodSongs.clear();
    }
  }

  Future<void> playSong(SongModel song, {List<SongModel>? fromList}) =>
      _player.play(song, fromList: fromList);
}