import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/core/network/api_client.dart';
import 'package:tunehive/core/network/network_response.dart';

/// Raw Apple Music / Musickit API client.
///
/// Returns Apple-shaped JSON payloads. Domain translation happens in
/// [AppleMusicMapper]. Tokens are development-signed identities issued by a
/// trusted backend, never generated inside the client.
class AppleMusicApi {
  AppleMusicApi({http.Client? client}) : _client = ApiClient(client: client);

  static const String baseUrl = 'https://api.music.apple.com/v1';

  final ApiClient _client;
  String? _devToken;

  void setDevToken(String token) => _devToken = token;

  bool get hasToken => _devToken != null && _devToken!.isNotEmpty;

  Map<String, String> _headers() {
    if (!hasToken) {
      throw const ProviderException(
        message: 'Apple Music is not connected. Please add a developer token.',
      );
    }
    return {'Authorization': 'Bearer $_devToken'};
  }

  Future<List<Map<String, dynamic>>> _data(String path,
      {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path')
        .replace(queryParameters: {...?query, 'limit': query?['limit'] ?? '20'});
    final response = await _client.get(uri.toString(), headers: _headers());
    if (response.isFailure) {
      throw ProviderException(
          message: 'Apple Music request failed (${response.statusCode}).');
    }
    final body = response.data?['data'];
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> search(String query) =>
      _data('/catalog/us/search', query: {'term': query});

  Future<List<Map<String, dynamic>>> catalogSongs(String term) =>
      _data('/catalog/us/search',
          query: {'term': term, 'types': 'songs', 'limit': '20'});

  Future<List<Map<String, dynamic>>> newReleases() =>
      _data('/catalog/us/new-releases');

  Future<Map<String, dynamic>?> song(String id) async {
    final uri = '$baseUrl/catalog/us/songs/$id';
    final response = await _client.get(uri, headers: _headers());
    final data = response.data?['data'];
    if (data is List && data.isNotEmpty) return Map<String, dynamic>.from(data.first);
    return null;
  }
}

/// Parses Apple Music response data containers into a consistent list of maps
/// so the mapper can be fed uniform payloads.
List<Map<String, dynamic>> extractAppleData(Object? body) {
  if (body is Map && body['data'] is List) {
    return body['data']
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}