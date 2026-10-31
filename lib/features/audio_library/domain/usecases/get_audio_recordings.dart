import '../entities/audio_recording_entity.dart';
import '../repositories/audio_library_repository.dart';

class GetAudioRecordings {
  final AudioLibraryRepository repository;

  GetAudioRecordings(this.repository);

  Future<List<AudioRecordingEntity>> call({
    AudioRecordingType? type,
  }) {
    return repository.getRecordings(type: type);
  }
}