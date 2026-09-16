import 'song_model.dart';

/// An album collection of songs.
class AlbumModel {
  const AlbumModel({
    required this.id,
    required this.name,
    required this.artistName,
    this.artistId,
    this.artworkUrl,
    this.releaseYear,
    this.totalTracks,
    this.songs = const [],
  });

  final String id;
  final String name;
  final String artistName;
  final String? artistId;
  final String? artworkUrl;
  final int? releaseYear;
  final int? totalTracks;
  final List<SongModel> songs;

  int get displayTrackCount => totalTracks ?? songs.length;

  AlbumModel copyWith({
    String? id,
    String? name,
    String? artistName,
    String? artistId,
    String? artworkUrl,
    int? releaseYear,
    int? totalTracks,
    List<SongModel>? songs,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      artistName: artistName ?? this.artistName,
      artistId: artistId ?? this.artistId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      releaseYear: releaseYear ?? this.releaseYear,
      totalTracks: totalTracks ?? this.totalTracks,
      songs: songs ?? this.songs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}