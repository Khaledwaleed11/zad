
import '../entities/hadith_entity.dart';
import '../entities/hadith_search_result_entity.dart';

abstract class HadithRepository {
  Future<List<HadithSearchResultEntity>> searchHadith(
      String query,
      );

  Future<HadithEntity> getHadithDetails(
      String apiUrl,
      );

  Future<HadithEntity> getHadithOfTheDay();

  Future<HadithEntity> getRandomHadith({
    int? excludeSeq,
  });
}
