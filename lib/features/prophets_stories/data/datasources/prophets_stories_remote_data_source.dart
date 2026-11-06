import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prophet_story_section_model.dart';

abstract class ProphetsStoriesRemoteDataSource {
  Future<List<ProphetStorySectionModel>> getStorySections();

  Future<String> getStorySectionContent({
    required String pageTitle,
    required int sectionIndex,
  });
}

class ProphetsStoriesRemoteDataSourceImpl
    implements ProphetsStoriesRemoteDataSource {
  static const String _apiHost = 'ar.wikisource.org';
  static const String _apiPath = '/w/api.php';
  static const Map<String, String> _storyPages = {
    'قصص الأنبياء لابن كثير/الجزء الأول': 'الجزء الأول',
    'قصص الأنبياء لابن كثير/الجزء الثاني': 'الجزء الثاني',
  };

  final http.Client client;

  const ProphetsStoriesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProphetStorySectionModel>> getStorySections() async {
    final sections = <ProphetStorySectionModel>[];

    // Wikisource API guidance recommends serial requests rather than fan-out.
    for (final entry in _storyPages.entries) {
      final response = await _getJson({
        'action': 'parse',
        'format': 'json',
        'page': entry.key,
        'prop': 'sections',
      });

      final parse = response['parse'];
      final rawSections = parse is Map ? parse['sections'] : null;

      if (rawSections is! List) {
        throw const FormatException('Invalid Wikisource sections response.');
      }

      for (final rawSection in rawSections) {
        if (rawSection is! Map) continue;

        final section = ProphetStorySectionModel.fromApi(
          json: Map<String, dynamic>.from(rawSection),
          pageTitle: entry.key,
          volumeTitle: entry.value,
        );

        if (section.title.isNotEmpty) sections.add(section);
      }
    }

    return sections;
  }

  @override
  Future<String> getStorySectionContent({
    required String pageTitle,
    required int sectionIndex,
  }) async {
    if (!_storyPages.containsKey(pageTitle) || sectionIndex < 1) {
      throw ArgumentError('Invalid Wikisource story section.');
    }

    final response = await _getJson({
      'action': 'parse',
      'format': 'json',
      'page': pageTitle,
      'section': sectionIndex.toString(),
      'prop': 'text',
      'disableeditsection': '1',
      'disabletoc': '1',
    });

    final parse = response['parse'];
    final rawText = parse is Map ? parse['text'] : null;
    final html = rawText is String
        ? rawText
        : rawText is Map
        ? '${rawText['*'] ?? ''}'
        : '';

    if (html.isEmpty) {
      throw const FormatException('Wikisource returned an empty story.');
    }

    return _htmlToPlainText(html);
  }

  Future<Map<String, dynamic>> _getJson(Map<String, String> parameters) async {
    final uri = Uri.https(_apiHost, _apiPath, parameters);
    final response = await client
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'ZadMobileApp/1.0 (prophets_stories)',
          },
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Wikisource request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid Wikisource API response.');
    }

    final apiError = decoded['error'];
    if (apiError is Map) {
      throw Exception('${apiError['info'] ?? 'Wikisource API error.'}');
    }

    return decoded;
  }

  String _htmlToPlainText(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '• ')
        .replaceAll(
          RegExp(
            r'</(p|div|h[1-6]|li|blockquote|tr)\s*>',
            caseSensitive: false,
          ),
          '\n\n',
        )
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&lrm;', '')
        .replaceAll('&rlm;', '')
        .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
          return String.fromCharCode(int.parse(match.group(1)!));
        })
        .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
          return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
        })
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
