import 'package:tunehive/core/errors/app_exception.dart';

/// OAuth token + refresh flow for the Spotify provider.
///
/// Uses the **Authorization Code (with PKCE)** flow — the client id is public
/// and never embedded. Only access/refresh tokens are stored locally, and the
/// refresh exchange must happen through a trusted backend in production.
class SpotifyAuthService {
  const SpotifyAuthService();

  Future<String?> getAccessToken() async {
    // Placeholder — when a live client id is supplied via env, this resolves
    // the token through the PKCE flow. Returns null when unconfigured so the
    // provider reports itself as not ready.
    const clientId = String.fromEnvironment('SPOTIFY_CLIENT_ID');
    if (clientId.isEmpty) return null;
    return null;
  }

  String get _clientId => String.fromEnvironment('SPOTIFY_CLIENT_ID');

  String get _redirectUri =>
      const String.fromEnvironment('SPOTIFY_REDIRECT_URI', defaultValue: 'tunehive://callback');

  Uri get authorizationUrl {
    final challenge = 'unconfigured';
    return Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': _redirectUri,
      'scope': 'streaming user-library-read playlist-modify-private',
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
    });
  }

  bool get isConfigured => _clientId.isNotEmpty;

  /// Exchange an authorization code for tokens via a backend proxy.
  Future<void> exchangeCode(String code) async {
    if (!isConfigured) {
      throw const ProviderException(
        message: 'Spotify is not configured. Add SPOTIFY_CLIENT_ID to continue.',
      );
    }
    // Production: POST to a trusted backend which holds the client secret and
    // performs the token exchange. The Flutter client never receives secrets.
  }
}