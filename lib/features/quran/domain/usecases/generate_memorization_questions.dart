import '../entities/memorization_test_config_entity.dart';
import '../entities/memorization_question_entity.dart';
import '../repositories/memorization_question_generator_repository.dart';

class GenerateMemorizationQuestions {
  final MemorizationQuestionGeneratorRepository repository;

  GenerateMemorizationQuestions(this.repository);

  Future<List<MemorizationQuestionEntity>> call({
    required MemorizationTestConfigEntity config,
  }) {
    return repository.generateQuestions(config: config);
  }
}
