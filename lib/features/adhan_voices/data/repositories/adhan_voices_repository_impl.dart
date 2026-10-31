import '../../domain/entities/adhan_voice_entity.dart';
import '../../domain/repositories/adhan_voices_repository.dart';
import '../datasources/adhan_voices_local_data_source.dart';
import '../datasources/adhan_voices_remote_data_source.dart';
import '../datasources/adhan_audio_cache_data_source.dart';

class AdhanVoicesRepositoryImpl implements AdhanVoicesRepository {
  final AdhanVoicesRemoteDataSource remoteDataSource;
  final AdhanVoicesLocalDataSource localDataSource;
  final AdhanAudioCacheDataSource audioCacheDataSource;

  AdhanVoicesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.audioCacheDataSource,
  });

  @override
  Future<List<AdhanVoiceEntity>> getAdhanVoices() async {
    final voices = await remoteDataSource.getAdhanVoices();
    return voices.map((voice) => voice.toEntity()).toList();
  }

  @override
  Future<void> saveSelectedVoiceId(String voiceId) {
    return localDataSource.saveSelectedVoiceId(voiceId);
  }

  @override
  String? getSelectedVoiceId() {
    return localDataSource.getSelectedVoiceId();
  }

  @override
  Future<String> cacheAdhanVoice({
    required String voiceId,
    required String audioUrl,
  }) {
    return audioCacheDataSource.cacheAudio(
      voiceId: voiceId,
      audioUrl: audioUrl,
    );
  }
  @override
  Future<String?> getCachedAdhanVoicePath(String voiceId) {
    return audioCacheDataSource.getCachedAudioPath(voiceId);
  }
}