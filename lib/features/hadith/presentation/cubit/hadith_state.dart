
import 'package:equatable/equatable.dart';

import '../../domain/entities/hadith_entity.dart';
import '../../domain/entities/hadith_search_result_entity.dart';

class HadithState extends Equatable {
  final HadithEntity? hadithOfTheDay;
  final HadithEntity? selectedHadith;
  final List<HadithSearchResultEntity> searchResults;

  final bool isLoadingDaily;
  final bool isLoadingSearch;
  final bool isLoadingDetails;

  final String? errorMessage;

  const HadithState({
    this.hadithOfTheDay,
    this.selectedHadith,
    this.searchResults = const [],
    this.isLoadingDaily = false,
    this.isLoadingSearch = false,
    this.isLoadingDetails = false,
    this.errorMessage,
  });

  HadithState copyWith({
    HadithEntity? hadithOfTheDay,
    HadithEntity? selectedHadith,
    List<HadithSearchResultEntity>? searchResults,
    bool? isLoadingDaily,
    bool? isLoadingSearch,
    bool? isLoadingDetails,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedHadith = false,
  }) {
    return HadithState(
      hadithOfTheDay: hadithOfTheDay ?? this.hadithOfTheDay,
      selectedHadith: clearSelectedHadith
          ? null
          : selectedHadith ?? this.selectedHadith,
      searchResults: searchResults ?? this.searchResults,
      isLoadingDaily: isLoadingDaily ?? this.isLoadingDaily,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    hadithOfTheDay,
    selectedHadith,
    searchResults,
    isLoadingDaily,
    isLoadingSearch,
    isLoadingDetails,
    errorMessage,
  ];
}
