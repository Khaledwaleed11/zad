import '../../domain/entities/azkar_entity.dart';
import '../../domain/repositories/azkar_repository.dart';
import '../datasources/azkar_local_data_source.dart';
import '../models/azkar_model.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDataSource localDataSource;

  AzkarRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<AzkarEntity>> getAzkar() async {
    final builtInModels = await localDataSource.getAzkar();
    final customModels = localDataSource.getCustomAzkar();

    return [
      ...builtInModels.map((model) => model.toEntity()),
      ...customModels.map((model) => model.toEntity()),
    ];
  }

  @override
  Future<AzkarEntity> addCustomAzkar(AzkarEntity azkar) async {
    final model = AzkarModel(
      id: azkar.id,
      category: azkar.category,
      title: azkar.title,
      text: azkar.text,
      count: azkar.count,
      isCustom: true,
    );

    final savedModel = await localDataSource.addCustomAzkar(model);

    return savedModel.toEntity();
  }

  @override
  Future<void> updateCustomAzkar(AzkarEntity azkar) async {
    final model = AzkarModel(
      id: azkar.id,
      category: azkar.category,
      title: azkar.title,
      text: azkar.text,
      count: azkar.count,
      isCustom: true,
    );

    await localDataSource.updateCustomAzkar(model);
  }

  @override
  Future<void> deleteCustomAzkar(int id) async {
    await localDataSource.deleteCustomAzkar(id);
  }
}