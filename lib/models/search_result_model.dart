import 'album_model.dart';
import 'artist_model.dart';
import 'playlist_model.dart';
import 'song_model.dart';

/// Aggregated result of a search query across all content types.
class SearchResultModel {
  const SearchResultModel({
    this.query = '',
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
    this.isLoading = false,
    this.hasError = false,
  });

  final String query;
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final List<PlaylistModel> playlists;
  final bool isLoading;
  final bool hasError;

  bool get isEmpty =>
      songs.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty;

  int get totalCount => songs.length + albums.length + artists.length + playlists.length;

  SearchResultModel copyWith({
    String? query,
    List<SongModel>? songs,
    List<AlbumModel>? albums,
    List<ArtistModel>? artists,
    List<PlaylistModel>? playlists,
    bool? isLoading,
    bool? hasError,
  }) {
    return SearchResultModel(
      query: query ?? this.query,
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  SearchResultModel clear() => SearchResultModel(query: query);
}

/// A single recent/trending search entry.
class SearchSuggestion {
  const SearchSuggestion({
    required this.query,
    this.isTrending = false,
    this.artworkUrl,
  });

  final String query;
  final bool isTrending;
  final String? artworkUrl;
}