import '../api_services/quran_api_service.dart';
import '../models/quran_ayah_model.dart';
import '../models/surah_model.dart';

class QuranService {
  final QuranApiService apiService = QuranApiService();

  Future<QuranAyahModel> getRandomAyah() async {
    final data = await apiService.getRandomAyah();

    final rawAyah = data['data'];

    if (rawAyah is! Map) {
      throw Exception('Invalid ayah response');
    }

    return QuranAyahModel.fromJson(Map<String, dynamic>.from(rawAyah));
  }

  Future<List<SurahModel>> getAllSurahs() async {
    final data = await apiService.getAllSurahs();

    final rawSurahs = data['data'];

    if (rawSurahs is! List) {
      throw Exception('Invalid surahs response');
    }

    return rawSurahs
        .whereType<Map>()
        .map((surah) => SurahModel.fromJson(Map<String, dynamic>.from(surah)))
        .toList();
  }

  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    final data = await apiService.getSurah(surahNumber);

    final rawSurah = data['data'];

    if (rawSurah is! Map) {
      throw Exception('Invalid surah response');
    }

    return Map<String, dynamic>.from(rawSurah);
  }
}
