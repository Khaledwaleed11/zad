import '../entities/quran_local_ayah_entity.dart';
import '../repositories/quran_local_repository.dart';

class GetAllLocalAyahs {
  final QuranLocalRepository repository;

  GetAllLocalAyahs(this.repository);

  Future<List<QuranLocalAyahEntity>> call() {
    return repository.getAllAyahs();
  }
}
