import '../repositories/adhan_voices_repository.dart';

class GetCachedAdhanVoicePath {
  final AdhanVoicesRepository repository;

  GetCachedAdhanVoicePath(this.repository);

  Future<String?> call(String voiceId) {
    return repository.getCachedAdhanVoicePath(voiceId);
  }
}