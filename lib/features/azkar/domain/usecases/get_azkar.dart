import '../entities/azkar_entity.dart';
import '../repositories/azkar_repository.dart';

class GetAzkar {
  final AzkarRepository repository;

  GetAzkar(this.repository);

  Future<List<AzkarEntity>> call() {
    return repository.getAzkar();
  }
}