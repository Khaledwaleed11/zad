import '../repositories/audio_preview_repository.dart';

class StopAudioPreview {
  final AudioPreviewRepository repository;

  StopAudioPreview(this.repository);

  Future<void> call() {
    return repository.stop();
  }
}