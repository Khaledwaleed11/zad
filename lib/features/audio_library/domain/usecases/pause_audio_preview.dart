import '../repositories/audio_preview_repository.dart';

class PauseAudioPreview {
  final AudioPreviewRepository repository;

  PauseAudioPreview(this.repository);

  Future<void> call() {
    return repository.pause();
  }
}