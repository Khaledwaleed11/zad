
import 'dart:convert';

import 'package:http/http.dart' as http;

class PrayerApiService {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  Future<Map<String, dynamic>> getPrayerTimes() async {
    final now = DateTime.now();

    final date = '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';

    final uri = Uri.parse(
      '$baseUrl/timingsByCity/$date'
          '?city=Cairo'
          '&country=Egypt'
          '&method=5',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load prayer times: ${response.statusCode} '
          '${response.body}',
    );
  }

  Future<Map<String, dynamic>> getPrayerCalendar({
    required int month,
    required int year,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/calendarByCity/$year/$month'
          '?city=Cairo'
          '&country=Egypt'
          '&method=5',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load prayer calendar: ${response.statusCode} '
          '${response.body}',
    );
  }
}
