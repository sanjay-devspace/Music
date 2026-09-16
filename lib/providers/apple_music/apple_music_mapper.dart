import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/providers/music_provider.dart';

/// Maps Apple Music (Musickit) JSON payloads onto domain models.
class AppleMusicMapper {
  const AppleMusicMapper();

  static String imageUrl(Map<String, dynamic> json) {
    final art = json['attributes']?['artwork'];
    if (art is Map) {
      final url = art['url'] as String?;
      if (url != null) {
        // Apple provides templates e.g. {w}x{h}bb.jpg — resolve to 300px.
        return url
            .replaceAll('{w}', '300')
            .replaceAll('{h}', '300')
            .replaceAll('{f}', 'jpg');
      }
    }
    return '';
  }

  static SongModel song(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final attributes = json['attributes'] as Map<String, dynamic>? ?? const {};
    final artwork = imageUrl(json);
    return SongModel(
      id: 'apple:$id',
      title: attributes['name'] as String? ?? 'Unknown Track',
      artistName: attributes['artistName'] as String? ?? 'Unknown Artist',
      albumName: attributes['albumName'] as String?,
      duration: Duration(milliseconds: attributes['durationInMillis'] as int? ?? 0),
      isExplicit: attributes['contentRating'] == 'explicit',
      artworkUrl: artwork.isEmpty ? null : artwork,
      sourceProvider: appleMusicProviderId,
    );
  }

  static AlbumModel album(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final attributes = json['attributes'] as Map<String, dynamic>? ?? const {};
    final trackCount = attributes['trackCount'] as int?;
    return AlbumModel(
      id: 'apple:$id',
      name: attributes['name'] as String? ?? 'Unknown Album',
      artistName: attributes['artistName'] as String? ?? 'Unknown Artist',
      artworkUrl: imageUrl(json),
      releaseYear: int.tryParse('${attributes['releaseDate'] ?? ''}'.substring(0, 4)),
      totalTracks: trackCount,
    );
  }

  static ArtistModel artist(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final attributes = json['attributes'] as Map<String, dynamic>? ?? const {};
    return ArtistModel(
      id: 'apple:$id',
      name: attributes['name'] as String? ?? 'Unknown Artist',
      avatarUrl: imageUrl(json),
      genres: [],
    );
  }
}