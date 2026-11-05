
import '../../repositories/audio_dua_repository.dart';

class ToggleAudioDuaFavorite {
  final AudioDuaRepository repository;

  ToggleAudioDuaFavorite(this.repository);

  Future<void> call(String duaId) {
    return repository.toggleFavorite(duaId);
  }
}
