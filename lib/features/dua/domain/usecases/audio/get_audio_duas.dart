
import '../../repositories/audio_dua_repository.dart';
import '../../entities/audio_dua_entity.dart';

class GetAudioDuas {
  final AudioDuaRepository repository;

  GetAudioDuas(this.repository);

  Future<List<AudioDuaEntity>> call() {
    return repository.getAudioDuas();
  }
}
