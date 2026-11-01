
import '../entities/hadith_entity.dart';
import '../repositories/hadith_repository.dart';

class GetRandomHadith {
  final HadithRepository repository;

  GetRandomHadith(this.repository);

  Future<HadithEntity> call({
    int? excludeSeq,
  }) {
    return repository.getRandomHadith(
      excludeSeq: excludeSeq,
    );
  }
}
