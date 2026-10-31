import '../repositories/adhan_voices_repository.dart';

class CacheAdhanVoice {
  final AdhanVoicesRepository repository;

  CacheAdhanVoice(this.repository);

  Future<String> call({
    required String voiceId,
    required String audioUrl,
  }) {
    return repository.cacheAdhanVoice(
      voiceId: voiceId,
      audioUrl: audioUrl,
    );
  }
}