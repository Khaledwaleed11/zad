import '../entities/audio_recording_entity.dart';

abstract class AudioLibraryRepository {
  Future<AudioRecordingEntity?> addRecording({
    required String name,
    required AudioRecordingType type,
    int? surahNumber,
  });

  Future<List<AudioRecordingEntity>> getRecordings({
    AudioRecordingType? type,
  });

  Future<void> deleteRecording(String id);
}