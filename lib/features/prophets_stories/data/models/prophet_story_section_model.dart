import '../../domain/entities/prophet_story_section_entity.dart';

class ProphetStorySectionModel {
  final String pageTitle;
  final String volumeTitle;
  final String title;
  final int sectionIndex;

  const ProphetStorySectionModel({
    required this.pageTitle,
    required this.volumeTitle,
    required this.title,
    required this.sectionIndex,
  });

  factory ProphetStorySectionModel.fromApi({
    required Map<String, dynamic> json,
    required String pageTitle,
    required String volumeTitle,
  }) {
    final sectionIndex = int.tryParse(
      '${json['index'] ?? json['number'] ?? ''}',
    );

    if (sectionIndex == null) {
      throw const FormatException('Invalid Wikisource section index.');
    }

    return ProphetStorySectionModel(
      pageTitle: pageTitle,
      volumeTitle: volumeTitle,
      title: _stripHtml('${json['line'] ?? ''}').trim(),
      sectionIndex: sectionIndex,
    );
  }

  ProphetStorySectionEntity toEntity() {
    return ProphetStorySectionEntity(
      pageTitle: pageTitle,
      volumeTitle: volumeTitle,
      title: title,
      sectionIndex: sectionIndex,
    );
  }

  static String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
          return String.fromCharCode(int.parse(match.group(1)!));
        })
        .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
          return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
        });
  }
}
