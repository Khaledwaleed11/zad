import 'package:hive/hive.dart';

import '../../domain/entities/dua_category_entity.dart';
import '../../domain/entities/written_dua_entity.dart';
import '../../domain/repositories/written_dua_repository.dart';
import '../datasources/written_dua_local_data_source.dart';

class WrittenDuaRepositoryImpl implements WrittenDuaRepository {
  final WrittenDuaLocalDataSource localDataSource;
  final Box<dynamic> favoritesBox;

  WrittenDuaRepositoryImpl({
    required this.localDataSource,
    required this.favoritesBox,
  });

  @override
  Future<List<DuaCategoryEntity>> getCategories() async {
    return localDataSource.getCategories();
  }

  @override
  Future<List<WrittenDuaEntity>> getAllDuas() async {
    return localDataSource.getAllDuas();
  }

  @override
  Future<List<WrittenDuaEntity>> getDuasByCategory(
      String categoryId,
      ) async {
    return localDataSource.getDuasByCategory(categoryId);
  }

  @override
  Future<List<WrittenDuaEntity>> searchDuas(String query) async {
    return localDataSource.searchDuas(query);
  }

  @override
  Future<List<String>> getFavoriteDuaIds() async {
    return favoritesBox.keys
        .where((key) => favoritesBox.get(key) == true)
        .map((key) => key.toString())
        .toList();
  }

  @override
  Future<void> toggleFavorite(String duaId) async {
    final isFavorite = favoritesBox.get(duaId) == true;

    if (isFavorite) {
      await favoritesBox.delete(duaId);
    } else {
      await favoritesBox.put(duaId, true);
    }
  }
}