/// A single playable track.
class SongModel {
  const SongModel({
    required this.id,
    required this.title,
    required this.artistName,
    this.artistId,
    this.albumName,
    this.albumId,
    this.artworkUrl,
    this.duration = Duration.zero,
    this.isExplicit = false,
    this.isFavorited = false,
    this.sourceProvider = 'mock',
  });

  final String id;
  final String title;
  final String artistName;
  final String? artistId;
  final String? albumName;
  final String? albumId;
  final String? artworkUrl;
  final Duration duration;
  final bool isExplicit;
  final bool isFavorited;
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
    String? artistId,
    String? albumName,
    String? albumId,
    String? artworkUrl,
    Duration? duration,
    bool? isExplicit,
    bool? isFavorited,
    String? sourceProvider,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artistId: artistId ?? this.artistId,
      albumName: albumName ?? this.albumName,
      albumId: albumId ?? this.albumId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      isExplicit: isExplicit ?? this.isExplicit,
      isFavorited: isFavorited ?? this.isFavorited,
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