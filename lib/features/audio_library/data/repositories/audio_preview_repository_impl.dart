import 'package:just_audio/just_audio.dart';

import '../../domain/repositories/audio_preview_repository.dart';
import '../datasources/audio_preview_data_source.dart';

class AudioPreviewRepositoryImpl implements AudioPreviewRepository {
  final AudioPreviewDataSource dataSource;

  AudioPreviewRepositoryImpl({
    required this.dataSource,
  });

  AudioPreviewStatus _mapStatus(PlayerState state) {
    switch (state.processingState) {
      case ProcessingState.idle:
        return AudioPreviewStatus.idle;

      case ProcessingState.loading:
      case ProcessingState.buffering:
        return state.playing
            ? AudioPreviewStatus.playing
            : AudioPreviewStatus.loading;

      case ProcessingState.ready:
        return state.playing
            ? AudioPreviewStatus.playing
            : AudioPreviewStatus.paused;

      case ProcessingState.completed:
        return AudioPreviewStatus.completed;
    }
  }

  @override
  AudioPreviewStatus get status => _mapStatus(dataSource.playerState);

  @override
  Stream<AudioPreviewStatus> get statusStream =>
      dataSource.playerStateStream
          .map(_mapStatus)
          .distinct();

  @override
  Future<void> play(String filePath) {
    return dataSource.play(filePath);
  }

  @override
  Future<void> pause() {
    return dataSource.pause();
  }

  @override
  Future<void> resume() {
    return dataSource.resume();
  }

  @override
  Future<void> stop() {
    return dataSource.stop();
  }

  @override
  Future<void> dispose() {
    return dataSource.dispose();
  }
}