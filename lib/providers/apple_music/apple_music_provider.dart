import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/apple_music/apple_music_api.dart';
import 'package:tunehive/providers/apple_music/apple_music_mapper.dart';
import 'package:tunehive/providers/music_provider.dart';

/// Apple Music backed [MusicProvider].
class AppleMusicProvider implements MusicProvider {
  AppleMusicProvider({AppleMusicApi? api})
      : _api = api ?? AppleMusicApi();

  final AppleMusicApi _api;
  static const _mapper = AppleMusicMapper();

  @override
  String get id => appleMusicProviderId;

  @override
  String get displayName => 'Apple Music';

  @override
  bool get isConfigured => _api.hasToken;

  @override
  Future<List<SongModel>> searchSongs(String query) async {
    final raw = await _api.catalogSongs(query);
    return raw.map(_mapper.song).toList();
  }

  @override
  Future<List<AlbumModel>> searchAlbums(String query) async {
    final raw = await _api._data('/catalog/us/search',
        query: {'term': query, 'types': 'albums', 'limit': '20'});
    return raw.map(_mapper.album).toList();
  }

  @override
  Future<List<ArtistModel>> searchArtists(String query) async {
    final raw = await _api._data('/catalog/us/search',
        query: {'term': query, 'types': 'artists', 'limit': '20'});
    return raw.map(_mapper.artist).toList();
  }

  @override
  Future<List<SongModel>> getTrendingSongs() async => const [];

  @override
  Future<List<SongModel>> getPopularSongs() async => const [];

  @override
  Future<List<SongModel>> getRecommendedForYou() async => const [];

  @override
  Future<List<SongModel>> getRecentlyPlayed() async => const [];

  @override
  Future<List<AlbumModel>> getNewAlbums() async {
    final raw = await _api.newReleases();
    return raw.map(_mapper.album).toList();
  }

  @override
  Future<List<ArtistModel>> getPopularArtists() async => const [];

  @override
  Future<List<GenreModel>> getCategories() async => const [];

  @override
  Future<SongModel?> getSong(String id) async {
    final raw = await _api.song(_stripPrefix(id));
    return raw == null ? null : _mapper.song(raw);
  }

  @override
  Future<AlbumModel?> getAlbum(String id) async => null;

  @override
  Future<ArtistModel?> getArtist(String id) async => null;

  @override
  Future<String?> getStreamUrl(String songId) async => null;

  static String _stripPrefix(String id) =>
      id.replaceFirst('apple:', '');
}