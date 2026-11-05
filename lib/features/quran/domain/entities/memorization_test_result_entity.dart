class MemorizationTestResultEntity {
  final String id;
  final DateTime date;
  final String scope;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double percentage;
  final List<Map<String, dynamic>> missedAyahs;
  const MemorizationTestResultEntity({
    required this.id,
    required this.date,
    required this.scope,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.missedAyahs,
  });
}
