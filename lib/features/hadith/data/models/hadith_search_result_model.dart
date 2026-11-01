
import '../../domain/entities/hadith_search_result_entity.dart';

class HadithSearchResultModel {
  final String citation;
  final int? number;
  final int seq;
  final String text;
  final String api;
  final String link;

  const HadithSearchResultModel({
    required this.citation,
    required this.number,
    required this.seq,
    required this.text,
    required this.api,
    required this.link,
  });

  factory HadithSearchResultModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return HadithSearchResultModel(
      citation: json['citation'] as String? ?? '',
      number: json['number'] as int?,
      seq: json['seq'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      api: json['api'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }

  HadithSearchResultEntity toEntity() {
    return HadithSearchResultEntity(
      citation: citation,
      number: number,
      seq: seq,
      text: text,
      api: api,
      link: link,
    );
  }
}
