import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/core/network/api_config.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/music_provider.dart';
import 'package:tunehive/providers/jiosaavn/jiosaavn_mapper.dart';

class JioSaavnProvider extends MusicProvider {
  JioSaavnProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  String get id => 'jiosaavn';

  @override
  String get displayName => 'JioSaavn';

  @override
  bool get isConfigured => true;

  Future<dynamic> _get(String path, {Map<String, String>? query}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ProviderException(message: 'JioSaavn API Error: ${response.statusCode}');
    } catch (e) {
      throw ProviderException(message: 'Network error: $e');
    }
  }

  @override
  Future<List<SongModel>> searchSongs(String query) async {
    final res = await _get('/result/', query: {'query': query});
    // The API usually returns search results, but sometimes it requires specific paths for songs
    // If it's a list directly or has a 'songs' key:
    List items = [];
    if (res is List) {
      items = res;
    } else if (res is Map && res['songs'] != null) {
      items = res['songs']['data'] ?? res['songs'] ?? [];
    } else if (res is Map && res['results'] != null) {
      items = res['results'];
    }
    
    return items.whereType<Map>().map((e) => JioSaavnMapper.song(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<List<AlbumModel>> searchAlbums(String query) async {
    // Basic implementation since universal search might return albums too
    return [];
  }

  @override
  Future<List<ArtistModel>> searchArtists(String query) async {
    return [];
  }

  @override
  Future<List<SongModel>> getTrendingSongs() async {
    // Since there's no native trending endpoint on the wrapper, mock it with a generic search
    return searchSongs('hits');
  }

  @override
  Future<List<SongModel>> getPopularSongs() async => getTrendingSongs();

  @override
  Future<List<SongModel>> getRecommendedForYou() async => searchSongs('top');

  @override
  Future<List<SongModel>> getRecentlyPlayed() async => searchSongs('new');

  @override
  Future<List<AlbumModel>> getNewAlbums() async => [];

  @override
  Future<List<ArtistModel>> getPopularArtists() async => [];

  @override
  Future<List<GenreModel>> getCategories() async => const [];

  @override
  Future<SongModel?> getSong(String id) async {
    final res = await _get('/song/', query: {'id': id});
    if (res is Map) return JioSaavnMapper.song(Map<String, dynamic>.from(res));
    if (res is List && res.isNotEmpty) return JioSaavnMapper.song(Map<String, dynamic>.from(res.first));
    return null;
  }

  @override
  Future<AlbumModel?> getAlbum(String id) async {
    final res = await _get('/album/', query: {'id': id});
    if (res is Map) return JioSaavnMapper.album(Map<String, dynamic>.from(res));
    return null;
  }

  @override
  Future<ArtistModel?> getArtist(String id) async {
    return null;
  }

  @override
  Future<String?> getStreamUrl(String songId) async {
    final song = await getSong(songId);
    return song?.audioUrl;
  }
}
