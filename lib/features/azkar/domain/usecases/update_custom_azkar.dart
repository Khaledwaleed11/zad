import '../entities/azkar_entity.dart';
import '../repositories/azkar_repository.dart';

class UpdateCustomAzkar {
  final AzkarRepository repository;

  UpdateCustomAzkar(this.repository);

  Future<void> call(AzkarEntity azkar) {
    return repository.updateCustomAzkar(azkar);
  }
}