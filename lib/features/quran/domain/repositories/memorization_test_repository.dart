import '../entities/memorization_test_result_entity.dart';

abstract class MemorizationTestRepository {
  Future<void> saveTestResult(MemorizationTestResultEntity result);

  List<MemorizationTestResultEntity> getTestHistory();

  Future<void> clearTestHistory();
}
