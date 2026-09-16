import 'dart:async';

import 'package:get/get.dart';
import 'package:tunehive/models/player_state_model.dart';
import 'package:tunehive/models/queue_item_model.dart';
import 'package:tunehive/models/song_model.dart';
import 'package:tunehive/services/player/player_service.dart';

/// Global playback controller.
///
/// Owns the observable player state shared across the whole app: song,
/// playing status, position, progress, queue and favorites. Because it is a
/// singleton scoped to the app, music continues while navigating between
/// Home, Search, Library and Profile.
class PlayerController extends GetxController {
  PlayerController(this._playerService);

  final PlayerService _playerService;

  final Rx<SongModel?> song = Rxn<SongModel>(null);
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool isShuffle = false.obs;
  final Rx<RepeatMode> repeatMode = RepeatMode.off.obs;

  final Rx<QueueItemModel> currentQueueItem = Rx<QueueItemModel>(QueueItemModel.empty);
  final RxList<QueueItemModel> queue = <QueueItemModel>[].obs;
  final RxInt queueIndex = 0.obs;

  /// Favorited song ids — a lightweight client-side collection so the heart
  /// toggles instantly everywhere (persists to a remote store later).
  final RxSet<String> likedIds = <String>{}.obs;

  StreamSubscription<PlayerStateModel>? _sub;

  bool get hasSong => song.value != null;
  SongModel? get currentSong => song.value;

  @override
  void onInit() {
    super.onInit();
    _sub = _playerService.stream.listen(_applyState);
    _playerService.onTrackEnded = _handleTrackEnded;
  }

  void _applyState(PlayerStateModel state) {
    song.value = state.currentSong;
    isPlaying.value = state.isPlaying;
    isLoading.value = state.state == PlaybackState.loading ||
        state.state == PlaybackState.buffering;
    position.value = state.position;
    duration.value = state.duration;
    progress.value = state.progress;
    isShuffle.value = state.isShuffle;
    repeatMode.value = state.repeatMode;
  }

  // ---- Playback -----------------------------------------------------------

  /// Play a song, optionally enqueueing the rest of the list it came from.
  Future<void> play(SongModel track, {List<SongModel>? fromList}) async {
    if (fromList != null && fromList.length > 1) {
      _buildQueue(track, fromList);
    }
    _applySong(track);
    await _playerService.play(track);
  }

  Future<void> togglePlayPause() async {
    if (song.value == null) return;
    if (isPlaying.value) {
      await _playerService.pause();
    } else {
      await _playerService.resume();
    }
  }

  Future<void> next() async {
    if (queue.isEmpty) return;
    final index = queueIndex.value + 1;
    if (index >= queue.length) {
      if (repeatMode.value == RepeatMode.all) {
        _playQueueItem(0);
      }
      return;
    }
    _playQueueItem(index);
  }

  Future<void> previous() async {
    if (position.value > const Duration(seconds: 3) ||
        hasSong == false) {
      await seek(Duration.zero);
      return;
    }
    if (queue.isEmpty) return;
    final index = queueIndex.value - 1;
    if (index < 0) {
      await seek(Duration.zero);
      return;
    }
    _playQueueItem(index);
  }

  Future<void> seek(Duration to) async => _playerService.seek(to);

  Future<void> seekToFraction(double fraction) async {
    final total = duration.value;
    if (total == Duration.zero) return;
    await seek(Duration(milliseconds: (total.inMilliseconds * fraction).round()));
  }

  void toggleShuffle() {
    final enabled = !isShuffle.value;
    _playerService.setShuffle(enabled);
  }

  void cycleRepeat() {
    _playerService.cycleRepeat();
  }

  Future<void> playFromQueue(int index) async {
    if (index >= 0 && index < queue.length) {
      _playQueueItem(index);
    }
  }

  // ---- Favorites ----------------------------------------------------------

  bool isLiked(String songId) => likedIds.contains(songId);

  void toggleFavorite([SongModel? track]) {
    final t = track ?? song.value;
    if (t == null) return;
    if (likedIds.contains(t.id)) {
      likedIds.remove(t.id);
    } else {
      likedIds.add(t.id);
    }
  }

  // ---- Queue --------------------------------------------------------------

  void _buildQueue(SongModel track, List<SongModel> songs) {
    final items = <QueueItemModel>[
      for (final s in songs) QueueItemModel(song: s),
    ];
    final start = items.indexWhere((q) => q.song.id == track.id);
    queueIndex.value = start < 0 ? 0 : start;
    queue.value = items;
    currentQueueItem.value = items[queueIndex.value];
  }

  void _applySong(SongModel track) {
    song.value = track;
    duration.value = track.duration;
    position.value = Duration.zero;
    progress.value = 0;
  }

  void _handleTrackEnded() {
    if (repeatMode.value == RepeatMode.one && song.value != null) {
      _playerService.seek(Duration.zero);
      return;
    }
    // Instead of auto-advancing, keep the current song selected.
    _playerService.seek(Duration.zero);
    _playerService.pause();
  }

  Future<void> _playQueueItem(int index) async {
    if (index < 0 || index >= queue.length) return;
    queueIndex.value = index;
    final item = queue[index];
    currentQueueItem.value = item;
    _applySong(item.song);
    await _playerService.play(item.song);
  }

  void removeQueueItem(int index) {
    if (index < 0 || index >= queue.length) return;
    queue.removeAt(index);
    if (queueIndex.value > index) queueIndex.value--;
    if (queueIndex.value >= queue.length) queueIndex.value = queue.length - 1;
  }

  void clearQueue() {
    queue.clear();
    queueIndex.value = 0;
    currentQueueItem.value = QueueItemModel.empty;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}