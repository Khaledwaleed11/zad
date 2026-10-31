enum AudioPreviewStatus {
  idle,
  loading,
  playing,
  paused,
  completed,
}

abstract class AudioPreviewRepository {
  AudioPreviewStatus get status;

  Stream<AudioPreviewStatus> get statusStream;

  Future<void> play(String filePath);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  Future<void> dispose();
}