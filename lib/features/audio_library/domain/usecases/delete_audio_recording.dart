import '../repositories/audio_library_repository.dart';

class DeleteAudioRecording {
  final AudioLibraryRepository repository;

  DeleteAudioRecording(this.repository);

  Future<void> call(String id) {
    return repository.deleteRecording(id);
  }
}