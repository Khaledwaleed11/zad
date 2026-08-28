import 'dart:convert';

import 'package:http/http.dart' as http;

class PrayerApiService {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  Future<Map<String, dynamic>> getPrayerTimes() async {
    final uri = Uri.parse(
      '$baseUrl/timingsByCity'
      '?city=Cairo'
      '&country=Egypt'
      '&method=5',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load prayer times: ${response.statusCode}');
  }
}
