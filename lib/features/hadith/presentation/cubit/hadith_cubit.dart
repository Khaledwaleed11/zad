
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hadith_entity.dart';
import '../../domain/usecases/get_hadith_details.dart';
import '../../domain/usecases/get_hadith_of_the_day.dart';
import '../../domain/usecases/get_random_hadith.dart';
import '../../domain/usecases/search_hadith.dart';
import 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  final SearchHadith searchHadithUseCase;
  final GetHadithDetails getHadithDetailsUseCase;
  final GetHadithOfTheDay getHadithOfTheDayUseCase;
  final GetRandomHadith getRandomHadithUseCase;

  HadithCubit({
    required this.searchHadithUseCase,
    required this.getHadithDetailsUseCase,
    required this.getHadithOfTheDayUseCase,
    required this.getRandomHadithUseCase,
  }) : super(const HadithState());

  Future<void> loadHadithOfTheDay() async {
    if (state.isLoadingDaily) return;

    emit(state.copyWith(
      isLoadingDaily: true,
      clearError: true,
    ));

    try {
      final hadith = await getHadithOfTheDayUseCase();

      emit(state.copyWith(
        hadithOfTheDay: hadith,
        isLoadingDaily: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDaily: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadAnotherHadith() async {
    if (state.isLoadingDaily) return;

    emit(state.copyWith(
      isLoadingDaily: true,
      clearError: true,
    ));

    try {
      final currentSeq = state.hadithOfTheDay?.seq;

      final hadith = await getRandomHadithUseCase(
        excludeSeq: currentSeq,
      );

      emit(state.copyWith(
        hadithOfTheDay: hadith,
        isLoadingDaily: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDaily: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    emit(state.copyWith(
      isLoadingSearch: true,
      clearError: true,
    ));

    try {
      final results = await searchHadithUseCase(query.trim());

      emit(state.copyWith(
        searchResults: results,
        isLoadingSearch: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingSearch: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadHadithDetails(String apiUrl) async {
    emit(state.copyWith(
      isLoadingDetails: true,
      clearError: true,
    ));

    try {
      final hadith = await getHadithDetailsUseCase(apiUrl);

      emit(state.copyWith(
        selectedHadith: hadith,
        isLoadingDetails: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetails: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void clearSearch() {
    emit(state.copyWith(
      searchResults: [],
      clearError: true,
    ));
  }
}
