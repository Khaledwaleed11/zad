
import '../entities/adhan_voice_entity.dart';
import '../repositories/adhan_voices_repository.dart';

class GetAdhanVoices {
  final AdhanVoicesRepository repository;

  GetAdhanVoices(this.repository);

  Future<List<AdhanVoiceEntity>> call() {
    return repository.getAdhanVoices();
  }
}
