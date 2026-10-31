
import '../entities/quran_ayah_entity.dart';
import '../repositories/quran_repository.dart';

class GetRandomAyah {
  final QuranRepository repository;

  GetRandomAyah(this.repository);

  Future<QuranAyahEntity> call() {
    return repository.getRandomAyah();
  }
}
