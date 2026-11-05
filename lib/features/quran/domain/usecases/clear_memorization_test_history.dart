import '../repositories/memorization_test_repository.dart';

class ClearMemorizationTestHistory {
  final MemorizationTestRepository repository;

  ClearMemorizationTestHistory(this.repository);

  Future<void> call() {
    return repository.clearTestHistory();
  }
}
