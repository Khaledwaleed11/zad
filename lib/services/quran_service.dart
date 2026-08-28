import '../api_services/quran_api_service.dart';
import '../models/quran_ayah_model.dart';
import '../models/surah_model.dart';

class QuranService {
  final QuranApiService apiService = QuranApiService();



  Future<QuranAyahModel> getRandomAyah() async {
    final data = await apiService.getRandomAyah();

    final ayahData = data['data'] as Map<String, dynamic>;

    return QuranAyahModel.fromJson(ayahData);
  }


  Future<List<SurahModel>> getAllSurahs() async {
    final data = await apiService.getAllSurahs();

    final List surahs = data['data'] ?? [];

    return surahs.map((surah) => SurahModel.fromJson(surah)).toList();
  }


  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    final data = await apiService.getSurah(surahNumber);

    return data['data'] as Map<String, dynamic>;
  }
}
