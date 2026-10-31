import '../entities/azkar_entity.dart';
import '../repositories/azkar_repository.dart';

class AddCustomAzkar {
  final AzkarRepository repository;

  AddCustomAzkar(this.repository);

  Future<AzkarEntity> call(AzkarEntity azkar) {
    return repository.addCustomAzkar(azkar);
  }
}