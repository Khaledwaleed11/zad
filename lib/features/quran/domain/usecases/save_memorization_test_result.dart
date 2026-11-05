import '../entities/memorization_test_result_entity.dart';
import '../repositories/memorization_test_repository.dart';

class SaveMemorizationTestResult {
  final MemorizationTestRepository repository;

  SaveMemorizationTestResult(this.repository);

  Future<void> call(MemorizationTestResultEntity result) {
    return repository.saveTestResult(result);
  }
}
