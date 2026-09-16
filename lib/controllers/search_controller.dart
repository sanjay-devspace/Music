import 'dart:async';

import 'package:get/get.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/music_service.dart';

import 'player_controller.dart';

/// Controls the Search screen — debounced query, live suggestions and
/// paginated results.
class SearchController extends GetxController {
  SearchController(this._musicService);

  final MusicService _musicService;
  late final PlayerController _player;

  final RxString query = ''.obs;
  final RxBool hasQuery = false.obs;
  final RxBool isSearching = false.obs;
  final RxList<String> trendingSearches = <String>[].obs;
  final RxList<String> recentSearches = <String>[].obs;

  final RxList<SongModel> songResults = <SongModel>[].obs;
  final RxList<AlbumModel> albumResults = <AlbumModel>[].obs;
  final RxList<ArtistModel> artistResults = <ArtistModel>[].obs;
  final RxList<SongModel> suggestions = <SongModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _player = Get.find<PlayerController>();
    _loadSearchHints();
    debounce<String>(
      query,
      _onQueryChanged,
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> _loadSearchHints() async {
    try {
      final trending = await _musicService.getTrendingSearches();
      trendingSearches.value = trending;
    } catch (_) {}
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