import '../entities/sebha_entity.dart';
import '../repositories/sebha_repository.dart';

class SaveSebhaData {
  final SebhaRepository repository;

  SaveSebhaData(this.repository);

  Future<void> call(SebhaEntity sebha) {
    return repository.saveSebhaData(sebha);
  }
}