/// A connected external music provider (Spotify, Apple Music, etc.).
class MusicProviderModel {
  const MusicProviderModel({
    required this.id,
    required this.name,
    this.isConnected = false,
    this.isDefault = false,
    this.scopes = const [],
    this.connectedAt,
  });

  /// Stable identifier, e.g. `spotify`, `apple_music`, `local`.
  final String id;
  final String name;
  final bool isConnected;
  final bool isDefault;
  final List<String> scopes;
  final DateTime? connectedAt;

  MusicProviderModel copyWith({
    bool? isConnected,
    bool? isDefault,
    List<String>? scopes,
    DateTime? connectedAt,
  }) {
    return MusicProviderModel(
      id: id,
      name: name,
      isConnected: isConnected ?? this.isConnected,
      isDefault: isDefault ?? this.isDefault,
      scopes: scopes ?? this.scopes,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }
}

/// Standard available providers known to the app.
class MusicProviderCatalog {
  MusicProviderCatalog._();

  static const list = [
    MusicProviderModel(id: 'local', name: 'Device Library', scopes: ['library.read']),
    MusicProviderModel(id: 'spotify', name: 'Spotify', scopes: ['streaming', 'user-library-read', 'playlist-modify-private']),
    MusicProviderModel(id: 'apple_music', name: 'Apple Music', scopes: ['playback', 'library']),
  ];
}