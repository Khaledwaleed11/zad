import '../repositories/audio_preview_repository.dart';

class ResumeAudioPreview {
  final AudioPreviewRepository repository;

  ResumeAudioPreview(this.repository);

  Future<void> call() {
    return repository.resume();
  }
}