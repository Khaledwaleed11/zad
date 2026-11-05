import '../entities/quran_ayah_entity.dart';
import '../repositories/quran_repository.dart';

class GetSurahAyahs {
  final QuranRepository repository;

  GetSurahAyahs(this.repository);

  Future<List<QuranAyahEntity>> call(int surahNumber) {
    return repository.getSurahAyahs(surahNumber);
  }
}
