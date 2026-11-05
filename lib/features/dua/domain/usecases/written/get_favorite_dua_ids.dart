
import '../../repositories/written_dua_repository.dart';

class GetFavoriteDuaIds {
  final WrittenDuaRepository repository;

  GetFavoriteDuaIds(this.repository);

  Future<List<String>> call() {
    return repository.getFavoriteDuaIds();
  }
}
