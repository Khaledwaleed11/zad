
import '../../domain/entities/hadith_entity.dart';
import 'hadith_grade_model.dart';
import 'narrator_model.dart';

class HadithModel {
  final String book;
  final String bookTitle;
  final int? number;
  final int seq;
  final String citation;
  final String chapter;
  final String chain;
  final String text;
  final String fullText;
  final HadithGradeModel grade;
  final String gradeNote;
  final List<String> takhrij;
  final List<NarratorModel> narrators;
  final String license;
  final String link;
  final List<String> relatedArticles;
  final String source;
  final String terms;

  const HadithModel({
    required this.book,
    required this.bookTitle,
    required this.number,
    required this.seq,
    required this.citation,
    required this.chapter,
    required this.chain,
    required this.text,
    required this.fullText,
    required this.grade,
    required this.gradeNote,
    required this.takhrij,
    required this.narrators,
    required this.license,
    required this.link,
    required this.relatedArticles,
    required this.source,
    required this.terms,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    final gradeJson = json['grade'] is Map
        ? Map<String, dynamic>.from(json['grade'] as Map)
        : <String, dynamic>{};

    final narratorsJson = json['narrators'] is List
        ? json['narrators'] as List
        : [];

    return HadithModel(
      book: json['book'] as String? ?? '',
      bookTitle: json['bookTitle'] as String? ?? '',
      number: json['number'] as int?,
      seq: json['seq'] as int? ?? 0,
      citation: json['citation'] as String? ?? '',
      chapter: json['chapter'] as String? ?? '',
      chain: json['chain'] as String? ?? '',
      text: json['text'] as String? ?? '',
      fullText: json['fullText'] as String? ?? '',
      grade: HadithGradeModel.fromJson(gradeJson),
      gradeNote: json['gradeNote'] as String? ?? '',
      takhrij: (json['takhrij'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      narrators: narratorsJson
          .whereType<Map>()
          .map(
            (item) => NarratorModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      license: json['license'] as String? ?? '',
      link: json['link'] as String? ?? '',
      relatedArticles: (json['relatedArticles'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      source: json['source'] as String? ?? '',
      terms: json['terms'] as String? ?? '',
    );
  }

  HadithEntity toEntity() {
    return HadithEntity(
      book: book,
      bookTitle: bookTitle,
      number: number,
      seq: seq,
      citation: citation,
      chapter: chapter,
      chain: chain,
      text: text,
      fullText: fullText,
      grade: grade.toEntity(),
      gradeNote: gradeNote,
      takhrij: takhrij,
      narrators: narrators.map((item) => item.toEntity()).toList(),
      license: license,
      link: link,
      relatedArticles: relatedArticles,
      source: source,
      terms: terms,
    );
  }
}
