
import '../repositories/adhan_voices_repository.dart';

class GetSelectedAdhanVoice {
  final AdhanVoicesRepository repository;

  GetSelectedAdhanVoice(this.repository);

  String? call() {
    return repository.getSelectedVoiceId();
  }
}
