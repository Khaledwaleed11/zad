import 'dart:convert';

import 'package:http/http.dart' as http;

class QuranApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';



  Future<Map<String, dynamic>> getRandomAyah() async {
    final uri = Uri.parse('$baseUrl/ayah/random/quran-uthmani-quran-academy');

    final response = await http.get(uri, headers: {'Accept-Encoding': ''});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load random ayah: ${response.statusCode}');
  }



  Future<Map<String, dynamic>> getAllSurahs() async {
    final uri = Uri.parse('$baseUrl/surah');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load surahs: ${response.statusCode}');
  }


  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    final uri = Uri.parse(
      '$baseUrl/surah/$surahNumber/quran-uthmani-quran-academy',
    );

    final response = await http.get(uri, headers: {'Accept-Encoding': ''});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load surah: ${response.statusCode}');
  }
}
