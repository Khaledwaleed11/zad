
import '../entities/hadith_entity.dart';
import '../repositories/hadith_repository.dart';

class GetHadithDetails {
  final HadithRepository repository;

  GetHadithDetails(this.repository);

  Future<HadithEntity> call(String apiUrl) {
    return repository.getHadithDetails(apiUrl);
  }
}
