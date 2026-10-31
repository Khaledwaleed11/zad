
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/adhan_voice_model.dart';

abstract class AdhanVoicesRemoteDataSource {
  Future<List<AdhanVoiceModel>> getAdhanVoices();
}

class AdhanVoicesRemoteDataSourceImpl
    implements AdhanVoicesRemoteDataSource {
  final http.Client client;

  AdhanVoicesRemoteDataSourceImpl({
    required this.client,
  });

  static const String _baseUrl = 'https://alfurqan.online';

  @override
  Future<List<AdhanVoiceModel>> getAdhanVoices() async {
    final uri = Uri.parse('$_baseUrl/api/v1/athan/list');

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Adhan voices: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! Map<String, dynamic> ||
        decoded['athans'] is! List) {
      throw const FormatException(
        'Invalid Adhan voices response',
      );
    }

    return (decoded['athans'] as List)
        .whereType<Map>()
        .map(
          (item) => AdhanVoiceModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }
}
