import 'album_model.dart';
import 'artist_model.dart';
import 'song_model.dart';

/// A single recommendation item surfaced to the user.
class RecommendationModel {
  const RecommendationModel({
    required this.id,
    required this.title,
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.reason,
    this.confidence = 0.0,
  });

  final String id;
  final String title;
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final String? reason;
  final double confidence;

  RecommendationModel copyWith({
    String? id,
    String? title,
    List<SongModel>? songs,
    List<AlbumModel>? albums,
    List<ArtistModel>? artists,
    String? reason,
    double? confidence,
  }) {
    return RecommendationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      reason: reason ?? this.reason,
      confidence: confidence ?? this.confidence,
    );
  }
}