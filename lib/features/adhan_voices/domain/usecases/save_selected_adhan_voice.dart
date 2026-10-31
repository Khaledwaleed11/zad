
import '../repositories/adhan_voices_repository.dart';

class SaveSelectedAdhanVoice {
  final AdhanVoicesRepository repository;

  SaveSelectedAdhanVoice(this.repository);

  Future<void> call(String voiceId) {
    return repository.saveSelectedVoiceId(voiceId);
  }
}
