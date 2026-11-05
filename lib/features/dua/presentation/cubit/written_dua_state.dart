import 'package:equatable/equatable.dart';

import '../../domain/entities/dua_category_entity.dart';
import '../../domain/entities/written_dua_entity.dart';

enum WrittenDuaStatus {
  initial,
  loading,
  success,
  failure,
}

class WrittenDuaState extends Equatable {
  final WrittenDuaStatus status;
  final List<DuaCategoryEntity> categories;
  final List<WrittenDuaEntity> duas;
  final List<String> favoriteIds;
  final String? errorMessage;
  final String? selectedCategoryId;
  final String searchQuery;

  const WrittenDuaState({
    this.status = WrittenDuaStatus.initial,
    this.categories = const [],
    this.duas = const [],
    this.favoriteIds = const [],
    this.errorMessage,
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  WrittenDuaState copyWith({
    WrittenDuaStatus? status,
    List<DuaCategoryEntity>? categories,
    List<WrittenDuaEntity>? duas,
    List<String>? favoriteIds,
    String? errorMessage,
    String? selectedCategoryId,
    String? searchQuery,
    bool clearError = false,
    bool clearSelectedCategory = false,
  }) {
    return WrittenDuaState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      duas: duas ?? this.duas,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedCategoryId: clearSelectedCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    duas,
    favoriteIds,
    errorMessage,
    selectedCategoryId,
    searchQuery,
  ];
}