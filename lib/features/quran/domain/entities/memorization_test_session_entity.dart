import 'memorization_test_config_entity.dart';
import 'memorization_question_entity.dart';
import 'memorization_missed_ayah_entity.dart';

class MemorizationTestSessionEntity {
  final MemorizationTestConfigEntity config;
  final List<MemorizationQuestionEntity> questions;
  final List<bool> answersCorrectness;
  final List<MemorizationMissedAyahEntity> missedAyahs;

  const MemorizationTestSessionEntity({
    required this.config,
    required this.questions,
    required this.answersCorrectness,
    required this.missedAyahs,
  });

  int get totalQuestions => questions.length;

  int get correctAnswers =>
      answersCorrectness.where((isCorrect) => isCorrect).length;

  int get wrongAnswers => totalQuestions - correctAnswers;

  double get percentage =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;
}
