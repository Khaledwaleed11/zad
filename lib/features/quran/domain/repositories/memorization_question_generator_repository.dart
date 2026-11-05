import '../entities/memorization_test_config_entity.dart';
import '../entities/memorization_question_entity.dart';

abstract class MemorizationQuestionGeneratorRepository {
  Future<List<MemorizationQuestionEntity>> generateQuestions({
    required MemorizationTestConfigEntity config,
  });
}
