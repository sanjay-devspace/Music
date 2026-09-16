import 'package:flutter/material.dart';
import 'package:tunehive/models/album_model.dart';
import 'package:tunehive/models/artist_model.dart';
import 'package:tunehive/models/genre_model.dart';
import 'package:tunehive/models/mood_model.dart';
import 'package:tunehive/models/playlist_model.dart';
import 'package:tunehive/models/recommendation_model.dart';
import 'package:tunehive/models/song_model.dart';

/// Realistic development data used by the MockMusicProvider.
///
/// Artwork uses picsum-style placeholders so the app looks premium even
/// before live catalogs are wired up. Swap the provider for a live one
/// without changing the UI.
abstract class MockData {
  MockData._();

  static String _art(String seed, [int size = 600]) =>
      'https://picsum.photos/seed/$seed/$size/$size';

  // ---------------------------------------------------------------------
  // Artists
  // ---------------------------------------------------------------------
  static final artists = <ArtistModel>[
    ArtistModel(id: 'a1', name: 'Nova Rae', avatarUrl: _art('nova'), followers: 4820000, genres: ['Electronic', 'Pop'], popularity: 92),
    ArtistModel(id: 'a2', name: 'The Midnight Heralds', avatarUrl: _art('heralds'), followers: 1900000, genres: ['Indie', 'Rock'], popularity: 88),
    ArtistModel(id: 'a3', name: 'Kael & The Waves', avatarUrl: _art('kael'), followers: 730000, genres: ['Blues', 'Soul'], popularity: 74),
    ArtistModel(id: 'a4', name: 'Solstice', avatarUrl: _art('solstice'), followers: 12000000, genres: ['Hip-Hop', 'Rap'], popularity: 96),
    ArtistModel(id: 'a5', name: 'Mira Celeste', avatarUrl: _art('mira'), followers: 3100000, genres: ['Alternative', 'Dream Pop'], popularity: 85),
    ArtistModel(id: 'a6', name: 'Rave Frequency', avatarUrl: _art('rave'), followers: 680000, genres: ['Techno', 'House'], popularity: 79),
    ArtistModel(id: 'a7', name: 'Lena Brooks', avatarUrl: _art('lena'), followers: 2200000, genres: ['R&B', 'Soul'], popularity: 90),
    ArtistModel(id: 'a8', name: 'Iron Claw', avatarUrl: _art('ironclaw'), followers: 940000, genres: ['Metal', 'Hard Rock'], popularity: 71),
  ];

  static ArtistModel artist(String id) =>
      artists.firstWhere((a) => a.id == id, orElse: () => artists.first);

