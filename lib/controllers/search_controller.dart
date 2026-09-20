import 'dart:async';

import 'package:get/get.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/services/music/music_service.dart';

import 'player_controller.dart';

/// Controls the Search screen — debounced query, live suggestions, 
/// paginated results, and rich Explore data (genres, languages, moods).
class SearchController extends GetxController {
  SearchController(this._musicService);

  final MusicService _musicService;
  late final PlayerController _player;

  // Search State
  final RxString query = ''.obs;
  final RxBool hasQuery = false.obs;
  final RxBool isSearching = false.obs;
  final RxList<String> trendingSearches = <String>[].obs;
  final RxList<String> recentSearches = <String>['Anirudh', 'A.R. Rahman', 'Telugu Hits', 'Romantic Songs'].obs;

  final RxList<SongModel> songResults = <SongModel>[].obs;
  final RxList<AlbumModel> albumResults = <AlbumModel>[].obs;
  final RxList<ArtistModel> artistResults = <ArtistModel>[].obs;
  final RxList<SongModel> suggestions = <SongModel>[].obs;

  // Explore State
  final RxList<GenreModel> exploreGenres = <GenreModel>[].obs;
  final RxList<ArtistModel> popularArtists = <ArtistModel>[].obs;
  final RxList<SongModel> trendingSongs = <SongModel>[].obs;
  final RxList<AlbumModel> newReleases = <AlbumModel>[].obs;
  final RxList<SongModel> recommendedSongs = <SongModel>[].obs;
  final RxBool isLoadingExplore = true.obs;

  // Preferences State
  final RxSet<String> selectedLanguages = <String>{}.obs;
  final RxSet<String> selectedMoods = <String>{}.obs;
  final RxSet<String> selectedGenres = <String>{}.obs;

  // Hardcoded Language Options
  final List<String> availableLanguages = const [
    'Tamil', 'Telugu', 'Hindi', 'Malayalam', 'Kannada', 'English', 'Bengali',
    'Marathi', 'Punjabi', 'Gujarati', 'Odia', 'Urdu', 'Assamese', 'Bhojpuri',
    'Rajasthani', 'Haryanvi', 'Konkani', 'Sanskrit', 'Nepali', 'Sinhala',
    'Arabic', 'Spanish', 'French', 'Korean', 'Japanese', 'Chinese',
    'Portuguese', 'German', 'Italian'
  ];

  // Hardcoded Mood Options
  final List<String> availableMoods = const [
    'Happy', 'Chill', 'Romantic', 'Sad', 'Energetic', 'Focus', 'Workout',
    'Party', 'Sleep', 'Peaceful', 'Motivation', 'Melancholy', 'Road Trip',
    'Devotional', 'Feel Good'
  ];

  @override
  void onInit() {
    super.onInit();
    _player = Get.find<PlayerController>();
    debounce<String>(
      query,
      _onQueryChanged,
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onReady() {
    super.onReady();
    _loadSearchHints();
    _loadExploreData();
  }

  Future<void> _loadSearchHints() async {
    try {
      final trending = await _musicService.getTrendingSearches();
      trendingSearches.value = trending.isNotEmpty 
          ? trending 
          : ['Anirudh', 'A.R. Rahman', 'Trending Now', 'Chill Tracks', 'Workout'];
    } catch (_) {}
  }

  Future<void> _loadExploreData() async {
    isLoadingExplore.value = true;
    try {
      final futures = await Future.wait([
        _musicService.getCategories(),
        _musicService.getPopularArtists(),
        _musicService.getTrendingSongs(),
        _musicService.getNewAlbums(),
        _musicService.getRecommendedForYou(),
      ]);

      exploreGenres.value = futures[0] as List<GenreModel>;
      popularArtists.value = futures[1] as List<ArtistModel>;
      trendingSongs.value = futures[2] as List<SongModel>;
      newReleases.value = futures[3] as List<AlbumModel>;
      recommendedSongs.value = futures[4] as List<SongModel>;
    } catch (_) {
    } finally {
      isLoadingExplore.value = false;
    }
  }

  // Multi-select actions
  void toggleLanguage(String lang) {
    if (selectedLanguages.contains(lang)) {
      selectedLanguages.remove(lang);
    } else {
      selectedLanguages.add(lang);
    }
  }

  void toggleMood(String mood) {
    if (selectedMoods.contains(mood)) {
      selectedMoods.remove(mood);
    } else {
      selectedMoods.add(mood);
    }
  }

  void toggleGenre(String genreId) {
    if (selectedGenres.contains(genreId)) {
      selectedGenres.remove(genreId);
    } else {
      selectedGenres.add(genreId);
    }
  }
  
  void clearRecentSearch(String search) {
    recentSearches.remove(search);
  }

  void onSearchChanged(String value) {
    query.value = value.trim();
    hasQuery.value = query.value.isNotEmpty;
    isSearching.value = hasQuery.value;
  }

  Future<void> _onQueryChanged(String _) async {
    final q = query.value;
    if (q.isEmpty) {
      songResults.clear();
      albumResults.clear();
      artistResults.clear();
      suggestions.clear();
      isSearching.value = false;
      return;
    }
    final results = await Future.wait([
      _musicService.searchSongs(q),
      _musicService.searchAlbums(q),
      _musicService.searchArtists(q),
    ]);
    songResults.value = results[0] as List<SongModel>;
    albumResults.value = results[1] as List<AlbumModel>;
    artistResults.value = results[2] as List<ArtistModel>;
    suggestions.value = (results[0] as List<SongModel>).take(4).toList();
    isSearching.value = false;
  }

  void clearSearch() {
    query.value = '';
    hasQuery.value = false;
    songResults.clear();
    albumResults.clear();
    artistResults.clear();
    suggestions.clear();
  }

  Future<void> playSong(SongModel song, {List<SongModel>? fromList}) =>
      _player.play(song, fromList: fromList);

  void toggleFavorite(SongModel song) => _player.toggleFavorite(song);
}