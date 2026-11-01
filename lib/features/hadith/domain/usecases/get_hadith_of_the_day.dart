
import '../entities/hadith_entity.dart';
import '../repositories/hadith_repository.dart';

class GetHadithOfTheDay {
  final HadithRepository repository;

  GetHadithOfTheDay(this.repository);

  Future<HadithEntity> call() {
    return repository.getHadithOfTheDay();
  }
}
