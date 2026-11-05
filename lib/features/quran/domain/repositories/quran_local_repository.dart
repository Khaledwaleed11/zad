import '../entities/quran_local_ayah_entity.dart';

abstract class QuranLocalRepository {
  Future<List<QuranLocalAyahEntity>> getAllAyahs();
}
