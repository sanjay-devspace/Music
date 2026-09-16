import 'song_model.dart';

/// A track queued for playback after the current song.
class QueueItemModel {
  const QueueItemModel({
    required this.song,
    required this.playedAt,
    this.isCurrent = false,
  });

  final SongModel song;
  final DateTime playedAt;
  final bool isCurrent;

  QueueItemModel copyWith({bool? isCurrent}) => QueueItemModel(
        song: song,
        playedAt: playedAt,
        isCurrent: isCurrent ?? this.isCurrent,
      );
}