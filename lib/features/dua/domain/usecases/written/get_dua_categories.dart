
import '../../repositories/written_dua_repository.dart';
import '../../entities/dua_category_entity.dart';

class GetDuaCategories {
  final WrittenDuaRepository repository;

  GetDuaCategories(this.repository);

  Future<List<DuaCategoryEntity>> call() {
    return repository.getCategories();
  }
}
