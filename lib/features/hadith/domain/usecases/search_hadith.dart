
import '../entities/hadith_search_result_entity.dart';
import '../repositories/hadith_repository.dart';

class SearchHadith {
  final HadithRepository repository;

  SearchHadith(this.repository);

  Future<List<HadithSearchResultEntity>> call(String query) {
    return repository.searchHadith(query);
  }
}
