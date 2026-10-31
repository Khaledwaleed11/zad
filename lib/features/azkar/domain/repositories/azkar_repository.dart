import '../entities/azkar_entity.dart';

abstract class AzkarRepository {
  Future<List<AzkarEntity>> getAzkar();

  Future<AzkarEntity> addCustomAzkar(AzkarEntity azkar);

  Future<void> updateCustomAzkar(AzkarEntity azkar);

  Future<void> deleteCustomAzkar(int id);
}