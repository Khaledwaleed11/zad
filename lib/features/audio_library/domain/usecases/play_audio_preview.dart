import '../repositories/audio_preview_repository.dart';

class PlayAudioPreview {
  final AudioPreviewRepository repository;

  PlayAudioPreview(this.repository);

  Future<void> call(String filePath) {
    return repository.play(filePath);
  }
}