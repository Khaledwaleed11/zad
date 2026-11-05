import '../../domain/entities/memorization_test_result_entity.dart';
import '../../domain/repositories/memorization_test_repository.dart';
import '../datasources/memorization_test_local_data_source.dart';
import '../models/memorization_test_result_model.dart';

class MemorizationTestRepositoryImpl implements MemorizationTestRepository {
  final MemorizationTestLocalDataSource localDataSource;

  MemorizationTestRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveTestResult(MemorizationTestResultEntity result) async {
    final model = MemorizationTestResultModel.fromEntity(result);

    await localDataSource.saveTestResult(result: model);
  }

  @override
  List<MemorizationTestResultEntity> getTestHistory() {
    final models = localDataSource.getTestHistory();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> clearTestHistory() async {
    await localDataSource.clearTestHistory();
  }
}
