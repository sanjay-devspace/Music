import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/music_provider.dart';

/// Maps Spotify API JSON payloads onto TUNEHIVE domain models.
///
/// This is the only place (besides the raw API client) that knows about
/// Spotify's field names. The rest of the app consumes [SongModel],
/// [AlbumModel] and [ArtistModel].
class SpotifyMapper {
  const SpotifyMapper();

  static String imageUrl(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final best = images
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((i) => i['url'] != null)
          .toList()
        ..sort((a, b) =>
            (b['width'] as int? ?? 0).compareTo(a['width'] as int? ?? 0));
      if (best.isNotEmpty) return best.last['url'] as String;
    }
    return '';
  }

  static Duration trackDuration(Map<String, dynamic> json) {
    final ms = json['duration_ms'];
    if (ms is int) return Duration(milliseconds: ms);
    return Duration.zero;
  }

  static ArtistModel artist(Map<String, dynamic> json) {
    return ArtistModel(
      id: 'spotify:${json['id']}',
      name: json['name'] as String? ?? 'Unknown Artist',
      avatarUrl: imageUrl(json),
      genres: (json['genres'] as List?)?.whereType<String>().toList() ?? const [],
      followers: (json['followers'] as Map?)?['total'] as int?,
      popularity: json['popularity'] as int?,
    );
  }

  static AlbumModel album(Map<String, dynamic> json) {
    final rawSongs = json['tracks']?['items'] as List? ?? const [];
    final year = json['release_date']?.toString().substring(0, 4);
    return AlbumModel(
      id: 'spotify:${json['id']}',
      name: json['name'] as String? ?? 'Unknown Album',
      artistName: _firstArtist(json),
      artistId: _firstArtistId(json),
      artworkUrl: imageUrl(json),
      releaseYear: int.tryParse(year ?? ''),
      totalTracks: json['total_tracks'] as int?,
      songs: rawSongs
          .whereType<Map>()
          .map((e) => song(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static SongModel song(Map<String, dynamic> json) {
    final albumMap = json['album'];
    final id = (json['id'] ?? json['uri'])?.toString() ?? '';
    return SongModel(
      id: id.contains('spotify:track:') ? id : 'spotify:$id',
      title: json['name'] as String? ?? 'Unknown Track',
      artistName: _firstArtist(json),
      artistId: _firstArtistId(json),
      albumName: albumMap is Map ? albumMap['name'] as String? : null,
      albumId: albumMap is Map && albumMap['id'] != null ? 'spotify:${albumMap['id']}' : null,
      artworkUrl: albumMap is Map ? imageUrl(Map<String, dynamic>.from(albumMap)) : null,
      duration: trackDuration(json),
      isExplicit: json['explicit'] == true,
      sourceProvider: spotifyProviderId,
    );
  }

  static String _firstArtist(Map<String, dynamic> json) {
    final artists = json['artists'];
    if (artists is List && artists.isNotEmpty) {
      final first = artists.first;
      if (first is Map) return first['name'] as String? ?? 'Unknown Artist';
    }
    return 'Unknown Artist';
  }

  static String? _firstArtistId(Map<String, dynamic> json) {
    final artists = json['artists'];
    if (artists is List && artists.isNotEmpty) {
      final first = artists.first;
      if (first is Map) {
        final id = first['id'];
        return id == null ? null : 'spotify:$id';
      }
    }
    return null;
  }
}