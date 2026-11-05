
import '../../domain/entities/memorization_test_result_entity.dart';

class MemorizationTestResultModel {
  final String id;
  final DateTime date;
  final String scope;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double percentage;
  final List<Map<String, dynamic>> missedAyahs;

  MemorizationTestResultModel({
    required this.id,
    required this.date,
    required this.scope,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.missedAyahs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'scope': scope,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'percentage': percentage,
      'missedAyahs': missedAyahs,
    };
  }

  factory MemorizationTestResultModel.fromEntity(
      MemorizationTestResultEntity entity,
      ) {
    return MemorizationTestResultModel(
      id: entity.id,
      date: entity.date,
      scope: entity.scope,
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      wrongAnswers: entity.wrongAnswers,
      percentage: entity.percentage,
      missedAyahs: entity.missedAyahs,
    );
  }

  MemorizationTestResultEntity toEntity() {
    return MemorizationTestResultEntity(
      id: id,
      date: date,
      scope: scope,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      percentage: percentage,
      missedAyahs: missedAyahs,
    );
  }

  factory MemorizationTestResultModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final rawMissedAyahs = map['missedAyahs'] as List? ?? [];

    return MemorizationTestResultModel(
      id: map['id']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ??
          DateTime.now(),
      scope: map['scope']?.toString() ?? '',
      totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? 0,
      correctAnswers: (map['correctAnswers'] as num?)?.toInt() ?? 0,
      wrongAnswers: (map['wrongAnswers'] as num?)?.toInt() ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      missedAyahs: rawMissedAyahs.map((item) {
        final missedAyah = Map<String, dynamic>.from(item as Map);

        return {
          'surahNumber':
          (missedAyah['surahNumber'] as num?)?.toInt() ?? 0,
          'ayahNumber':
          (missedAyah['ayahNumber'] as num?)?.toInt() ?? 0,
          'surahName': missedAyah['surahName']?.toString(),
        };
      }).toList(),
    );
  }
}
