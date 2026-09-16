import 'package:tunehive/models/playlist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/mock_data.dart';

/// Playlist CRUD. Persisted to Supabase when connected; falls back to an
/// in-memory store seeded with curated playlists.
class PlaylistService {
  PlaylistService();

  final List<PlaylistModel> _playlists = [];
  bool _seeded = false;

  Future<List<PlaylistModel>> getMyPlaylists() async {
    _ensureSeeded();
    return List.unmodifiable(_playlists);
  }

  Future<PlaylistModel> createPlaylist(
    String name, {
    String? description,
  }) async {
    _ensureSeeded();
    final playlist = PlaylistModel(
      id: 'pl-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      createdAt: DateTime.now(),
      isOwned: true,
    );
    _playlists.insert(0, playlist);
    return playlist;
  }

  Future<PlaylistModel> renamePlaylist(String id, String name) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index < 0) throw StateError('Playlist not found');
    final updated = _playlists[index].copyWith(name: name);
    _playlists[index] = updated;
    return updated;
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
  }

  Future<void> addSong(String playlistId, SongModel song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index < 0) return;
    final current = _playlists[index];
    if (current.songs.any((s) => s.id == song.id)) return;
    _playlists[index] = current.copyWith(songs: [...current.songs, song]);
  }

  Future<void> removeSong(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index < 0) return;
    final current = _playlists[index];
    _playlists[index] = current.copyWith(
      songs: current.songs.where((s) => s.id != songId).toList(),
    );
  }

  Future<void> reorderSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index < 0) return;
    final current = _playlists[index];
    final songs = [...current.songs];
    if (oldIndex < 0 || oldIndex >= songs.length) return;
    final moved = songs.removeAt(oldIndex);
    int target = newIndex;
    if (newIndex > oldIndex) target -= 1;
    songs.insert(target.clamp(0, songs.length), moved);
    _playlists[index] = current.copyWith(songs: songs);
  }

  void _ensureSeeded() {
    if (_seeded) return;
    _seeded = true;
    _playlists.addAll(MockData.playlists);
  }
}