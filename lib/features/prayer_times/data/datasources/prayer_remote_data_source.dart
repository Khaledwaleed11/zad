import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class PrayerRemoteDataSource {
  Future<Map<String, dynamic>> getPrayerTimes();

  Future<Map<String, dynamic>> getPrayerCalendar({
    required int month,
    required int year,
  });
}

class PrayerRemoteDataSourceImpl implements PrayerRemoteDataSource {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  @override
  Future<Map<String, dynamic>> getPrayerTimes() async {
    final uri = Uri.parse(
      '$_baseUrl/timingsByCity'
          '?city=Cairo'
          '&country=Egypt'
          '&method=5',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load prayer times: ${response.statusCode}',
    );
  }

  @override
  Future<Map<String, dynamic>> getPrayerCalendar({
    required int month,
    required int year,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/calendarByCity'
          '?city=Cairo'
          '&country=Egypt'
          '&method=5'
          '&month=$month'
          '&year=$year',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load prayer calendar: ${response.statusCode}',
    );
  }
}