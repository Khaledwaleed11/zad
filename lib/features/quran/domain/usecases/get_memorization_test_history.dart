import '../entities/memorization_test_result_entity.dart';
import '../repositories/memorization_test_repository.dart';

class GetMemorizationTestHistory {
  final MemorizationTestRepository repository;

  GetMemorizationTestHistory(this.repository);

  List<MemorizationTestResultEntity> call() {
    return repository.getTestHistory();
  }
}
