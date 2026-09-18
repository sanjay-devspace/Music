import 'dart:async';

import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/core/storage/storage_service.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/mood_model.dart';
import 'package:tunehive/models/playlist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/apple_music/apple_music_provider.dart';
import 'package:tunehive/providers/jiosaavn/jiosaavn_provider.dart';
import 'package:tunehive/providers/local/local_music_provider.dart';
import 'package:tunehive/providers/mock/mock_music_provider.dart';
import 'package:tunehive/providers/music_provider.dart';
import 'package:tunehive/providers/spotify/spotify_provider.dart';

/// Orchestrates the active music provider for the rest of the app.
///
/// Controllers talk to [MusicService], never directly to any provider. This
/// class owns provider selection, fallback logic and metadata caching.
class MusicService {
  MusicService({
    StorageService? storage,
    List<MusicProvider>? providers,
  }) : _storage = storage ?? _NoopStorage(),
       _activeId = 'jiosaavn' {
    _providers = providers ??
        <MusicProvider>[
          JioSaavnProvider(),
          MockMusicProvider(),
          LocalMusicProvider(),
          SpotifyProvider(),
          AppleMusicProvider(),
        ];
    _active = _providers.firstWhere(
      (p) => p.id == _activeId,
      orElse: () => _providers.first,
    );
    _loadPersistedSelection();
  }

  final StorageService _storage;
  late MusicProvider _active;
  String _activeId;
  late List<MusicProvider> _providers;

  // ---- Provider registry --------------------------------------------------
  List<MusicProvider> get providers => List.unmodifiable(_providers);

  MusicProvider get activeProvider => _active;

  String get activeProviderId => _active.id;

  MusicProvider providerFor(String id) => _providers.firstWhere(
        (p) => p.id == id,
        orElse: () => _providers.first,
      );

  Future<void> selectProvider(String id) async {
    _active = providerFor(id);
    _activeId = id;
    await _storage.setString('active_music_provider', id);
  }

  void _loadPersistedSelection() {
    try {
      final persisted = _storage.getString('active_music_provider');
      if (persisted == null) return;
      _active = providerFor(persisted);
      _activeId = persisted;
    } catch (_) {
      // Storage unavailable during startup — fall back gracefully.
    }
  }

  final Map<String, SongModel> _songCache = {};

  void _cacheSongs(List<SongModel> songs) {
    for (final s in songs) {
      _songCache[s.id] = s;
    }
  }

  // ---- Delegated provider calls ------------------------------------------
  Future<List<SongModel>> searchSongs(String query) async {
    final res = await _guard(() => _active.searchSongs(query));
    _cacheSongs(res);
    return res;
  }

  Future<List<AlbumModel>> searchAlbums(String query) async =>
      _guard(() => _active.searchAlbums(query));

  Future<List<ArtistModel>> searchArtists(String query) async =>
      _guard(() => _active.searchArtists(query));

  Future<List<SongModel>> getTrendingSongs() async {
    final res = await _guard(() => _active.getTrendingSongs());
    _cacheSongs(res);
    return res;
  }

  Future<List<SongModel>> getPopularSongs() async {
    final res = await _guard(() => _active.getPopularSongs());
    _cacheSongs(res);
    return res;
  }

  Future<List<SongModel>> getRecommendedForYou() async {
    final res = await _guard(() => _active.getRecommendedForYou());
    _cacheSongs(res);
    return res;
  }

  Future<List<SongModel>> getRecentlyPlayed() async {
    final res = await _guard(() => _active.getRecentlyPlayed());
    _cacheSongs(res);
    return res;
  }

  Future<List<AlbumModel>> getNewAlbums() async =>
      _guard(() => _active.getNewAlbums());

  Future<List<ArtistModel>> getPopularArtists() async =>
      _guard(() => _active.getPopularArtists());

  Future<List<GenreModel>> getCategories() async =>
      _guard(() => _active.getCategories());

  Future<List<MoodModel>> getMoods() async => _guard(
        () => _active.getMoods(),
      );

  Future<List<HeroFeature>> getHeroFeatures() async => _guard(
        () => _active.getHeroFeatures(),
      );

  Future<List<PlaylistModel>> getDailyMixes() async => _guard(
        () => _active.getDailyMixes(),
      );

  Future<List<PlaylistModel>> getEditorialPlaylists() async => _guard(
        () => _active.getEditorialPlaylists(),
      );

  Future<List<String>> getTrendingSearches() async => _guard(
        () => _active.getTrendingSearches(),
      );

  Future<List<SongModel>> getSongsForMood(String moodId) async {
    final res = await _guard(() => _active.getSongsForMood(moodId));
    _cacheSongs(res);
    return res;
  }

  Future<SongModel?> getSong(String id) async {
    if (_songCache.containsKey(id)) {
      return _songCache[id];
    }
    final song = await _guard(() => _active.getSong(id));
    if (song != null) {
      _songCache[id] = song;
    }
    return song;
  }

  Future<AlbumModel?> getAlbum(String id) async =>
      _guard(() => _active.getAlbum(id));

  Future<ArtistModel?> getArtist(String id) async =>
      _guard(() => _active.getArtist(id));

  Future<String?> getStreamUrl(String songId) async {
    if (_songCache.containsKey(songId)) {
      final cachedUrl = _songCache[songId]!.audioUrl;
      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        return cachedUrl;
      }
    }
    return _guard(() => _active.getStreamUrl(songId));
  }

  // ---- Error mapping -------------------------------------------------------
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AppException {
      rethrow;
    } catch (e) {
      throw wrapError(e);
    }
  }
}

class _NoopStorage extends StorageService {
  _NoopStorage() : super.noop();
}