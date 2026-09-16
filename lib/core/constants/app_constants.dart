/// Global application constants shared across TUNEHIVE.
///
/// Kept intentionally free of secrets — any environment-specific credential
/// must live in a `.env` file and be loaded through `AppConfig`.
class AppConstants {
  AppConstants._();

  static const String appName = 'TUNEHIVE';
  static const String appTagline = 'Start Your Sonic Journey';

  /// Maximum horizontal width of content before it is centered.
  static const double maxContentWidth = 1440;

  /// Maximum width used by windowed app shells (desktop/web).
  static const double maxAppWidth = 1920;

  /// Cache expiration for home/recommendation metadata (24h).
  static const Duration homeCacheDuration = Duration(hours: 24);

  /// Cache expiration for album/artist metadata (7 days).
  static const Duration metadataCacheDuration = Duration(days: 7);

  /// Debounce delay used by the search screen.
  static const Duration searchDebounceDelay = Duration(milliseconds: 350);

  /// Minimum artist/brand code prefix used by placeholder artwork.
  static const String brandId = 'TUNEHIVE';

  /// Network request timeout.
  static const Duration networkTimeout = Duration(seconds: 20);
}

/// Entry point for reading environment variables safely.
class AppConfig {
  AppConfig._();

  static const String _envFile = String.fromEnvironment(
    'TUNEHIVE_ENV_FILE',
    defaultValue: '.env',
  );

  /// The env file key / path (dash-encoded in the binary, readable in debug).
  static String get envFile => _envFile;

  /// Whether a production backend has been wired up.
  static const bool isBackendConfigured = String.fromEnvironment(
        'SUPABASE_URL',
      ) != '' ||
      String.fromEnvironment('SUPABASE_URL', defaultValue: '') != '';

  static String get supabaseUrl =>
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String get supabaseAnonKey =>
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static String get spotifyClientId =>
      String.fromEnvironment('SPOTIFY_CLIENT_ID', defaultValue: '');
  static String get spotifyRedirectUri =>
      String.fromEnvironment('SPOTIFY_REDIRECT_URI', defaultValue: 'tunehive://callback');
}