
import '../../repositories/written_dua_repository.dart';
import '../../entities/written_dua_entity.dart';

class GetDuasByCategory {
  final WrittenDuaRepository repository;

  GetDuasByCategory(this.repository);

  Future<List<WrittenDuaEntity>> call(String categoryId) {
    return repository.getDuasByCategory(categoryId);
  }
}
