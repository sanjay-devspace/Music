import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/playlist_model.dart';
import 'package:tunehive/models/recommendation_model.dart';
import 'package:tunehive/models/song_model.dart';

/// Core contract every music provider (Spotify, Apple Music, Local, Mock)
/// must implement.
///
/// The rest of the application works only against this interface and the
/// internal models — never against provider-specific payloads. This keeps the
/// UI fully provider-independent.
abstract class MusicProvider {
  String get id;
  String get displayName;

  /// Whether this provider currently authorizes requests.
  bool get isConfigured;

  // ---- Search -----------------------------------------------------------
  Future<List<SongModel>> searchSongs(String query);
  Future<List<AlbumModel>> searchAlbums(String query);
  Future<List<ArtistModel>> searchArtists(String query);

  // ---- Discovery ----------------------------------------------------------
  Future<List<SongModel>> getTrendingSongs();
  Future<List<SongModel>> getPopularSongs();
  Future<List<SongModel>> getRecommendedForYou();
  Future<List<SongModel>> getRecentlyPlayed();
  Future<List<AlbumModel>> getNewAlbums();
  Future<List<ArtistModel>> getPopularArtists();
  Future<List<GenreModel>> getCategories();

  // ---- Details ------------------------------------------------------------
  Future<SongModel?> getSong(String id);
  Future<AlbumModel?> getAlbum(String id);
  Future<ArtistModel?> getArtist(String id);

  // ---- Playback (stream URLs) ---------------------------------------------
  Future<String?> getStreamUrl(String songId);
}

/// Identity of the fallback mock provider.
const String mockProviderId = 'mock';
const String localProviderId = 'local';
const String spotifyProviderId = 'spotify';
const String appleMusicProviderId = 'apple_music';