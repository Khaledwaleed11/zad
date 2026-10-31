import '../../domain/entities/audio_recording_entity.dart';
import '../../domain/repositories/audio_library_repository.dart';
import '../datasources/audio_library_local_data_source.dart';

class AudioLibraryRepositoryImpl implements AudioLibraryRepository {
  final AudioLibraryLocalDataSource localDataSource;

  AudioLibraryRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<AudioRecordingEntity?> addRecording({
    required String name,
    required AudioRecordingType type,
    int? surahNumber,
  }) async {
    return await localDataSource.addRecording(
      name: name,
      type: type,
      surahNumber: surahNumber,
    );
  }

  @override
  Future<List<AudioRecordingEntity>> getRecordings({
    AudioRecordingType? type,
  }) async {
    return localDataSource.getRecordings(type: type);
  }

  @override
  Future<void> deleteRecording(String id) async {
    await localDataSource.deleteRecording(id);
  }
}