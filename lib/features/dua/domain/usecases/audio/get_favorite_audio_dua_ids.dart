
import '../../repositories/audio_dua_repository.dart';

class GetFavoriteAudioDuaIds {
  final AudioDuaRepository repository;

  GetFavoriteAudioDuaIds(this.repository);

  Future<List<String>> call() {
    return repository.getFavoriteAudioDuaIds();
  }
}
