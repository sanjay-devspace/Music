import 'song_model.dart';

/// A track queued for playback after the current song.
class QueueItemModel {
  QueueItemModel({
    required this.song,
    DateTime? playedAt,
    this.isCurrent = false,
  }) : playedAt = playedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Empty placeholder for the "no queue" state.
  static final QueueItemModel empty = QueueItemModel(
    song: const SongModel(id: '', title: '', artistName: ''),
  );

  final SongModel song;
  final DateTime playedAt;
  final bool isCurrent;

  QueueItemModel copyWith({bool? isCurrent}) => QueueItemModel(
        song: song,
        playedAt: playedAt,
        isCurrent: isCurrent ?? this.isCurrent,
      );
}