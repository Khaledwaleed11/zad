
import '../../repositories/written_dua_repository.dart';
import '../../entities/written_dua_entity.dart';

class SearchDuas {
  final WrittenDuaRepository repository;

  SearchDuas(this.repository);

  Future<List<WrittenDuaEntity>> call(String query) {
    return repository.searchDuas(query);
  }
}
