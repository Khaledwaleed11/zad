import 'package:hive/hive.dart';

import '../models/memorization_test_result_model.dart';

abstract class MemorizationTestLocalDataSource {
  Future<void> saveTestResult({required MemorizationTestResultModel result});

  List<MemorizationTestResultModel> getTestHistory();

  Future<void> clearTestHistory();
}

class MemorizationTestLocalDataSourceImpl
    implements MemorizationTestLocalDataSource {
  final Box<dynamic> box;

  MemorizationTestLocalDataSourceImpl({required this.box});

  static const String _historyKey = 'test_history';

  @override
  Future<void> saveTestResult({
    required MemorizationTestResultModel result,
  }) async {
    final history = getTestHistory();

    history.insert(0, result);

    await box.put(_historyKey, history.map((item) => item.toMap()).toList());
  }

  @override
  List<MemorizationTestResultModel> getTestHistory() {
    final data = box.get(_historyKey, defaultValue: []);

    return (data as List)
        .map(
          (item) => MemorizationTestResultModel.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> clearTestHistory() async {
    await box.delete(_historyKey);
  }
}
