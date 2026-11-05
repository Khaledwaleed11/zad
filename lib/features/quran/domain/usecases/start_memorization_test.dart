import '../entities/memorization_test_config_entity.dart';
import '../entities/memorization_test_session_entity.dart';
import 'generate_memorization_questions.dart';

class StartMemorizationTest {
  final GenerateMemorizationQuestions generateQuestions;

  StartMemorizationTest(this.generateQuestions);

  Future<MemorizationTestSessionEntity> call({
    required MemorizationTestConfigEntity config,
  }) async {
    final questions = await generateQuestions(config: config);

    return MemorizationTestSessionEntity(
      config: config,
      questions: questions,
      answersCorrectness: const [],
      missedAyahs: const [],
    );
  }
}
