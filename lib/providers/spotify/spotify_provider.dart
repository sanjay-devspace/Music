import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/music_provider.dart';
import 'package:tunehive/providers/spotify/spotify_api.dart';
import 'package:tunehive/providers/spotify/spotify_auth_service.dart';
import 'package:tunehive/providers/spotify/spotify_mapper.dart';

/// Spotify-backed [MusicProvider].
///
/// Isolated from the rest of the app: the UI only ever sees domain models.
class SpotifyProvider implements MusicProvider {
  SpotifyProvider({
    SpotifyApi? api,
    SpotifyAuthService auth = const SpotifyAuthService(),
  })  : _api = api ?? SpotifyApi(auth: auth),
        _auth = auth,
        _mapper = const SpotifyMapper();

  final SpotifyApi _api;
  final SpotifyAuthService _auth;
  final SpotifyMapper _mapper;

  @override
  String get id => spotifyProviderId;

  @override
  String get displayName => 'Spotify';

  @override
  bool get isConfigured => _auth.isConfigured;

  @override
  Future<List<SongModel>> searchSongs(String query) async {
    final raw = await _api.search(query, 'track');
    return raw.map(_mapper.song).toList();
  }

  @override
  Future<List<AlbumModel>> searchAlbums(String query) async {
    final raw = await _api.search(query, 'album');
    return raw.map(_mapper.album).toList();
  }

  @override
  Future<List<ArtistModel>> searchArtists(String query) async {
    final raw = await _api.search(query, 'artist');
    return raw.map(_mapper.artist).toList();
  }

  @override
  Future<List<SongModel>> getTrendingSongs() async {
    final raw = await _api.topTracks(limit: 20);
    return raw.map(_mapper.song).toList();
  }

  @override
  Future<List<SongModel>> getPopularSongs() async {
    return getTrendingSongs();
  }

  @override
  Future<List<SongModel>> getRecommendedForYou() async {
    final raw = await _api.topTracks(limit: 20);
    return raw.map(_mapper.song).toList();
  }

  @override
  Future<List<SongModel>> getRecentlyPlayed() async {
    final raw = await _api.topTracks(limit: 10);
    return raw.map(_mapper.song).toList();
  }

  @override
  Future<List<AlbumModel>> getNewAlbums() async {
    final raw = await _api.newReleases(limit: 20);
    return raw.map(_mapper.album).toList();
  }

  @override
  Future<List<ArtistModel>> getPopularArtists() async {
    final raw = await _api.search('year:2025', 'artist');
    return raw.map(_mapper.artist).toList();
  }

  @override
  Future<List<GenreModel>> getCategories() async => const [];

  @override
  Future<SongModel?> getSong(String id) async {
    final raw = await _api.track(_stripPrefix(id));
    return raw == null ? null : _mapper.song(raw);
  }

  @override
  Future<AlbumModel?> getAlbum(String id) async {
    final raw = await _api.album(_stripPrefix(id));
    return raw == null ? null : _mapper.album(raw);
  }

  @override
  Future<ArtistModel?> getArtist(String id) async {
    final raw = await _api.artist(_stripPrefix(id));
    return raw == null ? null : _mapper.artist(raw);
  }

  @override
  Future<String?> getStreamUrl(String songId) async {
    // Stream URLs are resolved through the Spotify Playback integration
    // (requires the SDK). The provider abstraction reserves the method so
    // the player can request playable media per song.
    return null;
  }

  static String _stripPrefix(String id) =>
      id.replaceFirst('spotify:', '').replaceFirst(RegExp('^spotify:track:'), '');
}