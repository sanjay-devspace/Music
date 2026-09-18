import 'package:http/http.dart' as http;

import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/core/network/api_client.dart';
import 'package:tunehive/core/network/network_response.dart';
import 'package:tunehive/providers/spotify/spotify_auth_service.dart';

/// Raw Spotify Web API client using WolfXSpotify.
///
/// Returns Spotify-shaped JSON maps. All requests require a valid bearer token
/// resolved by [SpotifyAuthService].
class SpotifyApi {
  SpotifyApi({
    http.Client? client,
    SpotifyAuthService? auth,
  })  : _client = ApiClient(client: client),
        _auth = auth ?? SpotifyAuthService();

  static const String baseUrl = 'https://spotify.xwolf.space';

  final ApiClient _client;
  final SpotifyAuthService _auth;

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const ProviderException(
        message: 'Could not acquire anonymous token.',
      );
    }
    return {'Authorization': 'Bearer $token'};
  }

  Future<List<Map<String, dynamic>>> _items(
    String endpoint,
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = '$baseUrl$path';
    final NetworkResponse<Map<String, dynamic>> response =
        await _client.get(uri, query: query, headers: await _headers());
    if (response.isFailure) {
      throw ProviderException(message: 'Spotify request failed (${response.statusCode}).');
    }
    final items = response.data?[endpoint];
    if (items is List) {
      return items
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  /// `GET /api/search`
  Future<List<Map<String, dynamic>>> search(
    String query,
    String type, {
    int limit = 20,
  }) async {
    return _items(
      '${type}s',
      '/api/search',
      query: {'q': query, 'type': type, 'limit': '$limit'},
    );
  }

  /// `GET /api/search` with new releases filter (mocking browse)
  Future<List<Map<String, dynamic>>> newReleases({int limit = 20}) async {
    // Wolf doesn't have /browse/new-releases so we mock it via search
    return _items('albums', '/api/search', query: {'q': 'tag:new', 'type': 'album', 'limit': '$limit'});
  }

  /// `GET /api/playlist/37i9dQZF1DXcBWIGoYBM5M` — Today's Top Hits
  Future<List<Map<String, dynamic>>> topTracks({int limit = 20}) async {
    final uri = '$baseUrl/api/playlist/37i9dQZF1DXcBWIGoYBM5M';
    final response = await _client.get(uri, headers: await _headers());
    if (response.isFailure) return const [];
    
    final data = response.data;
    if (data != null && data['tracks'] != null && data['tracks']['items'] != null) {
      final items = data['tracks']['items'] as List;
      return items.whereType<Map>().map((e) {
        if (e['track'] != null) {
          return Map<String, dynamic>.from(e['track']);
        }
        return Map<String, dynamic>.from(e);
      }).take(limit).toList();
    }
    return const [];
  }

  /// `GET /api/track/{id}`
  Future<Map<String, dynamic>?> track(String id) async {
    final uri = '$baseUrl/api/track/$id';
    final response = await _client.get(uri, headers: await _headers());
    return response.isSuccess ? response.data : null;
  }

  /// `GET /api/album/{id}`
  Future<Map<String, dynamic>?> album(String id) async {
    final uri = '$baseUrl/api/album/$id';
    final response = await _client.get(uri, headers: await _headers());
    return response.isSuccess ? response.data : null;
  }

  /// `GET /api/artist/{id}`
  Future<Map<String, dynamic>?> artist(String id) async {
    final uri = '$baseUrl/api/artist/$id';
    final response = await _client.get(uri, headers: await _headers());
    return response.isSuccess ? response.data : null;
  }
}