
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class HadithRemoteDataSource {
  Future<Map<String, dynamic>> searchHadith(String query);

  Future<Map<String, dynamic>> getHadithDetails(String apiUrl);

  Future<Map<String, dynamic>> getHadithByNumber(int number);
}

class HadithRemoteDataSourceImpl implements HadithRemoteDataSource {
  static const String _baseUrl = 'https://bayan.alwa7i.com/api';

  final http.Client client;

  HadithRemoteDataSourceImpl({
    required this.client,
  });

  @override
  Future<Map<String, dynamic>> searchHadith(String query) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {'q': query},
    );

    return _get(uri);
  }

  @override
  Future<Map<String, dynamic>> getHadithDetails(String apiUrl) async {
    final uri = Uri.parse(apiUrl);

    if (uri.scheme != 'https' ||
        uri.host != 'bayan.alwa7i.com' ||
        !uri.path.startsWith('/api/hadith/')) {
      throw Exception('Invalid Bayan API URL');
    }

    return _get(uri);
  }

  @override
  Future<Map<String, dynamic>> getHadithByNumber(int number) async {
    if (number <= 0) {
      throw Exception('Invalid hadith number');
    }

    final uri = Uri.parse('$_baseUrl/hadith/sahih-al-bukhari').replace(
      queryParameters: {'number': number.toString()},
    );

    return _get(uri);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final response = await client
        .get(uri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid Bayan API response format');
    }

    throw Exception(
      'Bayan API request failed: ${response.statusCode}',
    );
  }
}
