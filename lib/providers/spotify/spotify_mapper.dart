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
    return (json['image'] as String?) ??
        (json['thumbnail'] as String?) ??
        (json['artwork'] as String?) ??
        (json['album_image'] as String?) ??
        '';
  }

  static Duration trackDuration(Map<String, dynamic> json) {
    final ms = json['duration_ms'] ?? json['duration'];
    if (ms is int) return Duration(milliseconds: ms);
    if (ms is String) {
      final parsed = int.tryParse(ms);
      if (parsed != null) return Duration(milliseconds: parsed);
    }
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
    
    String? dateStr = json['release_date'] ?? (albumMap is Map ? albumMap['release_date'] : null);
    DateTime? releaseDate;
    if (dateStr != null && dateStr.isNotEmpty) {
      // Handle YYYY, YYYY-MM, or YYYY-MM-DD
      if (dateStr.length == 4) dateStr = '$dateStr-01-01';
      if (dateStr.length == 7) dateStr = '$dateStr-01';
      releaseDate = DateTime.tryParse(dateStr);
    }

    final previewUrl = json['preview_url'] as String? ?? json['previewUrl'] as String?;
    final audioUrl = json['audio_url'] as String? ?? json['audioUrl'] as String?;
    
    // Ensure we don't fall back to empty string for artwork if album image is null, but we do want fallback.
    final artworkUrl = albumMap is Map ? imageUrl(Map<String, dynamic>.from(albumMap)) : imageUrl(json);

    return SongModel(
      id: id.contains('spotify:track:') ? id : 'spotify:$id',
      title: json['name'] as String? ?? 'Unknown Track',
      artistName: _firstArtist(json),
      artists: _allArtists(json),
      artistId: _firstArtistId(json),
      albumName: albumMap is Map ? albumMap['name'] as String? : null,
      albumId: albumMap is Map && albumMap['id'] != null ? 'spotify:${albumMap['id']}' : null,
      artworkUrl: artworkUrl.isNotEmpty ? artworkUrl : null,
      duration: trackDuration(json),
      releaseDate: releaseDate,
      isExplicit: json['explicit'] == true,
      previewUrl: previewUrl,
      audioUrl: audioUrl,
      isPlayable: audioUrl != null || previewUrl != null,
      spotifyUrl: json['external_urls']?['spotify'] as String?,
      language: json['language'] as String?,
      languages: (json['languages'] as List?)?.whereType<String>().toList() ?? const [],
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
  
  static List<String> _allArtists(Map<String, dynamic> json) {
    final artists = json['artists'];
    if (artists is List) {
      return artists.whereType<Map>().map((e) => e['name'] as String? ?? '').where((e) => e.isNotEmpty).toList();
    }
    return [];
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