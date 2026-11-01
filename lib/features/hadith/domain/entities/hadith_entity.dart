
import 'hadith_grade_entity.dart';
import 'narrator_entity.dart';

class HadithEntity {
  final String book;
  final String bookTitle;
  final int? number;
  final int seq;
  final String citation;
  final String chapter;
  final String chain;
  final String text;
  final String fullText;
  final HadithGradeEntity grade;
  final String gradeNote;
  final List<String> takhrij;
  final List<NarratorEntity> narrators;
  final String license;
  final String link;
  final List<String> relatedArticles;
  final String source;
  final String terms;

  const HadithEntity({
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
}
