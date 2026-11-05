
import '../entities/dua_category_entity.dart';
import '../entities/written_dua_entity.dart';

abstract class WrittenDuaRepository {
  Future<List<DuaCategoryEntity>> getCategories();

  Future<List<WrittenDuaEntity>> getAllDuas();

  Future<List<WrittenDuaEntity>> getDuasByCategory(
      String categoryId,
      );

  Future<List<WrittenDuaEntity>> searchDuas(
      String query,
      );

  Future<List<String>> getFavoriteDuaIds();

  Future<void> toggleFavorite(String duaId);
}
