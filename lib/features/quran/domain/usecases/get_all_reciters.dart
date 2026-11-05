import '../entities/reciter_entity.dart';
import '../repositories/quran_repository.dart';

class GetAllReciters {
  final QuranRepository repository;

  GetAllReciters(this.repository);

  Future<List<ReciterEntity>> call() {
    return repository.getAllReciters();
  }
}
