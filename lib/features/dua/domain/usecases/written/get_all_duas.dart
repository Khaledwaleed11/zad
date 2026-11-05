
import '../../repositories/written_dua_repository.dart';
import '../../entities/written_dua_entity.dart';

class GetAllDuas {
  final WrittenDuaRepository repository;

  GetAllDuas(this.repository);

  Future<List<WrittenDuaEntity>> call() {
    return repository.getAllDuas();
  }
}
