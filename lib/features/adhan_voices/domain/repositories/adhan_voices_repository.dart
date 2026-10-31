import '../entities/adhan_voice_entity.dart';

abstract class AdhanVoicesRepository {
  Future<List<AdhanVoiceEntity>> getAdhanVoices();

  Future<void> saveSelectedVoiceId(String voiceId);

  String? getSelectedVoiceId();

  Future<String> cacheAdhanVoice({
    required String voiceId,
    required String audioUrl,
  });

  Future<String?> getCachedAdhanVoicePath(String voiceId);
}