import 'package:tunehive/models/song_model.dart';

enum AudioSourceType {
  full,
  preview,
  none,
}

class ResolvedAudioSource {
  const ResolvedAudioSource({
    required this.url,
    required this.type,
  });

  final String url;
  final AudioSourceType type;
}

class AudioSourceResolver {
  const AudioSourceResolver();

  Future<ResolvedAudioSource?> resolve(SongModel track) async {
    if (track.audioUrl != null && track.audioUrl!.isNotEmpty) {
      return ResolvedAudioSource(
        url: track.audioUrl!,
        type: AudioSourceType.full,
      );
    }
    
    if (track.previewUrl != null && track.previewUrl!.isNotEmpty) {
      return ResolvedAudioSource(
        url: track.previewUrl!,
        type: AudioSourceType.preview,
      );
    }
    
    return null;
  }
}
