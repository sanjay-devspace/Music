import 'song_model.dart';

/// A user-created or curated playlist.
class PlaylistModel {
  const PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.songs = const [],
    this.createdAt,
    this.isOwned = true,
  });

  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final List<SongModel> songs;
  final DateTime? createdAt;
  final bool isOwned;

  int get songCount => songs.length;

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    List<SongModel>? songs,
    DateTime? createdAt,
    bool? isOwned,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      isOwned: isOwned ?? this.isOwned,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}