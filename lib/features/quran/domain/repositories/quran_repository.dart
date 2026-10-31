
import '../entities/quran_ayah_entity.dart';
import '../entities/surah_entity.dart';
import '../entities/reciter_entity.dart';

abstract class QuranRepository {
  Future<QuranAyahEntity> getRandomAyah();

  Future<List<SurahEntity>> getAllSurahs();

  Future<List<QuranAyahEntity>> getSurahAyahs(int surahNumber);

  Future<List<ReciterEntity>> getAllReciters();
}
