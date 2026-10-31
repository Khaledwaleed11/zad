import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/storage_constants.dart';
import '../models/sebha_model.dart';

abstract class SebhaLocalDataSource {
  SebhaModel getSebhaData();

  Future<void> saveSebhaData(SebhaModel sebha);

  Future<void> resetCounter();
}

class SebhaLocalDataSourceImpl implements SebhaLocalDataSource {
  static const String _boxName = StorageConstants.sebhaBox;
  static const String _countKey = 'count';
  static const String _targetKey = 'target';
  static const String _zikrKey = 'zikr';

  Box get _box => Hive.box(_boxName);

  @override
  SebhaModel getSebhaData() {
    return SebhaModel.fromStorage(
      count: _box.get(_countKey, defaultValue: 0) as int,
      target: _box.get(_targetKey, defaultValue: 33) as int,
      zikr: _box.get(_zikrKey, defaultValue: 'سبحان الله') as String,
    );
  }

  @override
  Future<void> saveSebhaData(SebhaModel sebha) async {
    await _box.put(_countKey, sebha.count);
    await _box.put(_targetKey, sebha.target);
    await _box.put(_zikrKey, sebha.zikr);
  }

  @override
  Future<void> resetCounter() async {
    await _box.put(_countKey, 0);
  }
}