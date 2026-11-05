
import '../../repositories/written_dua_repository.dart';

class ToggleDuaFavorite {
  final WrittenDuaRepository repository;

  ToggleDuaFavorite(this.repository);

  Future<void> call(String duaId) {
    return repository.toggleFavorite(duaId);
  }
}
