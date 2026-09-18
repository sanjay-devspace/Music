import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/core/network/api_client.dart';

/// Authentication service using the free WolfXSpotify API endpoint.
///
/// Fetches a dynamic token from `GET /api/token` which works completely
/// anonymously. No client IDs, secrets, or user login required.
class SpotifyAuthService {
  SpotifyAuthService({http.Client? client}) : _client = ApiClient(client: client);

  final ApiClient _client;
  String? _cachedToken;
  DateTime? _tokenExpiry;

  Future<String?> getAccessToken() async {
    // If we have a valid cached token, return it
    if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken;
    }

    try {
      final response = await _client.get('https://spotify.xwolf.space/api/token');
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          _cachedToken = data['access_token'] as String?;
          // The token is valid for a short time (usually 30 minutes for wolfxspotify)
          // We'll cache it for 25 minutes to be safe.
          _tokenExpiry = DateTime.now().add(const Duration(minutes: 25));
          return _cachedToken;
        }
      }
    } catch (e) {
      throw ProviderException(
        message: 'Failed to fetch anonymous Spotify token: $e',
      );
    }
    return null;
  }

  /// Since this is an anonymous API, it is always considered configured.
  bool get isConfigured => true;
}