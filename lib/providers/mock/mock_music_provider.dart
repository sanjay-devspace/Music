import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/music_provider.dart';
import 'package:tunehive/services/music/mock_data.dart';

/// Development provider serving [MockData].
///
/// Implements the same [MusicProvider] contract as live providers so the UI
/// is identical regardless of the backing catalog.
class MockMusicProvider implements MusicProvider {
  const MockMusicProvider();

  @override
  String get id => mockProviderId;

  @override
  String get displayName => 'Demo Library';

  @override
  bool get isConfigured => true;

  /// Shared search used by the mock provider (and local provider).
  static List<SongModel> aliasSearchSongs(String query) {
    if (query.isEmpty) return const [];
    return MockData.songs
        .where((s) => _matches(query, s.title) || _matches(query, s.artistName))
        .take(20)
        .toList();
  }

  static List<AlbumModel> aliasSearchAlbums(String query) {
    if (query.isEmpty) return const [];
    return MockData.albums
        .where((a) => _matches(query, a.name) || _matches(query, a.artistName))
        .take(10)
        .toList();
  }

  static List<ArtistModel> aliasSearchArtists(String query) {
    if (query.isEmpty) return const [];
    return MockData.artists
        .where((a) => _matches(query, a.name))
        .take(10)
        .toList();
  }

  @override
  Future<List<SongModel>> searchSongs(String query) async =>
      aliasSearchSongs(query);

  @override
  Future<List<AlbumModel>> searchAlbums(String query) async {
    if (query.isEmpty) return const [];
    return MockData.albums
        .where((a) => _matches(query, a.name) || _matches(query, a.artistName))
        .take(10)
        .toList();
  }

  @override
  Future<List<ArtistModel>> searchArtists(String query) async {
    if (query.isEmpty) return const [];
    return MockData.artists
        .where((a) => _matches(query, a.name))
        .take(10)
        .toList();
  }

  @override
  Future<List<SongModel>> getTrendingSongs() async =>
      [MockData.songs[3], MockData.songs[6], MockData.songs[0], MockData.songs[7], MockData.songs[4]];

  @override
  Future<List<SongModel>> getPopularSongs() async =>
      [MockData.songs[0], MockData.songs[3], MockData.songs[6], MockData.songs[5], MockData.songs[1]];

  @override
  Future<List<SongModel>> getRecommendedForYou() async =>
      MockData.recommendations.first.songs;

  @override
  Future<List<SongModel>> getRecentlyPlayed() async =>
      [MockData.songs[4], MockData.songs[2], MockData.songs[9], MockData.songs[11]];

  @override
  Future<List<AlbumModel>> getNewAlbums() async => [
        MockData.albums[3],
        MockData.albums[6],
        MockData.albums[0],
        MockData.albums[4],
      ];

  @override
  Future<List<ArtistModel>> getPopularArtists() async =>
      [MockData.artists[3], MockData.artists[0], MockData.artists[6], MockData.artists[4]];

  @override
  Future<List<GenreModel>> getCategories() async => MockData.genres;

  @override
  Future<SongModel?> getSong(String id) async {
    try {
      return MockData.songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AlbumModel?> getAlbum(String id) async {
    try {
      final album = MockData.albums.firstWhere((a) => a.id == id);
      return AlbumModel(
        id: album.id,
        name: album.name,
        artistName: album.artistName,
        artistId: album.artistId,
        artworkUrl: album.artworkUrl,
        releaseYear: album.releaseYear,
        totalTracks: album.totalTracks,
        songs: MockData.songs
            .where((s) => s.albumId == album.id)
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ArtistModel?> getArtist(String id) async {
    try {
      final artist = MockData.artists.firstWhere((a) => a.id == id);
      return ArtistModel(
        id: artist.id,
        name: artist.name,
        avatarUrl: artist.avatarUrl,
        genres: artist.genres,
        followers: artist.followers,
        popularity: artist.popularity,
        isFollowing: artist.isFollowing,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getStreamUrl(String songId) async => null;

  static bool _matches(String query, String value) =>
      value.toLowerCase().contains(query.toLowerCase());
}