  // ---------------------------------------------------------------------
  // Songs
  // ---------------------------------------------------------------------
  static final songs = <SongModel>[
    SongModel(id: 's1', title: 'Neon Horizon', artistName: 'Nova Rae', artistId: 'a1', albumName: 'Chromatic', albumId: 'al1', artworkUrl: _art('s1'), duration: const Duration(seconds: 213), sourceProvider: 'mock'),
    SongModel(id: 's2', title: 'Midnight Hymn', artistName: 'The Midnight Heralds', artistId: 'a2', albumName: 'Tales of Dusk', albumId: 'al2', artworkUrl: _art('s2'), duration: const Duration(seconds: 251), sourceProvider: 'mock'),
    SongModel(id: 's3', title: 'Salt & Smoke', artistName: 'Kael & The Waves', artistId: 'a3', albumName: 'Into the Deep', albumId: 'al3', artworkUrl: _art('s3'), duration: const Duration(seconds: 198), sourceProvider: 'mock'),
    SongModel(id: 's4', title: 'Crown of Static', artistName: 'Solstice', artistId: 'a4', albumName: 'Golden Hour', albumId: 'al4', artworkUrl: _art('s4'), duration: const Duration(seconds: 187), sourceProvider: 'mock'),
    SongModel(id: 's5', title: 'Dream Atlas', artistName: 'Mira Celeste', artistId: 'a5', albumName: 'Slumber Notes', albumId: 'al5', artworkUrl: _art('s5'), duration: const Duration(seconds: 233), sourceProvider: 'mock'),
    SongModel(id: 's6', title: 'Pulse Drive', artistName: 'Rave Frequency', artistId: 'a6', albumName: 'Club Icons', albumId: 'al6', artworkUrl: _art('s6'), duration: const Duration(seconds: 176), sourceProvider: 'mock'),
    SongModel(id: 's7', title: 'Velvet Lies', artistName: 'Lena Brooks', artistId: 'a7', albumName: 'Afterglow', albumId: 'al7', artworkUrl: _art('s7'), duration: const Duration(seconds: 227), sourceProvider: 'mock'),
    SongModel(id: 's8', title: 'Iron Bloom', artistName: 'Iron Claw', artistId: 'a8', albumName: 'Forge & Sorrow', albumId: 'al8', artworkUrl: _art('s8'), duration: const Duration(seconds: 264), sourceProvider: 'mock'),
    SongModel(id: 's9', title: 'Static Bloom', artistName: 'Nova Rae', artistId: 'a1', albumName: 'Chromatic', albumId: 'al1', artworkUrl: _art('s9'), duration: const Duration(seconds: 205), sourceProvider: 'mock'),
    SongModel(id: 's10', title: 'Echo Park', artistName: 'Mira Celeste', artistId: 'a5', albumName: 'Slumber Notes', albumId: 'al5', artworkUrl: _art('s10'), duration: const Duration(seconds: 241), sourceProvider: 'mock'),
    SongModel(id: 's11', title: 'Winds of Mercury', artistName: 'The Midnight Heralds', artistId: 'a2', albumName: 'Tales of Dusk', albumId: 'al2', artworkUrl: _art('s11'), duration: const Duration(seconds: 219), sourceProvider: 'mock'),
    SongModel(id: 's12', title: 'Lithium Skies', artistName: 'Solstice', artistId: 'a4', albumName: 'Golden Hour', albumId: 'al4', artworkUrl: _art('s12'), duration: const Duration(seconds: 194), sourceProvider: 'mock'),
    SongModel(id: 's13', title: 'Glass Cathedral', artistName: 'Kael & The Waves', artistId: 'a3', albumName: 'Into the Deep', albumId: 'al3', artworkUrl: _art('s13'), duration: const Duration(seconds: 256), sourceProvider: 'mock'),
    SongModel(id: 's14', title: 'Golden Hour', artistName: 'Solstice', artistId: 'a4', albumName: 'Golden Hour', albumId: 'al4', artworkUrl: _art('s14'), duration: const Duration(seconds: 208), sourceProvider: 'mock'),
    SongModel(id: 's15', title: 'Paper Moons', artistName: 'Lena Brooks', artistId: 'a7', albumName: 'Afterglow', albumId: 'al7', artworkUrl: _art('s15'), duration: const Duration(seconds: 232), sourceProvider: 'mock'),
    SongModel(id: 's16', title: 'Daylight Static', artistName: 'Nova Rae', artistId: 'a1', albumName: 'Chromatic', albumId: 'al1', artworkUrl: _art('s16'), duration: const Duration(seconds: 189), sourceProvider: 'mock'),
    SongModel(id: 's17', title: 'Slow Motion Sun', artistName: 'Mira Celeste', artistId: 'a5', albumName: 'Slumber Notes', albumId: 'al5', artworkUrl: _art('s17'), duration: const Duration(seconds: 244), sourceProvider: 'mock'),
    SongModel(id: 's18', title: 'Runaway Dreams', artistName: 'Solstice', artistId: 'a4', albumName: 'Golden Hour', albumId: 'al4', artworkUrl: _art('s18'), duration: const Duration(seconds: 202), sourceProvider: 'mock'),
    SongModel(id: 's19', title: 'Ember & Tide', artistName: 'Kael & The Waves', artistId: 'a3', albumName: 'Into the Deep', albumId: 'al3', artworkUrl: _art('s19'), duration: const Duration(seconds: 217), sourceProvider: 'mock'),
    SongModel(id: 's20', title: 'Night Drive', artistName: 'Rave Frequency', artistId: 'a6', albumName: 'Club Icons', albumId: 'al6', artworkUrl: _art('s20'), duration: const Duration(seconds: 183), sourceProvider: 'mock'),
  ];

  static SongModel song(String id) =>
      songs.firstWhere((s) => s.id == id, orElse: () => songs.first);

  // ---------------------------------------------------------------------
  // Albums
  // ---------------------------------------------------------------------
  static final albums = <AlbumModel>[
    AlbumModel(id: 'al1', name: 'Chromatic', artistName: 'Nova Rae', artistId: 'a1', artworkUrl: _art('al1'), releaseYear: 2025, totalTracks: 12),
    AlbumModel(id: 'al2', name: 'Tales of Dusk', artistName: 'The Midnight Heralds', artistId: 'a2', artworkUrl: _art('al2'), releaseYear: 2024, totalTracks: 10),
    AlbumModel(id: 'al3', name: 'Into the Deep', artistName: 'Kael & The Waves', artistId: 'a3', artworkUrl: _art('al3'), releaseYear: 2024, totalTracks: 9),
    AlbumModel(id: 'al4', name: 'Golden Hour', artistName: 'Solstice', artistId: 'a4', artworkUrl: _art('al4'), releaseYear: 2026, totalTracks: 14),
    AlbumModel(id: 'al5', name: 'Slumber Notes', artistName: 'Mira Celeste', artistId: 'a5', artworkUrl: _art('al5'), releaseYear: 2025, totalTracks: 11),
    AlbumModel(id: 'al6', name: 'Club Icons', artistName: 'Rave Frequency', artistId: 'a6', artworkUrl: _art('al6'), releaseYear: 2023, totalTracks: 8),
    AlbumModel(id: 'al7', name: 'Afterglow', artistName: 'Lena Brooks', artistId: 'a7', artworkUrl: _art('al7'), releaseYear: 2026, totalTracks: 10),
    AlbumModel(id: 'al8', name: 'Forge & Sorrow', artistName: 'Iron Claw', artistId: 'a8', artworkUrl: _art('al8'), releaseYear: 2022, totalTracks: 11),
  ];

