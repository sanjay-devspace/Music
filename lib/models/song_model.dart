/// A single playable track.
class SongModel {
  const SongModel({
    required this.id,
    required this.title,
    required this.artistName,
    this.artists = const [],
    this.artistId,
    this.albumName,
    this.albumId,
    this.artworkUrl,
    this.duration = Duration.zero,
    this.releaseDate,
    this.isExplicit = false,
    this.isFavorited = false,
    this.previewUrl,
    this.audioUrl,
    this.isPlayable = true,
    this.spotifyUrl,
    this.language,
    this.languages = const [],
    this.sourceProvider = 'mock',
  });

  final String id;
  final String title;
  final String artistName;
  final List<String> artists;
  final String? artistId;
  final String? albumName;
  final String? albumId;
  final String? artworkUrl;
  final Duration duration;
  final DateTime? releaseDate;
  final bool isExplicit;
  final bool isFavorited;
  
  final String? previewUrl;
  final String? audioUrl;
  final bool isPlayable;
  final String? spotifyUrl;
  final String? language;
  final List<String> languages;
  
  final String sourceProvider;

  String get durationText {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artistName,
    List<String>? artists,
    String? artistId,
    String? albumName,
    String? albumId,
    String? artworkUrl,
    Duration? duration,
    DateTime? releaseDate,
    bool? isExplicit,
    bool? isFavorited,
    String? previewUrl,
    String? audioUrl,
    bool? isPlayable,
    String? spotifyUrl,
    String? language,
    List<String>? languages,
    String? sourceProvider,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artists: artists ?? this.artists,
      artistId: artistId ?? this.artistId,
      albumName: albumName ?? this.albumName,
      albumId: albumId ?? this.albumId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      releaseDate: releaseDate ?? this.releaseDate,
      isExplicit: isExplicit ?? this.isExplicit,
      isFavorited: isFavorited ?? this.isFavorited,
      previewUrl: previewUrl ?? this.previewUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isPlayable: isPlayable ?? this.isPlayable,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      language: language ?? this.language,
      languages: languages ?? this.languages,
      sourceProvider: sourceProvider ?? this.sourceProvider,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}