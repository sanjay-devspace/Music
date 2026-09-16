import 'song_model.dart';

/// Enumeration of the playback engine's canonical states.
enum PlaybackState {
  idle,
  loading,
  playing,
  paused,
  buffering,
  error,
}

/// Immutable snapshot of the player's UI-relevant state.
class PlayerStateModel {
  const PlayerStateModel({
    this.currentSong,
    this.state = PlaybackState.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
    this.audioUrl,
  });

  final SongModel? currentSong;
  final PlaybackState state;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final double volume;
  final String? audioUrl;

  bool get isPlaying => state == PlaybackState.playing;
  bool get hasSong => currentSong != null;
  double get progress =>
      duration == Duration.zero ? 0 : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  PlayerStateModel copyWith({
    SongModel? currentSong,
    bool clearSong = false,
    PlaybackState? state,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    RepeatMode? repeatMode,
    double? volume,
    String? audioUrl,
  }) {
    return PlayerStateModel(
      currentSong: clearSong ? null : (currentSong ?? this.currentSong),
      state: state ?? this.state,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  PlayerStateModel copyWithSong(SongModel? song) => PlayerStateModel(
        currentSong: song,
        state: song == null ? PlaybackState.idle : state,
        position: song == null ? Duration.zero : position,
        duration: song == null ? Duration.zero : duration,
        isShuffle: isShuffle,
        repeatMode: song == null ? RepeatMode.off : repeatMode,
        volume: volume,
        audioUrl: song == null ? null : audioUrl,
      );
}

enum RepeatMode { off, all, one }