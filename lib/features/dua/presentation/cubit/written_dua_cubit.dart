
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dua_category_entity.dart';
import '../../domain/entities/written_dua_entity.dart';

import '../../domain/usecases/written/get_dua_categories.dart';
import '../../domain/usecases/written/get_all_duas.dart';
import '../../domain/usecases/written/get_duas_by_category.dart';
import '../../domain/usecases/written/get_favorite_dua_ids.dart';
import '../../domain/usecases/written/search_duas.dart';
import '../../domain/usecases/written/toggle_dua_favorite.dart';

import 'written_dua_state.dart';

class WrittenDuaCubit extends Cubit<WrittenDuaState> {
  final GetDuaCategories getDuaCategories;
  final GetAllDuas getAllDuas;
  final GetDuasByCategory getDuasByCategory;
  final SearchDuas searchDuas;
  final GetFavoriteDuaIds getFavoriteDuaIds;
  final ToggleDuaFavorite toggleDuaFavorite;

  WrittenDuaCubit({
    required this.getDuaCategories,
    required this.getAllDuas,
    required this.getDuasByCategory,
    required this.searchDuas,
    required this.getFavoriteDuaIds,
    required this.toggleDuaFavorite,
  }) : super(const WrittenDuaState());


  Future<void> loadInitialData() async {
    emit(
      state.copyWith(
        status: WrittenDuaStatus.loading,
        clearError: true,
      ),
    );

    try {
      final minimumLoadingDuration = Future.delayed(
        const Duration(milliseconds: 600),
      );

      final results = await Future.wait<Object>([
        getDuaCategories(),
        getAllDuas(),
        getFavoriteDuaIds(),
      ]);

      await minimumLoadingDuration;

      final categories = results[0] as List<DuaCategoryEntity>;
      final duas = results[1] as List<WrittenDuaEntity>;
      final favorites = results[2] as List<String>;

      emit(
        state.copyWith(
          status: WrittenDuaStatus.success,
          categories: categories,
          duas: duas,
          favoriteIds: favorites,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('WrittenDuaCubit loadInitialData: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(
        state.copyWith(
          status: WrittenDuaStatus.failure,
          errorMessage: 'Failed to load duas.',
        ),
      );
    }
  }

  Future<void> selectCategory(String? categoryId) async {
    emit(state.copyWith(
      selectedCategoryId: categoryId,
      clearSelectedCategory: categoryId == null,
    ));

    await _loadFilteredDuas();
  }

  Future<void> search(String query) async {
    emit(state.copyWith(searchQuery: query));
    await _loadFilteredDuas();
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(
      searchQuery: '',
      clearSelectedCategory: true,
    ));

    await _loadFilteredDuas();
  }

  Future<void> _loadFilteredDuas() async {
    try {
      List<WrittenDuaEntity> results;

      if (state.searchQuery.trim().isNotEmpty) {
        results = await searchDuas(state.searchQuery.trim());
      } else if (state.selectedCategoryId != null) {
        results = await getDuasByCategory(state.selectedCategoryId!);
      } else {
        results = await getAllDuas();
      }

      if (state.selectedCategoryId != null &&
          state.searchQuery.trim().isNotEmpty) {
        results = results
            .where(
              (dua) => dua.categoryId == state.selectedCategoryId,
        )
            .toList();
      }

      emit(state.copyWith(
        status: WrittenDuaStatus.success,
        duas: results,
        clearError: true,
      ));
    } catch (e, stackTrace) {
      debugPrint('WrittenDuaCubit _loadFilteredDuas: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(state.copyWith(
        status: WrittenDuaStatus.failure,
        errorMessage: 'Failed to filter duas.',
      ));
    }
  }

  Future<void> toggleFavorite(String duaId) async {
    try {
      await toggleDuaFavorite(duaId);

      final favorites = await getFavoriteDuaIds();

      emit(state.copyWith(favoriteIds: favorites));
    } catch (e, stackTrace) {
      debugPrint('WrittenDuaCubit toggleFavorite: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await getFavoriteDuaIds();

      emit(state.copyWith(favoriteIds: favorites));
    } catch (e, stackTrace) {
      debugPrint('WrittenDuaCubit loadFavorites: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
