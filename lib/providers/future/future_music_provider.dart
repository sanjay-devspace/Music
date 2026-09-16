import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/music_provider.dart';

/// Extension point for future providers (e.g. YouTube Music, Deezer).
///
/// Implements the same contract. Until wired to a live backend it behaves as
/// an unconfigured provider so the app never breaks if selected.
class FutureMusicProvider extends MusicProvider {
  FutureMusicProvider({this.futureId = 'future'});

  final String futureId;

  @override
  String get id => futureId;

  @override
  String get displayName => 'Future Catalog';

  @override
  bool get isConfigured => false;

  @override
  Future<List<SongModel>> searchSongs(String query) async => const [];

  @override
  Future<List<AlbumModel>> searchAlbums(String query) async => const [];

  @override
  Future<List<ArtistModel>> searchArtists(String query) async => const [];

  @override
  Future<List<SongModel>> getTrendingSongs() async => const [];

  @override
  Future<List<SongModel>> getPopularSongs() async => const [];

  @override
  Future<List<SongModel>> getRecommendedForYou() async => const [];

  @override
  Future<List<SongModel>> getRecentlyPlayed() async => const [];

  @override
  Future<List<AlbumModel>> getNewAlbums() async => const [];

  @override
  Future<List<ArtistModel>> getPopularArtists() async => const [];

  @override
  Future<List<GenreModel>> getCategories() async => const [];

  @override
  Future<SongModel?> getSong(String id) async => null;

  @override
  Future<AlbumModel?> getAlbum(String id) async => null;

  @override
  Future<ArtistModel?> getArtist(String id) async => null;

  @override
  Future<String?> getStreamUrl(String songId) async => null;
}