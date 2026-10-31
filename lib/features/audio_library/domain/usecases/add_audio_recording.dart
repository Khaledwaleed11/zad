import '../entities/audio_recording_entity.dart';
import '../repositories/audio_library_repository.dart';

class AddAudioRecording {
  final AudioLibraryRepository repository;

  AddAudioRecording(this.repository);

  Future<AudioRecordingEntity?> call({
    required String name,
    required AudioRecordingType type,
    int? surahNumber,
  }) {
    return repository.addRecording(
      name: name,
      type: type,
      surahNumber: surahNumber,
    );
  }
}