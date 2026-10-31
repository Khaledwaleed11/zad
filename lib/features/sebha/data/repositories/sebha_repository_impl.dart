import '../../domain/entities/sebha_entity.dart';
import '../../domain/repositories/sebha_repository.dart';
import '../datasources/sebha_local_data_source.dart';
import '../models/sebha_model.dart';

class SebhaRepositoryImpl implements SebhaRepository {
  final SebhaLocalDataSource localDataSource;

  SebhaRepositoryImpl({
    required this.localDataSource,
  });

  @override
  SebhaEntity getSebhaData() {
    return localDataSource.getSebhaData().toEntity();
  }

  @override
  Future<void> saveSebhaData(SebhaEntity sebha) async {
    final model = SebhaModel(
      count: sebha.count,
      target: sebha.target,
      zikr: sebha.zikr,
    );

    await localDataSource.saveSebhaData(model);
  }

  @override
  Future<void> resetCounter() async {
    await localDataSource.resetCounter();
  }
}