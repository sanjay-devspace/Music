import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/models/player_state_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/music/music_service.dart';

/// Audio playback engine.
///
/// Wraps `just_audio` and exposes a small state stream the player controller
/// subscribes to. The service stays active while the app navigates, which
/// keeps music playing across screens.
class PlayerService {
  PlayerService({required this._musicService}) {
    _player.positionStream.listen((position) {
      _position = position;
      _emit();
    });
    _player.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      _emit();
    });
    _player.playerStateStream.listen((playerState) {
      _state = switch (playerState.processingState) {
        ProcessingState.idle => PlaybackState.idle,
        ProcessingState.loading => PlaybackState.loading,
        ProcessingState.buffering => PlaybackState.buffering,
        ProcessingState.ready =>
          playerState.playing ? PlaybackState.playing : PlaybackState.paused,
        ProcessingState.completed => PlaybackState.idle,
      };
      _emit();
    });
  }

  final MusicService _musicService;
  final AudioPlayer _player = AudioPlayer();
  final StreamController<PlayerStateModel> _stateController =
      StreamController<PlayerStateModel>.broadcast();

  SongModel? _currentSong;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlaybackState _state = PlaybackState.idle;
  bool _shuffle = false;
  RepeatMode _repeat = RepeatMode.off;
  double _volume = 1.0;

  // Callback for automatic progression through an ambient queue.
  VoidCallback? onTrackEnded;

  PlayerStateModel get current =>
      _buildState();

  Stream<PlayerStateModel> get stream => _stateController.stream;

  PlayerStateModel _buildState() => PlayerStateModel(
        currentSong: _currentSong,
        state: _state,
        position: _position,
        duration: _duration,
        isShuffle: _shuffle,
        repeatMode: _repeat,
        volume: _volume,
      );

  void _emit() {
    if (!_stateController.isClosed) {
      _stateController.add(_buildState());
    }
  }

  // ---- Playback control ----------------------------------------------------

  /// Play a song from any provider. `streamUrl` falls back to a live fetch.
  Future<void> play(SongModel song, {String? streamUrl}) async {
    try {
      _currentSong = song;
      _emit();
      final url = streamUrl ?? song.audioUrl ?? await _musicService.getStreamUrl(song.id);
      debugPrint('PlayerService: Playing url: $url');
      if (url == null || url.isEmpty) {
        _duration = song.duration;
        _position = Duration.zero;
        _state = PlaybackState.playing;
        _startFakeTicker(song.duration);
        _emit();
        return;
      }
      _tickerSub?.cancel();
      _fakeTicker?.cancel();
      _fakeTicker = null;
      _tickerSub = null;
      
      final uri = Uri.parse(url);
      await _player.setAudioSource(
        AudioSource.uri(uri),
      ).timeout(const Duration(seconds: 10));
      _player.play();
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('PlayerService error: $e');
      throw PlaybackException(
        message: 'Playback could not be started for "${song.title}".',
        cause: e,
      );
    }
  }

  Future<void> pause() async {
    _state = PlaybackState.paused;
    _emit();
    if (_fakeTicker != null) {
      _tickerSub?.cancel();
      _tickerSub = null;
    }
    await _player.pause();
  }

  Future<void> resume() async {
    if (_fakeTicker != null) {
      _tickerSub ??= Timer.periodic(const Duration(seconds: 1), (_) {
        _position += const Duration(seconds: 1);
        _emit();
      });
    }
    await _player.play();
  }

  Future<void> seek(Duration position) async {
    _position = position;
    _emit();
    await _player.seek(position);
  }

  Future<void> next() async {
    final ended = onTrackEnded;
    if (ended != null) ended();
  }

  Future<void> previous() async {
    if (_position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    final ended = onTrackEnded;
    if (ended != null) ended();
  }

  Future<void> stop() async {
    _tickerSub?.cancel();
    _tickerSub = null;
    await _player.stop();
    _currentSong = null;
    _state = PlaybackState.idle;
    _emit();
  }

  void setShuffle(bool enabled) {
    _shuffle = enabled;
    _emit();
  }

  void cycleRepeat() {
    _repeat = switch (_repeat) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    _emit();
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _player.setVolume(_volume);
    _emit();
  }

  // ---- Simulated playback (mock / licensing-limited providers) -------------
  Timer? _fakeTicker;
  Timer? _tickerSub;

  void _startFakeTicker(Duration duration) {
    _tickerSub?.cancel();
    _fakeTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _position += const Duration(seconds: 1);
      if (_position >= duration) {
        _tickerSub?.cancel();
        _position = Duration.zero;
        onTrackEnded?.call();
      } else {
        _emit();
      }
    });
    if (duration == Duration.zero) {
      // Non-zero safety so endless fake playback never stalls the UI.
      onTrackEnded?.call();
    }
  }

  void dispose() {
    _tickerSub?.cancel();
    _stateController.close();
    _player.dispose();
  }
}