  static AlbumModel album(String id) =>
      albums.firstWhere((a) => a.id == id, orElse: () => albums.first);

  // ---------------------------------------------------------------------
  // Genres / Categories
  // ---------------------------------------------------------------------
  static final genres = <GenreModel>[
    const GenreModel(id: 'g0', name: 'All'),
    GenreModel(id: 'g1', name: 'Party', icon: IconsName.celebration, imageUrls: [_art('party')], songCount: 4200),
    GenreModel(id: 'g2', name: 'Blues', icon: IconsName.musicNote, imageUrls: [_art('blues')], songCount: 1300),
    GenreModel(id: 'g3', name: 'Sad', icon: IconsName.cloud, imageUrls: [_art('sad')], songCount: 980),
    GenreModel(id: 'g4', name: 'Hip-Hop', icon: IconsName.mic, imageUrls: [_art('hiphop')], songCount: 5600),
    GenreModel(id: 'g5', name: 'Chill', icon: IconsName.spa, imageUrls: [_art('chill')], songCount: 3100),
    GenreModel(id: 'g6', name: 'Focus', icon: IconsName.centerFocus, imageUrls: [_art('focus')], songCount: 870),
    GenreModel(id: 'g7', name: 'Romantic', icon: IconsName.favorite, imageUrls: [_art('romantic')], songCount: 2400),
    GenreModel(id: 'g8', name: 'Workout', icon: IconsName.fitness, imageUrls: [_art('workout')], songCount: 1900),
  ];

  // ---------------------------------------------------------------------
  // Moods — "Your Mood" row on Home
  // ---------------------------------------------------------------------
  static final moods = <MoodModel>[
    MoodModel(id: 'm-chill', name: 'Chill', icon: Icons.nightlight_round, imageUrl: _art('mood-chill'), label: 'Low lights'),
    MoodModel(id: 'm-workout', name: 'Workout', icon: Icons.fitness_center_rounded, imageUrl: _art('mood-workout'), label: 'Heavy reps'),
    MoodModel(id: 'm-focus', name: 'Focus', icon: Icons.center_focus_strong, imageUrl: _art('mood-focus'), label: 'Deep work'),
    MoodModel(id: 'm-romantic', name: 'Romantic', icon: Icons.favorite_rounded, imageUrl: _art('mood-romantic'), label: 'Good vibes'),
    MoodModel(id: 'm-party', name: 'Party', icon: Icons.celebration_rounded, imageUrl: _art('mood-party'), label: 'Turn it up'),
    MoodModel(id: 'm-sleep', name: 'Sleep', icon: Icons.bedtime_rounded, imageUrl: _art('mood-sleep'), label: 'Drift away'),
    MoodModel(id: 'm-drive', name: 'Drive', icon: Icons.directions_car_rounded, imageUrl: _art('mood-drive'), label: 'Open road'),
  ];

  static const List<(String, List<String>)> _moodSongIds = [
    ('m-chill', ['s5', 's10', 's1', 's17', 's9']),
    ('m-workout', ['s6', 's4', 's8', 's20', 's18']),
    ('m-focus', ['s16', 's11', 's1', 's10', 's14']),
    ('m-romantic', ['s7', 's15', 's2', 's3', 's13']),
    ('m-party', ['s20', 's6', 's4', 's12', 's8']),
    ('m-sleep', ['s5', 's17', 's2', 's11', 's3']),
    ('m-drive', ['s14', 's20', 's12', 's6', 's19']),
  ];

  /// Songs tuned to a given mood (used by Home when filtering).
  static List<SongModel> songsForMood(String moodId) {
    for (final (mood, ids) in _moodSongIds) {
      if (mood == moodId) return ids.map(song).toList();
    }
    return songs.take(5).toList();
  }

