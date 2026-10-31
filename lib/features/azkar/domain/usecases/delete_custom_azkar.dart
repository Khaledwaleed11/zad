import '../repositories/azkar_repository.dart';

class DeleteCustomAzkar {
  final AzkarRepository repository;

  DeleteCustomAzkar(this.repository);

  Future<void> call(int id) {
    return repository.deleteCustomAzkar(id);
  }
}