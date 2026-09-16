import 'package:http/http.dart' as http;

import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/core/network/api_client.dart';
import 'package:tunehive/core/network/network_response.dart';
import 'package:tunehive/providers/spotify/spotify_auth_service.dart';

/// Raw Spotify Web API client.
///
/// Returns Spotify-shaped JSON maps. No domain models are built here — see
/// [SpotifyMapper]. All requests require a valid bearer token resolved by
/// [SpotifyAuthService].
class SpotifyApi {
  SpotifyApi({
    http.Client? client,
    this._auth = const SpotifyAuthService(),
  }) : _client = ApiClient(client: client);

  static const String baseUrl = 'https://api.spotify.com/v1';

  final ApiClient _client;
  final SpotifyAuthService _auth;

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const ProviderException(
        message: 'Please connect your Spotify account first.',
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

  /// `GET /search` with a typed result selector.
  Future<List<Map<String, dynamic>>> search(
    String query,
    String type, {
    int limit = 20,
  }) async {
    return _items(
      '${type}s',
      '/search',
      query: {'q': query, 'type': type, 'limit': '$limit'},
    );
  }

  /// `GET /browse/new-releases`
  Future<List<Map<String, dynamic>>> newReleases({int limit = 20}) async {
    return _items('albums', '/browse/new-releases', query: {'limit': '$limit'});
  }

  /// `GET /me/top/tracks` — popular tracks for the user.
  Future<List<Map<String, dynamic>>> topTracks({int limit = 20}) async {
    return _items('items', '/me/top/tracks', query: {'limit': '$limit'});
  }

  /// `GET /tracks/{id}`
  Future<Map<String, dynamic>?> track(String id) async {
    final uri = '$baseUrl/tracks/$id';
    final response = await _client.get(uri, headers: await _headers());
    return response.isSuccess ? response.data : null;
  }

  /// `GET /albums/{id}`
  Future<Map<String, dynamic>?> album(String id) async {
    final uri = '$baseUrl/albums/$id';
    final response = await _client.get(uri, headers: await _headers());
    return response.isSuccess ? response.data : null;
  }

  /// `GET /artists/{id}`
  Future<Map<String, dynamic>?> artist(String id) async {
    final uri = '$baseUrl/artists/$id';
    final response = await _client.get(uri, headers: await _headers());
    return response.isSuccess ? response.data : null;
  }
}