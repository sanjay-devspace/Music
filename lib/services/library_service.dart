import 'package:tunehive/models/song_model.dart';

/// User library: liked songs, albums, artists, recently played.
///
/// Source of truth lives in Supabase when connected; otherwise an in-memory
/// store keeps the UI fully functional.
class LibraryService {
  LibraryService();

  final List<SongModel> _likedSongs = [];
  final Set<String> _likedAlbumIds = {};
  final Set<String> _likedArtistIds = {};
  final List<SongModel> _recentlyPlayed = [];
  final Map<String, int> _playCounts = {};

  // ---- Liked songs ---------------------------------------------------------

  Future<List<SongModel>> getLikedSongs() async =>
      List.unmodifiable(_likedSongs);

  Future<bool> isLiked(String songId) async =>
      _likedSongs.any((s) => s.id == songId);

  Future<void> toggleLike(SongModel song) async {
    if (_likedSongs.any((s) => s.id == song.id)) {
      _likedSongs.removeWhere((s) => s.id == song.id);
    } else {
      _likedSongs.insert(0, song.copyWith(isFavorited: true));
    }
  }

  Future<void> likeSong(SongModel song) async {
    if (!_likedSongs.any((s) => s.id == song.id)) {
      _likedSongs.insert(0, song.copyWith(isFavorited: true));
    }
  }

  Future<void> unlikeSong(String songId) async {
    _likedSongs.removeWhere((s) => s.id == songId);
  }

  // ---- Liked albums / artists ----------------------------------------------

  Future<Set<String>> getLikedAlbumIds() async => Set.of(_likedAlbumIds);
  Future<Set<String>> getLikedArtistIds() async => Set.of(_likedArtistIds);

  Future<void> toggleLikeAlbum(String albumId) async {
    if (!_likedAlbumIds.add(albumId)) _likedAlbumIds.remove(albumId);
  }

  Future<void> toggleLikeArtist(String artistId) async {
    if (!_likedArtistIds.add(artistId)) _likedArtistIds.remove(artistId);
  }

  // ---- Recently played -----------------------------------------------------

  Future<List<SongModel>> getRecentlyPlayed() async =>
      List.unmodifiable(_recentlyPlayed);

  Future<void> recordPlay(SongModel song) async {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 50) {
      _recentlyPlayed.removeRange(50, _recentlyPlayed.length);
    }
    _playCounts[song.id] = (_playCounts[song.id] ?? 0) + 1;
  }

  int get playCount => _playCounts.values.fold(0, (a, b) => a + b);
  Map<String, int> get playCounts => Map.unmodifiable(_playCounts);

  /// Most played songs ordered by count (used by recommendation signals).
  List<SongModel> get topPlayed {
    final sorted = _playCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .map((e) => _recentlyPlayed.where((s) => s.id == e.key).firstOrNull)
        .whereType<SongModel>()
        .toList();
  }
}

extension _FirstOrNull on Iterable<SongModel> {
  SongModel? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}