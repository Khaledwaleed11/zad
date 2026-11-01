import 'dart:math';

import '../../domain/entities/hadith_entity.dart';
import '../../domain/entities/hadith_search_result_entity.dart';
import '../../domain/repositories/hadith_repository.dart';
import '../datasources/hadith_local_data_source.dart';
import '../datasources/hadith_remote_data_source.dart';
import '../models/hadith_model.dart';
import '../models/hadith_search_result_model.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithRemoteDataSource remoteDataSource;
  final HadithLocalDataSource localDataSource;
  final Random random;

  static const int _maxHadithNumber = 7563;
  static const int _maxAttempts = 20;

  HadithRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    Random? random,
  }) : random = random ?? Random();

  @override
  Future<List<HadithSearchResultEntity>> searchHadith(String query) async {
    final response = await remoteDataSource.searchHadith(query);
    final hadithList = response['hadith'];

    if (hadithList is! List) {
      return [];
    }

    return hadithList
        .whereType<Map>()
        .map(
          (item) => HadithSearchResultModel.fromJson(
            Map<String, dynamic>.from(item),
          ).toEntity(),
        )
        .toList();
  }

  @override
  Future<HadithEntity> getHadithDetails(String apiUrl) async {
    final response = await remoteDataSource.getHadithDetails(apiUrl);
    return HadithModel.fromJson(response).toEntity();
  }

  @override
  Future<HadithEntity> getHadithOfTheDay() async {
    final today = _getTodayDate();
    final savedDate = localDataSource.getDailyHadithDate();
    final savedApiUrl = localDataSource.getDailyHadithApiUrl();

    if (savedDate == today && savedApiUrl != null) {
      final savedHadith = await getHadithDetails(savedApiUrl);

      if (savedHadith.book == 'sahih-al-bukhari') {
        return savedHadith;
      }
    }

    return getRandomHadith();
  }

  @override
  Future<HadithEntity> getRandomHadith({int? excludeSeq}) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final number = random.nextInt(_maxHadithNumber) + 1;

      try {
        final response = await remoteDataSource.getHadithByNumber(number);
        final hadith = HadithModel.fromJson(response).toEntity();

        if (hadith.book != 'sahih-al-bukhari') {
          continue;
        }

        // Avoid returning the currently displayed hadith.
        if (excludeSeq != null && hadith.seq == excludeSeq) {
          continue;
        }

        final apiUrl =
            'https://bayan.alwa7i.com/api/hadith/sahih-al-bukhari?number=$number';

        await localDataSource.saveDailyHadith(
          apiUrl: apiUrl,
          date: _getTodayDate(),
        );

        return hadith;
      } catch (e) {
        // Retry if the selected number is unavailable or the request fails.
        if (attempt == _maxAttempts - 1) {
          rethrow;
        }
      }
    }

    throw Exception('Unable to find another Sahih Al-Bukhari hadith.');
  }

  String _getTodayDate() {
    final now = DateTime.now();

    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
