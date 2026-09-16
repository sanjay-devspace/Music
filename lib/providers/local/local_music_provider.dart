import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/music_provider.dart';
import 'package:tunehive/providers/mock/mock_music_provider.dart';
import 'package:tunehive/services/music/mock_data.dart';

/// Provider backed by the user's on-device library.
///
/// At present it wraps the bundled development catalog; a real
/// implementation would read scan results from a media store index.
class LocalMusicProvider extends MusicProvider {
  LocalMusicProvider();

  @override
  String get id => localProviderId;

  @override
  String get displayName => 'Device Library';

  @override
  bool get isConfigured => true;

  @override
  Future<List<SongModel>> searchSongs(String query) async =>
      MockMusicProvider.aliasSearchSongs(query);

  @override
  Future<List<AlbumModel>> searchAlbums(String query) async =>
      MockMusicProvider.aliasSearchAlbums(query);

  @override
  Future<List<ArtistModel>> searchArtists(String query) async =>
      MockMusicProvider.aliasSearchArtists(query);

  @override
  Future<List<SongModel>> getTrendingSongs() async =>
      MockData.songs.take(4).toList();

  @override
  Future<List<SongModel>> getPopularSongs() async =>
      MockData.songs.take(5).toList();

  @override
  Future<List<SongModel>> getRecommendedForYou() async =>
      MockData.songs.reversed.take(4).toList();

  @override
  Future<List<SongModel>> getRecentlyPlayed() async =>
      MockData.songs.take(3).toList();

  @override
  Future<List<AlbumModel>> getNewAlbums() async =>
      MockData.albums.take(4).toList();

  @override
  Future<List<ArtistModel>> getPopularArtists() async =>
      MockData.artists.take(4).toList();

  @override
  Future<List<GenreModel>> getCategories() async => MockData.genres;

  @override
  Future<SongModel?> getSong(String id) async => MockData.song(id);

  @override
  Future<AlbumModel?> getAlbum(String id) async {
    final album = MockData.album(id);
    return AlbumModel(
      id: album.id,
      name: album.name,
      artistName: album.artistName,
      artworkUrl: album.artworkUrl,
      releaseYear: album.releaseYear,
      totalTracks: album.totalTracks,
      songs: MockData.songs.where((s) => s.albumId == album.id).toList(),
    );
  }

  @override
  Future<ArtistModel?> getArtist(String id) async => MockData.artist(id);

  @override
  Future<String?> getStreamUrl(String songId) async => null;
}