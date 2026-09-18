import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';

class JioSaavnMapper {
  const JioSaavnMapper();

  static SongModel song(Map<String, dynamic> json) {
    // JioSaavnAPI usually returns fields like:
    // id, song, primary_artists, album, duration, image, media_url, language, year, has_lyrics
    
    final id = json['id']?.toString() ?? '';
    final title = json['song']?.toString() ?? json['title']?.toString() ?? 'Unknown Track';
    final artistStr = json['primary_artists']?.toString() ?? json['singers']?.toString() ?? '';
    final albumStr = json['album']?.toString() ?? '';
    final image = json['image']?.toString() ?? '';
    final mediaUrl = json['media_url']?.toString() ?? json['download_links']?.toString() ?? json['link']?.toString();
    final language = json['language']?.toString();
    
    // Duration might be string or int
    final durationRaw = json['duration'];
    Duration duration = Duration.zero;
    if (durationRaw is int) {
      duration = Duration(seconds: durationRaw); // JioSaavn usually returns duration in seconds
    } else if (durationRaw is String) {
      final parsed = int.tryParse(durationRaw);
      if (parsed != null) duration = Duration(seconds: parsed);
    }
    
    // Year
    final yearStr = json['year']?.toString();
    DateTime? releaseDate;
    if (yearStr != null && yearStr.length == 4) {
      releaseDate = DateTime.tryParse('$yearStr-01-01');
    }

    return SongModel(
      id: id,
      title: _cleanText(title),
      artistName: _cleanText(artistStr),
      artists: _cleanText(artistStr).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      albumName: _cleanText(albumStr),
      artworkUrl: image.isNotEmpty ? image.replaceAll('150x150', '500x500') : null,
      duration: duration,
      releaseDate: releaseDate,
      audioUrl: mediaUrl,
      isPlayable: mediaUrl != null && mediaUrl.isNotEmpty,
      language: language,
      languages: language != null ? [language] : const [],
      sourceProvider: 'jiosaavn',
    );
  }

  static AlbumModel album(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? json['album']?.toString() ?? 'Unknown Album';
    final image = json['image']?.toString() ?? '';
    final songsList = json['songs'] as List? ?? [];
    final artistStr = json['primary_artists']?.toString() ?? json['music']?.toString() ?? 'Unknown Artist';
    
    return AlbumModel(
      id: id,
      name: _cleanText(title),
      artistName: _cleanText(artistStr),
      artworkUrl: image.isNotEmpty ? image.replaceAll('150x150', '500x500') : null,
      songs: songsList.whereType<Map>().map((e) => song(Map<String, dynamic>.from(e))).toList(),
    );
  }

  static ArtistModel artist(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? 'Unknown Artist';
    final image = json['image']?.toString() ?? '';
    
    return ArtistModel(
      id: id,
      name: _cleanText(name),
      avatarUrl: image.isNotEmpty ? image.replaceAll('150x150', '500x500') : '',
    );
  }

  static String _cleanText(String text) {
    return text.replaceAll('&quot;', '"').replaceAll('&amp;', '&').replaceAll('&#039;', "'");
  }
}
