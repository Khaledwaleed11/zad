import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class QuranRemoteDataSource {
  Future<Map<String, dynamic>> getRandomAyah();

  Future<Map<String, dynamic>> getAllSurahs();

  Future<Map<String, dynamic>> getSurah(int surahNumber);

  Future<Map<String, dynamic>> getAllReciters();
}

class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  static const String _mp3QuranBaseUrl = 'https://mp3quran.net/api/v3';

  @override
  Future<Map<String, dynamic>> getRandomAyah() async {
    final uri = Uri.parse('$_baseUrl/ayah/random/quran-uthmani-quran-academy');

    return _get(uri);
  }

  @override
  Future<Map<String, dynamic>> getAllSurahs() async {
    final uri = Uri.parse('$_baseUrl/surah');

    return _get(uri);
  }

  @override
  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    final uri = Uri.parse(
      '$_baseUrl/surah/$surahNumber/quran-uthmani-quran-academy',
    );

    return _get(uri);
  }

  @override
  Future<Map<String, dynamic>> getAllReciters() async {
    final uri = Uri.parse(
      '$_mp3QuranBaseUrl/reciters',
    ).replace(queryParameters: {'language': 'ar'});

    return _get(uri);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Quran API request failed: ${response.statusCode}');
  }
}