  // ---------------------------------------------------------------------
  // Hero features — editorial "MIDNIGHT VIBES" style card
  // ---------------------------------------------------------------------
  static final heroFeatures = <HeroFeature>[
    HeroFeature(
      id: 'hero-midnight',
      title: 'MIDNIGHT VIBES',
      subtitle: 'Slow songs. Deep thoughts. Bright tomorrow.',
      description: 'The calm after the noise — built for 2AM reflection.',
      artworkUrl: _art('hero-midnight'),
    ),
    HeroFeature(
      id: 'hero-speed',
      title: 'HIGH VOLTAGE',
      subtitle: 'Turn it up. Feel it burn.',
      description: 'Amped-up anthems for the moments you need fuel.',
      artworkUrl: _art('hero-speed'),
    ),
  ];

  // ---------------------------------------------------------------------
  // Daily mixes
  // ---------------------------------------------------------------------
  static final dailyMixes = <PlaylistModel>[
    PlaylistModel(id: 'd1', name: 'Daily Mix 1', description: 'Nova Rae, Mira Celeste & more', coverUrl: _art('mix1'), songs: [songs[0], songs[9], songs[5], songs[16]]),
    PlaylistModel(id: 'd2', name: 'Daily Mix 2', description: 'Solstice, Rave Frequency & more', coverUrl: _art('mix2'), songs: [songs[3], songs[20 - 1], songs[8], songs[11]]),
    PlaylistModel(id: 'd3', name: 'Daily Mix 3', description: 'Lena Brooks, Kael & more', coverUrl: _art('mix3'), songs: [songs[6], songs[14], songs[2], songs[12]]),
    PlaylistModel(id: 'd4', name: 'Daily Mix 4', description: 'The Midnight Heralds & more', coverUrl: _art('mix4'), songs: [songs[1], songs[10], songs[18 - 1], songs[15 - 1]]),
  ];

  // ---------------------------------------------------------------------
  // Editorial playlists — "Recommended For You"
  // ---------------------------------------------------------------------
  static final editorialPlaylists = <PlaylistModel>[
    PlaylistModel(id: 'p-focus-beats', name: 'Focus Beats', description: 'Instrumental flow for deep work.', coverUrl: _art('focus-beats'), songs: [songs[9], songs[15], songs[0], songs[10]]),
    PlaylistModel(id: 'p-feel-good', name: 'Feel Good', description: 'Instant serotonin, no skips.', coverUrl: _art('feel-good'), songs: [songs[13], songs[6], songs[18], songs[3]]),
    PlaylistModel(id: 'p-top-100', name: 'Top 100', description: 'The biggest tracks on TuneHive today.', coverUrl: _art('top-100'), songs: [songs[3], songs[0], songs[6], songs[7]]),
    PlaylistModel(id: 'p-study-vibes', name: 'Study Vibes', description: 'Lo-fi, dream pop & ambient.', coverUrl: _art('study-vibes'), songs: [songs[5], songs[16], songs[9], songs[1]]),
  ];

  // ---------------------------------------------------------------------
  // Playlists
  // ---------------------------------------------------------------------
  static final playlists = <PlaylistModel>[
    PlaylistModel(id: 'p1', name: 'Chill Vibes', description: 'Late night, low lights.', coverUrl: _art('p1'), songs: [songs[9], songs[0], songs[4]]),
    PlaylistModel(id: 'p2', name: 'Workout Energy', description: 'Heavy beats for heavy reps.', coverUrl: _art('p2'), songs: [songs[5], songs[3], songs[7]]),
    PlaylistModel(id: 'p3', name: 'Sonic Sundays', description: 'Slow mornings, warm tones.', coverUrl: _art('p3'), songs: [songs[2], songs[6], songs[10]]),
  ];

  // ---------------------------------------------------------------------
  // Search hints
  // ---------------------------------------------------------------------
  static const List<String> trendingSearches = [
    'Midnight Hymn',
    'Solstice',
    'Lena Brooks',
    'Focus Beats',
    'Chromatic',
    'Night Drive',
  ];

  static const List<String> recentSearches = [
    'Nova Rae',
    'Dream Atlas',
    'Daily Mix 1',
  ];

  // ---------------------------------------------------------------------
  // Recommendations
  // ---------------------------------------------------------------------
  static final recommendations = <RecommendationModel>[
    RecommendationModel(
      id: 'r1',
      title: 'Recommended for you',
      reason: 'Based on Nova Rae & Solstice',
      confidence: 0.92,
      songs: [songs[0], songs[3], songs[9], songs[5], songs[6]],
    ),
    RecommendationModel(
      id: 'r2',
      title: 'Trending now',
      reason: 'People are playing this worldwide',
      confidence: 0.97,
      songs: [songs[3], songs[6], songs[7], songs[1], songs[12]],
    ),
  ];
}

/// Icon name constants (decoupled from Material imports in data files).
abstract class IconsName {
  static const celebration = 'celebration';
  static const musicNote = 'music_note';
  static const cloud = 'cloud';
  static const mic = 'mic';
  static const spa = 'spa';
  static const centerFocus = 'center_focus';
  static const favorite = 'favorite';
  static const fitness = 'fitness';
}